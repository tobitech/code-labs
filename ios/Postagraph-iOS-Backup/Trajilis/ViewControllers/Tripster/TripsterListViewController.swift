//
//  TripsterListViewController.swift
//  Trajilis
//
//  Created by bharats802 on 13/03/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import SDWebImage

class TripsterListViewController: BaseVC, UITableViewDelegate,UITableViewDataSource {
    
    let noTripVC: NoTripViewController = Router.get()
    var selected:((Trip) -> Void)?
    var viewModel = TripListViewModel()
    private weak var inviteBadgeButton: SSBadgeButton?
    private var didAnimate: Bool = false
    
    @IBOutlet weak var tblView:UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        viewModel.viewMode = .CurrentTrips
        
        self.navigationItem.largeTitleDisplayMode = .never
        self.showNavigationBar()
        self.tblView.backgroundColor = UIColor.clear
        
        viewModel.onInviteTripCountUpdate = { [weak self] count in
            self?.inviteBadgeButton?.badge = count
            self?.inviteBadgeButton?.tintColor = count == nil ? UIColor(hexString: "#E5E5E5") : UIColor(hexString: "#D63D41")
        }
        
        if viewModel.isOnMainTab {
            self.navigationItem.title = "Trips"
            self.tabBarItem.title = nil
            guard let loggedInUserId = UserDefaults.standard.value(forKey: USERID) as? String else {
                return
            }
            viewModel.userId = loggedInUserId
            let button = SSBadgeButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
            button.badgeEdgeInsets = UIEdgeInsets(top: 18, left: 0, bottom: 0, right: 22)
            button.setImage(UIImage(named: "briefcaseNew"), for: .normal)
            button.tintColor = UIColor(hexString: "#E5E5E5")
            button.contentHorizontalAlignment = .leading
            button.addTarget(self, action: #selector(self.btnInvitesTripTapped), for: .touchUpInside)
            navigationItem.leftBarButtonItem = UIBarButtonItem(customView: button)
            inviteBadgeButton = button
            button.clipsToBounds = false
        } else {
            switch viewModel.viewMode {
            case .AllTrip:
                title = "Trips"
            case .Invited:
                title = "Invites"
            case .ForPin:
                title = "Select Trip"
            case .CurrentTrips:
                title = "Select Trip"
                getCurrentTrips()
            case .Public:
                title = "Popular Trips"
            }
        }
        addRightBarButton()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.isOnMainTab {
            viewModel.getPendingInviteCount()
        }
        viewModel.tripListResponse.removeAll()
        switch viewModel.viewMode {
        case .AllTrip, .ForPin:
            getTripList(inviteCode: "ACCEPTED")
        case .Invited:
            fetchInvitedTrips()
        case .Public:
            fetchTrendingTrips()
        case .CurrentTrips: break
        }
    }
    
