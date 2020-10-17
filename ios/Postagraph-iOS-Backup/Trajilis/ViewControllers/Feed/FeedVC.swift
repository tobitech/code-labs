//
//  GenericVideoTableViewController.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import AVKit
import Social
import FacebookShare
import FBSDKShareKit
import JPVideoPlayer
import MobileCoreServices
import AVKit
import SDWebImage

final class FeedVC: BaseVC {
    
    var viewModel: FeedViewModel!
    var playingCell: FeedTableViewCell?
    var ratingCompletion:((Double) -> ())?
    var loadedPlace:((Place) -> ())?
    
    @IBOutlet weak var tapAndHoldLabel: UILabel!
    @IBOutlet weak var tapAndHoldIcon: UIImageView!
    @IBOutlet weak var tapAndHoldView: UIView!
    @IBOutlet weak var tableView: UITableView!
    
    var tripsterBlock:(() -> ())?
    var noTripsBlock:(() -> ())?
    var viewedFeeds = [String]()
    var placesBlock:(() -> ())?
    var followersBlock:(() -> ())?
    var followingBlock:(() -> ())?
    var showFullImage:((URL?) -> ())?
    var showHud:Bool = true
    var isVisible = false
    var fullScreenMode = false
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(FeedTableViewCell.Nib, forCellReuseIdentifier: FeedTableViewCell.identifier)
        if let feeds = self.getViewedFeedsLocally(), !feeds.isEmpty {
            viewedFeeds.append(contentsOf: feeds)
        }
        
        if Network.reachability?.status != .unreachable {
            if(showHud) {
                MBProgressHUD.showCustomHud(to: view, animated: true,minSize: true)
            }
        }
        viewModel.reload = { [weak self] in
            DispatchQueue.main.async {
                guard let strongSelf = self else { return }
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                UIView.performWithoutAnimation {
                    self?.tableView.reloadData()
                }
            }
        }
        
        viewModel.spamReport = {
            self.showAlert(message: "Post has been Reported.")
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
        
        viewModel.loadedPlace = { place in
            DispatchQueue.main.async {
                self.loadedPlace?(place)
            }
        }
        
        tableView.tableFooterView = UIView(frame: .zero)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeed), name: UIApplication.didBecomeActiveNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(updateFeed), name: Constants.NotificationName.Reload, object: nil)
        
        showInstructions()
        switch viewModel.type {
        case .withFeeds:
            tableView.scrollToRow(at: IndexPath(row: viewModel.selectedFeedIndex, section: 0), at: .top, animated: false)
        default: break
        }
    }
    
    @objc private func optionsTapped(_ sender: UILongPressGestureRecognizer) {
        if sender.state == .began {
            UserDefaults.standard.setValue(true, forKey: "TapAndHoldOnFeed")
            tapAndHoldView.isHidden = true
            if let indexPath = tableView.indexPathForRow(at: CGPoint(x: 20, y: tableView.contentOffset.y + 20)) {
                let feed = viewModel.feeds[indexPath.row]
                showMoreOptions(feed: feed)
            }
        }
    }
    
    @objc private func tappedOnInstruction() {
        UserDefaults.standard.setValue(true, forKey: "TapOnFeed")
        tapAndHoldView.isHidden = true
        if let indexPath = tableView.indexPathForRow(at: CGPoint(x: 20, y: tableView.contentOffset.y + 20)) {
            self.tableView(tableView, didSelectRowAt: indexPath)
        }
    }
    
    private func showInstructions() {
        if !UserDefaults.standard.bool(forKey: "TapOnFeed") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnInstruction))
                self.tapAndHoldView.addGestureRecognizer(tapGesture)
                self.tapAndHoldView.isHidden = false
                self.tapAndHoldIcon.image = UIImage(named: "tapIcon")
                self.tapAndHoldLabel.text = "Tap the screen to view the post fullscreen."
            })
        }else if !UserDefaults.standard.bool(forKey: "TapAndHoldOnFeed") {
            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
                let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.optionsTapped(_:)))
                self.tapAndHoldView.addGestureRecognizer(longPressGesture)
                self.tapAndHoldView.isHidden = false
                self.tapAndHoldIcon.image = UIImage(named: "tapAndHoldIcon")
                self.tapAndHoldLabel.text = "Tap and hold the screen to bring up additional options."
                DispatchQueue.main.asyncAfter(deadline: .now() + 20, execute: {
                    self.showInstructions()
                })
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        isVisible = true
        hideNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if let cell = playingCell {
            cell.videoView?.jp_resume()
        }
        tableView.reloadData()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        isVisible = false
        if let cell = playingCell {
            cell.videoView?.jp_stopPlay()
        }
        NotificationCenter.default.post(name: NSNotification.Name.fullScreenMode, object: false)
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    @objc func updateFeed() {
        viewModel.currentPage = 0
        viewModel.fetchRemoteFeeds()
    }
    
    func getViewedFeedsLocally() -> [String]? {
        do {
            let data = try DataStorage.shared.dataStorage.object(forKey: "D_VIEWED_FEEDS")
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [String]
            {
                return jsonArray
            } else {
                print("bad json")
            }
        } catch {
            print(error)
        }
        
        return nil
    }
}


