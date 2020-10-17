//
//  TerminalVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import AVKit
import Social
import FacebookShare
import FBSDKShareKit
import CoreLocation
import Hakawai

extension Notification.Name {
    static let fullScreenMode = Notification.Name("FullScreenModeToggle")
}

final class TerminalVC: BaseVC {
    
    @IBOutlet var profileImageButton: UIButton!
    @IBOutlet var sideMenuButton: UIButton!
    @IBOutlet var badgeButton: SSBadgeButton!
    @IBOutlet var msgButton: SSBadgeButton!
    @IBOutlet weak var uploadProgressView: UIView!
    
    let progressUploadView = VideoProgressView.fromNib()
    
    let videoViewModel = VideoViewModel()
    let viewModel = TerminalViewModel()
    var container = UIView()
    var feedController: FeedVC?

    let messageVC = MessagesVC.instantiate(fromAppStoryboard: .message)

    let maxBlackViewAlpha: CGFloat = 0.5
    let animationDuration: TimeInterval = 0.3
    var isLeftToRight = true

    override func viewDidLoad() {
        super.viewDidLoad()
        
        profileImageButton.rounded()
        profileImageButton.set(borderWidth: 1, of: .white)
        sideMenuButton.rounded()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        badgeButton.badgeBackgroundColor = .red
//        badgeButton.setImage(UIImage(named: "push_notif")?.withRenderingMode(.alwaysTemplate), for: .normal)
        badgeButton.badgeEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 10)
        msgButton.badgeEdgeInsets = UIEdgeInsets(top: 12, left: 0, bottom: 0, right: 10)
        
        
        msgButton.badgeBackgroundColor = .red
//        msgButton.setImage(UIImage(named: "msgIcon")?.withRenderingMode(.alwaysOriginal), for: .normal)
//        msgButton.badgeEdgeInsets = UIEdgeInsets(top: 15, left: 0, bottom: 0, right: 5)
        
        viewModel.updateNotification = { count in
            self.badgeButton.badge = count
        }
        
        viewModel.updateMessageCount = { count in
            DispatchQueue.main.async {
                if let navVC = self.tabBarController?.viewControllers?[kTabIndex.Terminal.rawValue] as? UINavigationController ,let trmVC = navVC.viewControllers.first as? TerminalVC {
                    if let cnt = count,!cnt.isEmpty {
                        trmVC.msgButton.badge = "\(cnt)"
                    } else {
                        trmVC.msgButton.badge = nil
                    }
                }
            }
        }
        
        videoViewModel.uploadContentComplete = { msg in
            self.uploadProgressView.isHidden = true
            if let msg = msg {
                self.showAlert(message: msg)
            }else {
                NotificationCenter.default.post(name: Constants.NotificationName.Reload, object: nil)
            }
        }
        setContainerFrame()
        setupTableChildView()