    private func addRightBarButton() {
        if viewModel.isOnMainTab {
            guard let _ = UserDefaults.standard.value(forKey: USERID) as? String else {return}
            navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"plus")?.withRenderingMode(.alwaysOriginal), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(btnAddNewTripTapped))
        }else {
            switch viewModel.viewMode {
            case .AllTrip:
                if let loggedInUserId = UserDefaults.standard.value(forKey: USERID) as? String,
                    loggedInUserId == viewModel.userId {
                    navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"plus")?.withRenderingMode(.alwaysOriginal), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(btnAddNewTripTapped))
                }
            case .ForPin:
                navigationItem.rightBarButtonItem = UIBarButtonItem(image: UIImage(named:"plus")?.withRenderingMode(.alwaysOriginal), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(btnAddNewTripTapped))
            default: break
            }
        }
    }
    
    private func reload() {
        if didAnimate {
            tblView.reloadData()
        }else {
            didAnimate = true
            animateTable(tableView: tblView)
        }
    }
    
    private func fetchTrendingTrips() {
        spinner(with: "One Moment...")
        viewModel.fetchTrendingTrips(onSuccess: { [weak self] in
            self?.hideSpinner()
            self?.reload()
        }) { [weak self] (error) in
            self?.hideSpinner()
            self?.showAlert(message: error)
        }
    }
    
    private func fetchInvitedTrips() {
        spinner(with: "One Moment...")
        viewModel.fetchInvitedTrips(success: { [weak self] in
            self?.hideSpinner()
            self?.reload()
        }) { [weak self] (error) in
            self?.hideSpinner()
            self?.showAlert(message: error)
        }
    }
    
    @objc func btnInvitesTripTapped() {
        let controller = TripsterListViewController.instantiate(fromAppStoryboard: .tripster)
        let viewModel = TripListViewModel()
        viewModel.userId = self.viewModel.userId
        viewModel.viewMode = .Invited
        viewModel.isOnMainTab = false
        controller.hidesBottomBarWhenPushed = true
        controller.viewModel = viewModel
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc func btnAddNewTripTapped() {
        let controller: NewTripViewController = Router.get()
        let model = NewTripViewModel.init()
        controller.viewModel = model
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func getCurrentTrips() {
        self.spinner(with: "One Moment...", blockInteraction: true)
        viewModel.getCurrentTrips(success: { [weak self] in
            self?.hideSpinner()
            self?.reload()
        }) { [weak self] (error) in
            self?.hideSpinner()
            self?.showAlert(message: error)
        }
    }
    
    func getTripList(inviteCode: String) {
        noTripVC.view.removeFromSuperview()
        noTripVC.removeFromParent()
        addRightBarButton()
        spinner(with: "One Moment...", blockInteraction: true)
        viewModel.getTripList(inviteCode: inviteCode, success: { [weak self] in
            self?.hideSpinner()
            self?.reload()
            if self?.viewModel.tripListResponse.isEmpty == true {
                self?.showNoTripsVC()
            }
        }) { [weak self] (error) in
            self?.hideSpinner()
            self?.showAlert(message: error)
            self?.reload()
        }
    }
    
    func showNoTripsVC() {
        guard let _ = UserDefaults.standard.value(forKey: USERID) as? String else { return }
        navigationItem.rightBarButtonItem = nil
        //        if loggedInUserId == self.userId {
        self.view.addSubview(noTripVC.view)
        self.addChild(noTripVC)
        self.view.addChildViewConstraints(subView: noTripVC.view)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.tripListResponse.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  tableView.dequeue(TripsterListTableViewCell.self, for: indexPath)
        if let trip = viewModel.tripListResponse.item(at: indexPath.row) {
            cell.configure(trip: trip)
            cell.tripSelectMode = [.CurrentTrips, .ForPin].contains(viewModel.viewMode)
            cell.onAddMemoriesTapped = { [weak self] in
                if !Helpers.isLoggedIn() {
                    self?.unauthenticatedBlock(canDismiss: true)
                }
                self?.openCamera()
            }
            cell.onDeleteTapped = { [weak self] in
                self?.deleteTrip(trip: trip)
            }
            cell.onChatTapped = { [weak self] in
                self?.openChat(trip: trip)
            }
            cell.onAddToTripTapped = { [weak self] in
                self?.selected?(trip)
                self?.navigationController?.popViewController(animated: true)
            }
            cell.onCellTapped = { [weak self] in
                guard let self = self else {return}
                self.tableView(self.tblView, didSelectRowAt: indexPath)
            }
            cell.onUserTapped = { [weak self] tripMember in
                let controller: ProfileViewController = Router.get()
                let vModel = ProfileViewModel(userId:  tripMember.userId)
                controller.viewModel = vModel
                controller.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(controller, animated: true)
            }
            cell.onMemoryTapped = { [weak self] memory in
                let controller = FeedDetailVC.instantiate(fromAppStoryboard: .feed)
                controller.feeds = [memory]
                controller.hidesBottomBarWhenPushed = true
                self?.navigationController?.pushViewController(controller, animated: true)
            }
            if viewModel.viewMode == .Invited {
                cell.beFirstToAdd.isHidden = true
                cell.addToTrip.isHidden = true
                cell.chatDeleteStackView.isHidden = true
            }
        }
        return cell
    }
    
    private func openChat(trip: Trip) {
        if !trip.chatGroupId.isEmpty {
            spinner(with: "Loading...", blockInteraction: true)
            viewModel.getGroupById(id: trip.chatGroupId) { [weak self] group in
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
    
    private func deleteTrip(trip: Trip) {
        let controller = UIAlertController(title: nil, message: "Are you sure, you want to delete this trip?", preferredStyle: Helpers.actionSheetStyle())
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (_) in
            self.spinner(with: "Deleting Trip...", blockInteraction: true)
            self.viewModel.deleteTrip(trip: trip, success: { [weak self] (index) in
                self?.hideSpinner()
                let index = IndexPath(row: index, section: 0)
                self?.tblView.deleteRows(at: [index], with: .fade)
                }, failure: { [weak self] (error) in
                    self?.hideSpinner()
                    self?.showAlert(message: error)
            })
        }
        
        controller.addAction(cancel)
        controller.addAction(delete)
        
        present(controller, animated: true, completion: nil)
        
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let cell = tableView.cellForRow(at: indexPath)
        cell?.setSelected(false, animated: true)
        if let trip = viewModel.tripListResponse.item(at: indexPath.row) {
            switch viewModel.viewMode {
            case .AllTrip, .Public:
                let model = TripsterDetailViewModel(trip: trip)
                let controller: TripDetailViewController = Router.get()
                controller.viewModel = model
                controller.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(controller, animated: true)
            case .Invited:
                let controller = TripInvitationVC.instantiate(fromAppStoryboard: .tripster)
                controller.trips = [trip]
                controller.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(controller, animated: true)
            case .CurrentTrips, .ForPin:
                self.selected?(trip)
                self.navigationController?.popViewController(animated: true)
            }
        }
    }
    
}