extension FeedVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count = viewModel.feeds.count
        switch viewModel.type {
        case .profile:
            if viewModel.user == nil { return 0 }
            count += 1
        default:
            break
        }
        return count
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            if tableView.visibleCells.contains(cell) {
                if tableView.visibleCells.contains(cell) && self.isVisible {
                    if (indexPath.row > self.viewModel.feeds.count - 3) && !self.viewModel.isLastContent {
                        self.viewModel.loadMore()
                    }
//                    if let feedCell = cell as? FeedTableViewCell {
//                        self.setupVideoFor(cell: feedCell)
//                    }
                }
            }
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        let visibleRect = CGRect(origin: scrollView.contentOffset, size: scrollView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        if let visibleIndexPath = tableView.indexPathForRow(at: visiblePoint),
            let cell = tableView.cellForRow(at: visibleIndexPath) as? FeedTableViewCell {
            setupVideoFor(cell: cell)
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FeedTableViewCell") as! FeedTableViewCell
        var feed: Feed!
        
        switch viewModel.type {
        case .profile: break
        default:
            feed = viewModel.feeds[indexPath.row]
            configure(cell: cell, feed: feed)
        }
        return cell
    }
    
    
    private func showActionSheet() {
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let video = UIAlertAction(title: "Video Upload", style: .default) { (_) in
            let controller = CameraVC.instantiate(fromAppStoryboard: .video)
            controller.recordType = .profile
            controller.didFinishRecording = { [weak self] (videoURL, coverImage) in
                self?.uploadProfileVideoImage(profileVideoCoverImage: coverImage, profileVideo: videoURL)
                //                self?.profileVideo = videoURL
                //                self?.profileVideoCoverImage = coverImage
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.isNavigationBarHidden = true
            self.present(navController, animated: true, completion: nil)
        }
        
        let library = UIAlertAction(title: "Video Library", style: .default) { (_) in
            self.openCamera()
        }
        
        controller.addAction(video)
        controller.addAction(library)
        
        
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)
    }
    
    private func openCamera() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String]
        present(imagePicker, animated: true, completion: nil)
    }
    
    
    private func configure(cell: FeedTableViewCell, feed: Feed) {
        cell.configure(with: feed, hideViews: fullScreenMode)
        
        cell.addFeaturedBlock = {
            self.makeFeatured(feed: feed)
        }
        
        cell.optionBlock = {
            self.showMoreOptions(feed: feed)
        }
        
        cell.commentBlock = {
            self.comment(feed: feed)
        }
        
        cell.pinBlock = {
            self.goForPINFeed(feed: feed)
        }
        
        cell.likeBlock = {
            self.like(feed: feed)
            cell.configure(with: feed, hideViews: self.fullScreenMode)
        }
        
        cell.likeCountBlock = {
            self.showFeedLikers(feed: feed)
        }
        
        cell.pinCountBlock = {
            self.showFeedPinners(feed: feed)
        }
        
        cell.viewCountBlock = {
            self.showFeedViewers(feed: feed)
        }
        
        cell.loadVideo = { [weak cell] in
            if let cell = cell {
                self.setupVideoFor(cell: cell)
            }
        }
        if self.viewedFeeds.contains(feed.id) {
            //            cell.feedViewersButton.backgroundColor = UIColor.appRed.withAlphaComponent(0.4)
        } else {
            //            cell.feedViewersButton.backgroundColor = UIColor.black.withAlphaComponent(0.2)
        }
        
        cell.profileBlock = {
            self.profileTapped(userId: feed.userId)
        }
        
        cell.placeBlock = {
            self.placeTapped(feed: feed)
        }
        
        cell.hashtagBlock = { (tag,cell) in
            self.handleHash(tag: tag)
        }
        
        cell.mentionBlock = { mention in
            for u in feed.taggedUsers {
                if u.username == mention {
                    self.profileTapped(userId: u.userId)
                }
            }
        }
    }
    
    private func setupVideoFor(cell: FeedTableViewCell) {
        playingCell?.videoView?.jp_stopPlay()
        playingCell = cell
        if let url = URL(string: cell.videoURLString) {
            playingCell?.videoView?.jp_videoPlayerDelegate = self
            kAppDelegate.setupSound(isPrimary: fullScreenMode)
            if fullScreenMode {
                playingCell?.videoView?.jp_playVideo(with: url, bufferingIndicator: JPVideoPlayerBufferingIndicator(), controlView: nil, progressView: nil){ (v, model) in
                    model.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                }
                playingCell?.videoView?.jp_muted = false
            }else {
                playingCell?.videoView?.jp_playVideoMute(with: url, bufferingIndicator: JPVideoPlayerBufferingIndicator(), progressView: nil, configuration: { (v, model) in
                    model.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                })
            }
        }
    }
    
    func markFeedViewed(feedId:String?) {
        guard let feedId = feedId else {
            return
        }
        viewModel.markFeedViewed(feedId: feedId) { [weak self] in
            guard let strngSelf = self else {return }
            strngSelf.saveViewwedFeedLocally(feedId: feedId)
            strngSelf.addViewCount(feedId:feedId)
        }
    }
    
    func saveViewwedFeedLocally(feedId:String) {
        
        self.viewedFeeds.append(feedId)
        if self.viewedFeeds.count > 0 {
            do {
                let jsond = try JSONSerialization.data(withJSONObject:self.viewedFeeds, options: [])
                try DataStorage.shared.dataStorage.setObject(jsond, forKey:"D_VIEWED_FEEDS")
            } catch {
                print(error)
            }
        }
    }
    func addViewCount(feedId:String) {
        let feedById = self.viewModel.feeds.filter { (fed) -> Bool in
            if fed.id == feedId {
                return true
            }
            return false
        }
        
        if let feed = feedById.first {
            feed.viewcount = feed.viewcount + 1
        }
        if let cell = self.tableView.visibleCells.first, let indexPath = self.tableView.indexPath(for: cell) {
            self.tableView.reloadRows(at: [indexPath], with: .none)
        }
    }
    
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.hash == playingCell?.hash {
            playingCell?.jp_stopPlay()
            playingCell = nil
        }
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UIScreen.main.bounds.height
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        fullScreenMode = !fullScreenMode
        kAppDelegate.setupSound(isPrimary: fullScreenMode)
        playingCell?.videoView?.jp_muted = !fullScreenMode
        playingCell?.changeMode(hideViews: fullScreenMode)
        
        if fullScreenMode {
            markFeedViewed(feedId: playingCell?.feedId)
        }
        
        NotificationCenter.default.post(name: NSNotification.Name.fullScreenMode, object: fullScreenMode)
    }
}

