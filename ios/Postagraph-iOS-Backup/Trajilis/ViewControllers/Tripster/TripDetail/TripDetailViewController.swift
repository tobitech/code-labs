//
//  TripsterDetailVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 18/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import SDWebImage

final class TripDetailViewController: BaseVC {
    
    var viewModel: TripsterDetailViewModel!
    var isPublic: Bool = false
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        hidesBottomBarWhenPushed = true
        title = "Trip Details"
        
        viewModel.reload = {
            self.collectionView.reloadData()
        }
        
        var rightBarButtons: [UIBarButtonItem] = []
        
        if viewModel.isAdmin && !isPublic {
            let edit = UIBarButtonItem(image: UIImage(named: "editIcon"), style: .plain, target: self, action: #selector(editTrip))
            rightBarButtons.append(edit)
        }
        
        if viewModel.trip.shouldShowChat() {
            let chat = UIBarButtonItem(image: UIImage(named: "message"), style: .plain, target: self, action: #selector(openGroupChat))
            rightBarButtons.append(chat)
        }
        navigationItem.rightBarButtonItems = rightBarButtons
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    @objc private func editTrip() {
        let controller: NewTripViewController = Router.get()
        let model = NewTripViewModel.init()
        model.trip = viewModel.trip
        model.isEdit = true
        controller.viewModel = model
        controller.didAddTrip = { [weak self] in
            self?.viewModel.getTripDetail()
        }
        controller.onTripDelete = { [weak self] in
            guard let nav = self?.navigationController else {return}
            if let index = nav.viewControllers.firstIndex(of: self!) {
                if let vc = nav.viewControllers.item(at: max(index - 1, 0)) {
                    nav.popToViewController(vc, animated: true)
                }
            }
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func playUsersMemory(userId:String) {
        var urls = [String]()
        for mmory in viewModel.memories {
            if mmory.userId == userId {
                urls.append(mmory.cdnUrl)
            }
        }
        let controller = FullscreenVideoVC.instantiate(fromAppStoryboard: .feed)
        controller.playlistURLs = urls
        controller.isMultipleVideo = true
        controller.imageURL = viewModel.memories.first?.imageURL ?? ""
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func viewUserList() {
        let controller = storyboard?.instantiateViewController(withIdentifier: "TripDetailUserListViewController") as! TripDetailUserListViewController
        let viewModel = TripDetailUserListViewModel(members: self.viewModel.members, tripId: self.viewModel.trip.tripId)
        controller.viewModel = viewModel
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = .overFullScreen
        controller.providesPresentationContextTransitionStyle = true
        controller.onDismiss = { [weak self] shouldPop in
            if shouldPop {
                self?.navigationController?.popViewController(animated: true)
            }else {
                self?.viewModel.getTripDetail()
            }
            self?.navigationController?.dim(.out, speed: 0)
        }
        controller.onAddUser = { [weak self] in
            self?.openAddMember()
            self?.navigationController?.dim(.out, speed: 0)
        }
        controller.onOpenChat = { [weak self] tripMember in
            self?.openChat(member: tripMember)
            self?.navigationController?.dim(.out, speed: 0)
        }
        controller.onOpenUser = { [weak self] tripMember in
            self?.openProfile(tripMember: tripMember)
            self?.navigationController?.dim(.out, speed: 0)
        }
        navigationController?.dim(.in, color: UIColor.black, alpha: 0.3, speed: 0.5)
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    private func openProfile(tripMember: TripMember) {
        let controller: ProfileViewController = Router.get()
        let vModel = ProfileViewModel(userId:  tripMember.userId)
        controller.viewModel = vModel
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func openGroupChat() {
        if !viewModel.trip.chatGroupId.isEmpty {
            spinner(with: "Loading...", blockInteraction: true)
            viewModel.getGroupById(id: viewModel.trip.chatGroupId) { [weak self] group in
                self?.hideSpinner()
                guard let self = self,
                    let chatContact = group,
                    let user = (UIApplication.shared.delegate as? AppDelegate)?.user else {return}
                let controller = ChatViewController.instantiate(fromAppStoryboard: .message)
                controller.chatContact = chatContact
                controller.currentUser = user.condensedUser
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
                SocketIOManager.shared.msgVC?.viewModel.refresh()
            }
        }
    }
    
    private func openChat(member: TripMember) {
        spinner(with: "", blockInteraction: true)
        ChatViewController.createGroup(withUser: member.condensedUser) { [weak self] (chatContact) in
            self?.hideSpinner()
            if let grp = chatContact, let currentUser = (UIApplication.shared.delegate as? AppDelegate)?.user {
                let controller = ChatViewController.instantiate(fromAppStoryboard: .message)
                controller.chatContact = grp
                controller.currentUser = currentUser.condensedUser
                controller.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(controller, animated: true)
            } else {
                self?.showAlert(message: "App is unable to process request.")
            }
        }
    }
    
    private func openAddMember() {
        let vc: AddMemberToTripViewController = Router.get()
        let viewModel = AddMemberToTripViewModel()
        viewModel.excludeUserIds = self.viewModel.members.map({$0.userId})
        viewModel.mode = .edit
        viewModel.noMemberTitle = "Add users to your trip."
        viewModel.noMemberSubtitle = "Tap the search bar to find members."
        vc.viewModel = viewModel
        vc.title = "Manage Users"
        vc.onAdd = { [weak self] userId in
            self?.viewModel.addUserToTrip(userId: userId)
        }
        vc.onRemove = { [weak self] userId in
            self?.viewModel.deleteUserFromTrip(userId: userId)
        }
        vc.onDone = { [weak self] in
            self?.viewModel.getTripDetail()
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func unpin(feed: Feed) {
        let alertController = UIAlertController(title: "Postagraph", message: "Are you sure you want to unpin?", preferredStyle: .alert)
        let continueButton = UIAlertAction(title: "Continue", style: .default) { (_) in
            self.viewModel.unpin(feed: feed)
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(continueButton)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
}

extension TripDetailViewController: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeue(TripDetailHeaderCollectionReusableView.self, for: indexPath, forSupplementaryViewOfKind: kind)
        reusableView.trip = viewModel.trip
        reusableView.selectedMode = viewModel.selectedTab
        reusableView.onTabChanged = { [weak self] in
            guard let self = self else {return}
            self.viewModel.selectedTab = $0
            if $0 == .Pins && self.viewModel.tripPins.isEmpty {
                self.viewModel.getTripPinsMemmories()
            }
            self.collectionView.reloadData()
        }
        reusableView.onMemberSelected = { [weak self] member in
            guard let self = self else {return}
            self.openProfile(tripMember: member)
//            if !member.memberMemoryCount.isEmpty && member.memberMemoryCount != "0" {
//                let controller = TripsterMemoriesViewController.instantiate(fromAppStoryboard: .tripster)
//                let model = TripsterMemoriesViewModel(userId: member.userId, trip: self.viewModel.trip)
//                controller.viewModel = model
//                self.navigationController?.pushViewController(controller, animated: true)
//            }
        }
        reusableView.onAddMemoryTapped = { [weak self] in
            if !Helpers.isLoggedIn() {
                self?.unauthenticatedBlock(canDismiss: true)
            }
            self?.openCamera()
        }
        reusableView.onBookFlightsTapped = { [weak self] in
            guard let self = self else {return}
            if let navVC = self.tabBarController?.viewControllers?[kTabIndex.Book.rawValue] as? UINavigationController {
                
                if let bookVC = navVC.viewControllers.first as? BookingViewController {
                    //bookVC.showFlights(origin: origin, destination: destinatoin)
//                    bookVC.searchOrigin = origin
//                    bookVC.searchDestination = destinatoin
                    self.tabBarController?.selectedIndex = kTabIndex.Book.rawValue
                }
            }
        }
        reusableView.onUsersTapped = { [weak self] in
            self?.viewUserList()
        }
        reusableView.addAMemoryView.superview?.isHidden = !viewModel.isMember
        return reusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        switch viewModel.selectedTab {
        case .AllMemories:
            return max(viewModel.memories.count, 1)
        case .Pins:
            return  max(viewModel.tripPins.count, 1)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let feed: Feed?
        switch viewModel.selectedTab {
        case .AllMemories:
            feed = viewModel.memories.item(at: indexPath.item)
        case .Pins:
            feed = viewModel.tripPins.item(at: indexPath.item)
        }
        
        if feed == nil {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Empty", for: indexPath)
            let titleLabel = cell.viewWithTag(1) as? UILabel
            let subtitleLabel = cell.viewWithTag(2) as? UILabel
            titleLabel?.text = viewModel.selectedTab == .Pins ? "No Pins" : "No Memories"
            subtitleLabel?.text = viewModel.selectedTab == .Pins ? "Pin posts you like to this trip." : "Add new memories to this trip"
            return cell
        }
        
        let cell = collectionView.dequeue(TripListMemoryCollectionViewCell.self, for: indexPath)
        cell.deleteButton?.isHidden = viewModel.selectedTab == .AllMemories || !viewModel.isAdmin
        cell.onDeleteTapped = { [weak self] in
            self?.unpin(feed: feed!)
        }
        cell.imageView.image = nil
        cell.viewCountLabel.text = "\(feed?.viewcount ?? 0)"
        if let urlString = feed?.imageURL,
            let url = URL(string: urlString) {
            cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageView.sd_setImage(with: url, completed: nil)
        }
         return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feeds: [Feed]
        switch viewModel.selectedTab {
        case .AllMemories:
            feeds = viewModel.memories
        case .Pins:
            feeds = viewModel.tripPins
        }
        
        let controller = FeedDetailVC.instantiate(fromAppStoryboard: .feed)
        controller.feeds = feeds
        controller.selectedFeedIndex = indexPath.item
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: viewModel.isMember ? 612 : 476)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if viewModel.selectedTab == .AllMemories && !viewModel.memories.isEmpty || viewModel.selectedTab == .Pins && !viewModel.tripPins.isEmpty {
            let width = (collectionView.frame.width - 4)/3
            let height = width*163/124
            return CGSize(width: width, height: height)
        }else {
            return CGSize(width: collectionView.frame.width, height: 150)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleIndexPath = collectionView.indexPathsForVisibleItems
        if let indexPath = visibleIndexPath.first {
            if viewModel.selectedTab == .AllMemories {
                if !viewModel.memories.isEmpty && (viewModel.memories.count - indexPath.row) == 5 && !viewModel.isLastContent {
                    viewModel.getTripMemmories(isLoadingMore: true)
                }
            }else {
                if !viewModel.tripPins.isEmpty && (viewModel.tripPins.count - indexPath.row) == 5 && !viewModel.isLastContent {
                    viewModel.getTripPinsMemmories(isLoadingMore: true)
                }
            }
        }
    }
    
    func getGroupById(id:String, onComplete:@escaping (ChatContact?) -> Void) {
        guard Helpers.isLoggedIn() else { return }
        
        self.spinner(with: "Loading...", blockInteraction: true)
        APIController.makeRequest(request: .getChatUsers) { (response) in
            self.hideSpinner()
            switch response {
            case .failure(_):
                
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                let chats = data.compactMap{ ChatContact.init(json: $0) }
                let group = chats.filter({ (contact) -> Bool in
                    if contact.groupId == id {
                        return true
                    }
                    return false
                })
                onComplete(group.first)
            }
        }
    }
    
}