        //sideMenuButton.isHidden = !Helpers.isLoggedIn()
        badgeButton.isHidden = !Helpers.isLoggedIn()
        msgButton.isHidden = !Helpers.isLoggedIn()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handlePostContent(notification:)), name: NSNotification.Name.postContent, object: nil)
        
        uploadProgressView.isHidden = true
        uploadProgressView.addSubview(progressUploadView)
        progressUploadView.fill()
        progressUploadView.closeBtn.addTarget(self, action: #selector(handleCloseTap), for: .touchUpInside)
    }
    
    @objc private func fullScreenMode( _ notification: Notification) {
        if let fullScreenMode = notification.object as? Bool {
            [sideMenuButton, badgeButton, msgButton, profileImageButton].forEach{$0.isHidden = fullScreenMode}
            self.tabBarController?.tabBar.isHidden = fullScreenMode
        }
    }
    
    @objc func handleCloseTap() {
       uploadProgressView.isHidden = true
    }
    
    @objc func handlePostContent(notification: NSNotification) {
        let coordinates = notification.userInfo?["coordinates"] as? CLLocationCoordinate2D?
        let coverImages = notification.userInfo?["coverImages"] as? [UIImage]
        let postType = notification.userInfo?["postType"] as? String
        let rating = notification.userInfo?["rating"] as? Int
        let taggedUsers = notification.userInfo?["taggedUsers"] as? String
        let tags = notification.userInfo?["tags"] as? String
        let videoURLs = notification.userInfo?["videoURLs"] as? [URL]
        let description = notification.userInfo?["description"] as? String
        let selectedVenue = notification.userInfo?["selectedVenue"] as? Venue
        let trip = notification.userInfo?["trip"]  as? Trip
        let plugin = notification.userInfo?["plugin"]  as? HKWMentionsPlugin
        
        
        videoViewModel.coordinates = coordinates ?? nil
        videoViewModel.coverImages = coverImages
        videoViewModel.postType = postType ?? ""
        videoViewModel.rating = rating
        videoViewModel.taggedUsers = taggedUsers
        videoViewModel.tags = tags
        videoViewModel.videoURLs = videoURLs
        videoViewModel.trip = trip
        videoViewModel.plugin = plugin
        videoViewModel.selectedVenue = selectedVenue
        videoViewModel.description = description
        print("videoURL \(videoURLs!)")
        uploadProgressView.isHidden = false
        progressUploadView.imgView.image = coverImages?.first
        //viewModel.getUnreadMessageCount()
        videoViewModel.uploadVideo(videoUrls: videoURLs!, progressView: progressUploadView.progressbar) { (fileName, fileExtension, s3URL) in
            if let videoURL = s3URL,
                let fileName = fileName,
                let fileExtension = fileExtension {
                self.videoViewModel.uploadCoverImage(completion: { (coverImageURL) in
                    DispatchQueue.main.async {
                        self.videoViewModel.postContent(venue: self.videoViewModel.selectedVenue!, videoName: fileName, videoExtension: fileExtension, videoURL: videoURL, coverImageURL: coverImageURL ?? "", desc: self.videoViewModel.description ?? "")
                    }
                })
            } else {
                DispatchQueue.main.async {
                    self.hideSpinner()
                    self.showAlert(message: "Video upload failed. But, videos are saved locally, you can upload them at your convinience.")
                }
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        self.messageVC.viewModel.refresh()
        self.viewModel.refreshData()
        self.tabBarController?.tabBar.backgroundColor = UIColor.clear
        
        let avatar = UIImage(named: "userAvatar")
        profileImageButton.setImage(avatar, for: .normal)
        if let image = try? kAppDelegate.user?.profileImageThumb.asURL() ?? nil {
            profileImageButton.sd_setImage(with: image, for: .normal, placeholderImage: avatar)
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.fullScreenMode(_:)), name: .fullScreenMode, object: nil)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: .fullScreenMode, object: nil)
    }

    private func setContainerFrame() {
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.insertSubview(container, belowSubview: profileImageButton)
    }
    
    private func setupTableChildView() {
        feedController = FeedVC.instantiate(fromAppStoryboard: .feed)
        let vModel = FeedViewModel(type: .terminal)
        feedController?.viewModel = vModel
        addChild(feedController!)
        container.addSubview(feedController!.view)
        feedController!.view.fill()
        feedController!.didMove(toParent: self)
    }

    func scrolToTop() {
        feedController?.tableView.setContentOffset(CGPoint.zero, animated: true)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    @IBAction func btnMsgTapped(_ sender: Any?) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        
        let controller = messageVC
        
        controller.onCreateGroup = { [weak self] in
            self?.dim(.out, speed: 0)
            self?.viewModel.getUnreadMessageCount()
            let controller = CreateGroupViewController.instantiate(fromAppStoryboard: .message)
            controller.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        controller.onDismiss = { [weak self] in
            self?.dim(.out, speed: 0)
            self?.viewModel.getUnreadMessageCount()
        }
        controller.onOpenChat = { [weak self] (contact, user) in
            self?.dim(.out, speed: 0)
            self?.viewModel.getUnreadMessageCount()
            let controller = ChatViewController.instantiate(fromAppStoryboard: .message)
            controller.chatContact = contact
            controller.currentUser = user
            controller.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = .overFullScreen
        controller.providesPresentationContextTransitionStyle = true
        dim(.in, color: UIColor.black, alpha: 0.3, speed: 0.5)
        navigationController?.present(controller, animated: true, completion: nil)
//
//        self.messageVC.hidesBottomBarWhenPushed = true
//        self.navigationController?.pushViewController(self.messageVC, animated: true)
    }
    
    func showMessageVCWithGroupId(grpId:String) {
        self.messageVC.isFromChatNotification = true
        self.messageVC.notificationGroupId = grpId
        btnMsgTapped(nil)
    }
    
    @IBAction func notificationTapped(_ sender: Any) {
        badgeButton.badge = nil
        let controller = NotificationVC.instantiate(fromAppStoryboard: .notification)
        controller.onDismiss = { [weak self] in
            self?.dim(.out, speed: 0)
        }
        controller.onOpenMessage = {[weak self] in
            guard let self = self else {return}
            self.dim(.out, speed: 0)
            self.btnMsgTapped(self.msgButton)
        }
        controller.onOpenComment = { [weak self] feedID, commentID in
            let controller = CommentVC.instantiate(fromAppStoryboard: .comment)
            let model = CommentViewModel(feedId: feedID, commentCount: 0, isOwner: false)
            model.commentIDToPreload = commentID
            controller.viewModel = model
            controller.onDone = {
                self?.dim(.out, speed: 0)
            }
            controller.definesPresentationContext = true
            controller.modalPresentationStyle = .overFullScreen
            controller.providesPresentationContextTransitionStyle = true
            self?.navigationController?.present(controller, animated: true, completion: nil)
        }
        controller.onOpenFeed = { [weak self] feedID in
            self?.dim(.out, speed: 0)
            let controller = FeedDetailVC.instantiate(fromAppStoryboard: .feed)
            controller.feedId = feedID
            controller.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        controller.onOpenProfile = { [weak self] userId in
            self?.dim(.out, speed: 0)
            let controller: ProfileViewController = Router.get()
            let viewModel = ProfileViewModel(userId: userId)
            controller.viewModel = viewModel
            controller.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        controller.onOpenInvitedTrip = { [weak self] in
            self?.dim(.out, speed: 0)
            let controller = TripsterListViewController.instantiate(fromAppStoryboard: .tripster)
            let viewModel = TripListViewModel()
            viewModel.viewMode = .Invited
            viewModel.isOnMainTab = false
            controller.hidesBottomBarWhenPushed = true
            controller.viewModel = viewModel
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        controller.onOpenTripster = { [weak self] in
            self?.dim(.out, speed: 0)
            kAppDelegate.mainTabbar?.selectedIndex = kTabIndex.Tripster.rawValue
        }
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = .overFullScreen
        controller.providesPresentationContextTransitionStyle = true
        dim(.in, color: UIColor.black, alpha: 0.3, speed: 0.5)
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    @IBAction func sideMenuTapped(_ sender: Any) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        let controller: ProfileViewController = Router.get()
        let vModel = ProfileViewModel(userId: id)
        controller.viewModel = vModel
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}