//Mark:- Profile Actions
extension FeedVC {
    
    private func follow(user: User, status: String) {
        if status == "false" {
            let alertController = UIAlertController(title: "Postagraph", message: "Are you sure you want to unfollow \(user.firstname)", preferredStyle: .alert)
            let continueButton = UIAlertAction(title: "Continue", style: .default) { (_) in
                self.viewModel.follow(followerId: Helpers.userId, followingId: user.id, status: status)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(continueButton)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        } else {
            viewModel.follow(followerId: Helpers.userId, followingId: user.id, status: status)
        }
    }
    
    private func like(user: User, status: String) {
        viewModel.likeProfile(userId: user.id, status: status)
    }
    
    private func showProfileOptions(user: User) {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        if user.id == Helpers.userId {
            
            let edit = UIAlertAction(title: "Edit Profile", style: .default) { (_) in
                //TODO Editing
                let controller = SettingsViewController.instantiate(fromAppStoryboard: .settings)
                self.navigationController?.pushViewController(controller, animated: true)
                
            }
            controller.addAction(edit)
        } else {
            let block = UIAlertAction(title: "Block \(user.firstname)", style: .default) { (_) in
                self.blockUser(userId: user.id)
                self.navigationController?.popViewController(animated: true)
                NotificationCenter.default.post(name: Constants.NotificationName.Reload, object: nil)
            }
            let spam = UIAlertAction(title: "Report User", style: .default) { (_) in
                self.viewModel.report(user: user)
            }
            //controller.addAction(message)
            controller.addAction(block)
            controller.addAction(spam)
        }
        
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)
    }
    
    private func blockUser(userId: String) {
        MBProgressHUD.showCustomHud(to: view, animated: true,minSize: true)
        viewModel.blockUser(userId: userId) {
            
        }
    }
    private func uploadVideo(user:User) {
        let controller = CameraVC.instantiate(fromAppStoryboard: .video)
        controller.recordType = .profile
        controller.didFinishRecording = { [weak self] (videoURL, coverImage) in
            self?.uploadProfileVideoImage(profileVideoCoverImage: coverImage, profileVideo: videoURL)
        }
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        self.present(navController, animated: true, completion: nil)
    }
    
    private func uploadProfileVideoImage(profileVideoCoverImage:UIImage?,profileVideo:URL?) {
        guard let img = profileVideoCoverImage, profileVideo != nil else {
            return
        }
        self.spinner(with: "Uploading...", blockInteraction: true)
        Helpers.uploadToS3(image: img) { (s3URL, error) in
            DispatchQueue.main.async {
                self.uploadVideo(profileVideo:profileVideo,completion: { (videoURL) in
                    if let url = videoURL {
                        self.viewModel.uploadProfileVideo(videoUrl: url, videoThumbnailUrl: s3URL, completion: { [weak self] in
                            self?.hideSpinner()
                            self?.navigationController?.popViewController(animated: true)
                        })
                    }
                })
            }
        }
    }
    private func uploadVideo(profileVideo:URL?,completion: @escaping ((String?) ->())) {
        guard let urlString = profileVideo else {
            completion(nil)
            return
        }
        do {
            let data = try Data.init(contentsOf: urlString)
            Helpers.uploadVideoToS3(data: data) { (s3URL, error) in
                DispatchQueue.main.async {
                    completion(s3URL)
                }
            }
        } catch {
            completion(nil)
            showAlert(message: "Video upload failed.")
            print(error)
        }
    }
    private func goToChat(user:User) {
        guard let currentUser = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
        self.spinner(with: "", blockInteraction: true)
        ChatViewController.createGroup(withUser: user.condensedUser) { [weak self] (chatContact) in
            if let strngSelf = self {
                strngSelf.hideSpinner()
                if let grp = chatContact {
                    let controller = ChatViewController.instantiate(fromAppStoryboard: .message)
                    controller.chatContact = grp
                    controller.currentUser = currentUser.condensedUser
                    controller.hidesBottomBarWhenPushed = true
                    strngSelf.navigationController?.pushViewController(controller, animated: true)
                    
                } else {
                    strngSelf.showAlert(message: "App is unable to process request.")
                }
            }
        }
    }
}

//Mark:- Feed Actions
extension FeedVC {
    private func shareImage(feed: Feed) {
        guard let url = URL.init(string: feed.imageURL) else { return }
        
        MBProgressHUD.showCustomHud(to: view, animated: true,minSize: true)
        Helpers.retrieveImage(imageURL: url) { (image) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                if let instagramURL = URL(string: "instagram://app") {
                    if UIApplication.shared.canOpenURL(instagramURL) {
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let saveImagePath = (documentsPath as NSString).appendingPathComponent("Image.igo")
                        let imageData = image!.pngData()
                        do {
                            let urlfile = URL(fileURLWithPath: saveImagePath)
                            try imageData?.write(to: urlfile)
                            
                        } catch {
                            print("Instagram sharing error")
                        }
                        let imageURL = URL(fileURLWithPath: saveImagePath)
                        let documentInteractionController = UIDocumentInteractionController(url: imageURL)
                        documentInteractionController.uti = "com.instagram.exclusivegram"
                        let bounds = self.tableView.bounds
                        if !documentInteractionController.presentOpenInMenu(from: bounds, in: self.view, animated: true) {
                            print("Instagram not found")
                        }
                    } else {
                        print("Instagram not found")
                    }
                }
                else {
                    print("Instagram not found")
                }
            }
        }
    }
    
    
    private func shareVideo(feed: Feed) {
        if Utility.canShareOnInsta() {
            MBProgressHUD.showCustomHud(to: view, animated: true,minSize: true)
            
            Helpers.downloadVideo(feed: feed) { (fileAsset) in
                DispatchQueue.main.async {
                    if let asset = fileAsset {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        Utility.share(onInsta:asset.videoURL.absoluteString)
                    } else {
                        MBProgressHUD.hide(for: self.view, animated: true)
                        self.showAlert(message: kDefaultError)
                    }
                }
            }
        } else {
            self.showAlert(message: "Please install instagram app to share on instagram.")
        }
        
    }
    
    private func showMoreOptions(feed: Feed) {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let share = UIAlertAction(title: "Share post on Instagram", style: .default) { (_) in
            if feed.feedType == "video" {
                self.shareVideo(feed: feed)
            } else {
                self.shareImage(feed: feed)
            }
        }
        if user.id == feed.userId {
            let delete = UIAlertAction(title: "Delete Post", style: .default) { (_) in
                
                self.deleteConfirmation(feed: feed)
            }
            let edit = UIAlertAction(title: "Edit Description", style: .default) { (_) in
                self.editFeed(feed: feed)
            }
            let editPrivacy = UIAlertAction(title: "Change Privacy", style: .default) { (_) in
                self.editPrivacy(feed: feed)
            }
            let download = UIAlertAction(title: "Download", style: .default) { (_) in
                self.downloadFeed(feed: feed)
            }
            controller.addAction(delete)
            controller.addAction(edit)
            controller.addAction(editPrivacy)
            controller.addAction(download)
            
            
        } else {
            let spam = UIAlertAction(title: "Report Post", style: .default) { (_) in
                self.viewModel.report(feed: feed, completion: {[weak self] (msg) in
                    self?.showAlert(message: msg)
                })
            }
            let hide = UIAlertAction(title: "Hide Post", style: .default) { (_) in
                self.hide(feed: feed)
            }
            
            controller.addAction(hide)
            controller.addAction(spam)
        }
        
        if user.id == feed.userId {
            controller.addAction(share)
        }
        
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)
    }
    
    private func makeFeatured(feed: Feed) {
        guard kAppDelegate.user?.registrationType == "admin" else {return}
        let controller = UIAlertController(title: nil, message: "Do you want to make this a featured post?", preferredStyle: .alert)
        let no = UIAlertAction(title: "No", style: .default, handler: nil)
        
        let yes = UIAlertAction(title: "Yes", style: .default) { (_) in
            self.repostFeedOnPosta(feed: feed)
        }
        controller.addAction(yes)
        controller.addAction(no)
        present(controller, animated: true, completion: nil)
    }
    
    private func deleteConfirmation(feed: Feed) {
        
        let controller = UIAlertController(title: nil, message: "Are you sure, you want to delete this post?", preferredStyle: Helpers.actionSheetStyle())
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let delete = UIAlertAction(title: "Delete", style: .default) { (_) in
            self.delete(feed: feed)
        }
        controller.addAction(delete)
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)
    }
    private func comment(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        let controller = CommentVC.instantiate(fromAppStoryboard: .comment)
        controller.title = "Comments"
        let model = CommentViewModel(feedId: feed.id, commentCount: Int(feed.commentCount) ?? 0, isOwner: feed.userId == Helpers.userId)
        controller.viewModel = model
        controller.onDone = { [weak self] in
            self?.navigationController?.dim(.out, speed: 0)
            feed.commentCount = "\(model.commentCount)"
            self?.playingCell?.videoView?.jp_resume()
            self?.tableView.reloadData()
        }
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = .overFullScreen
        controller.providesPresentationContextTransitionStyle = true
        navigationController?.dim(.in, color: UIColor.black, alpha: 0.3, speed: 0.5)
        navigationController?.present(controller, animated: true, completion: nil)
    }
    
    private func like(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        guard var count = Int(feed.likeCount) else { return }
        if feed.likeStatus == "false" {
            feed.likeStatus = "true"
            count += 1
        } else {
            feed.likeStatus = "false"
            count -= 1
        }
        feed.likeCount = "\(count)"
        viewModel.like(feed: feed)
    }
    private func showFeedViewers(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        let controller = FollowViewController.instantiate(fromAppStoryboard: .follow)
        let model = FollowViewModel(type: .feedViewers(feedId: feed.id))
        controller.viewModel = model
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func showFeedLikers(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        let controller = FollowViewController.instantiate(fromAppStoryboard: .follow)
        let model = FollowViewModel(type: .likers(feedId: feed.id))
        controller.viewModel = model
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func showFeedPinners(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        let controller = FollowViewController.instantiate(fromAppStoryboard: .follow)
        let model = FollowViewModel(type: .pins(feedId: feed.id))
        controller.viewModel = model
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func repostFeedOnPosta(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        viewModel.repostToPosta(feed: feed, completion: { [weak self] (error) in
            if let error = error {
                self?.showAlert(message: error)
            }
        })
    }
    
    private func goForPINFeed(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        let controller = TripsterListViewController.instantiate(fromAppStoryboard: .tripster)
        let viewModel = TripListViewModel()
        viewModel.viewMode = .ForPin
        viewModel.userId = Helpers.userId
        controller.selected = { [weak self] trip in
            self?.spinner(with: "Pinning", blockInteraction: true)
            self?.viewModel.pin(feed: feed, toTrip: trip) {
                guard let self = self else {return}
                DispatchQueue.main.async {
                    self.playingCell?.configure(with: feed, hideViews: self.fullScreenMode)
                    self.hideSpinner()
                    self.showAlert(title: "Post pinned successfully.", message: "")
                }
            }
        }
        viewModel.isOnMainTab = false
        controller.viewModel = viewModel
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func hide(feed: Feed) {
        viewModel.hide(feed: feed)
    }
    
    private func editFeed(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        let controller = EditFeedDescriptionVC.instantiate(fromAppStoryboard: .video)
        controller.selectedFeed = feed
        controller.hidesBottomBarWhenPushed = true
        //        self.navigationController?.present(controller, animated: true, completion: nil)
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func editPrivacy(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        let controller = EditPrivacyVC.instantiate(fromAppStoryboard: .video)
        controller.feed = feed
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
    private func downloadFeed(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        
        MBProgressHUD.showCustomHud(to: view, animated: true,minSize: true)
        Helpers.downloadVideoForUser(feed: feed) { (success) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                if success {
                    self.showAlert(message: "Post video saved in phone library.")
                } else {
                    self.showAlert(message: kDefaultError)
                }
            }
        }
    }
    
    private func delete(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        MBProgressHUD.showCustomHud(to: view, animated: true,minSize: true)
        viewModel.delete(feed: feed) { (message) in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let msg = message {
                self.showAlert(message: msg)
            } else {
                self.tableView.reloadData()
            }
        }
    }
    
    private func profileTapped(userId: String) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        let controller: ProfileViewController = Router.get()
        let vModel = ProfileViewModel(userId: userId)
        controller.viewModel = vModel
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
}

//Places
extension FeedVC {
    private func placeTapped(feed: Feed) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        switch viewModel.type {
        case .places:
            break
        default:
            let controller = PlacesVC.instantiate(fromAppStoryboard: .places)
            controller.viewModel = FeedViewModel(type: .places(id: feed.placeId))
            controller.location = feed.feedLocation
            controller.address = feed.address
            controller.rating = Double(feed.rating) ?? 0
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
}

extension FeedVC {
    private func handleHash(tag: String) {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        switch viewModel.type {
        case .hash(let currentTag):
            if tag == currentTag { return }
        default:
            break
        }
        let controller = HashTagFeedVC.instantiate(fromAppStoryboard: .places)
        controller.hashTag = tag
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
        
    }
}

extension FeedVC: JPVideoPlayerDelegate {
    func shouldShowDefaultControlAndIndicatorViews() -> Bool {
        return false
    }
    func shouldShowBlackBackgroundWhenPlaybackStart() -> Bool {
        return false
    }
}

extension FeedVC: UIImagePickerControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let videoUrl = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            let asset = AVAsset(url: videoUrl)
            if asset.duration.seconds > 7 {
                showAlert(message: "Video must be less or equal to 6 seconds long.")
                return
            }
            
            let thumbnail = getThumbnail(asset: asset)
            uploadProfileVideoImage(profileVideoCoverImage: thumbnail, profileVideo: videoUrl)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    private func getThumbnail(asset: AVAsset) -> UIImage? {
        
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        
        var time = asset.duration
        time.value = min(time.value, 2)
        
        do {
            let imageRef = try assetImageGenerator.copyCGImage(at: time, actualTime: nil)
            let thumbNail = UIImage.init(cgImage: imageRef)
            
            return thumbNail
            
        } catch {
            return nil
        }
    }
    
}
