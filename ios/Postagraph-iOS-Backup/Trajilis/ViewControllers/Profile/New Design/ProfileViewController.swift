//
//  ProfileViewController.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/27/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SDWebImage
import JPVideoPlayer
import AVKit
import MobileCoreServices

class ProfileViewController: BaseVC {
    
    var viewModel: ProfileViewModel!
    
    private weak var headerView: ProfileHeaderCollectionReusableView? {
        didSet {
            if oldValue != headerView {
                oldValue?.videoView.jp_stopPlay()
            }
            
            if let url = (try? viewModel?.user?.profileVideo.asURL()) ?? nil {
                headerView?.videoView.jp_videoPlayerDelegate = self
                headerView?.videoView.jp_playVideoMute(with: url, bufferingIndicator: JPVideoPlayerBufferingIndicator(), progressView: nil, configuration: { (v, model) in
                    model.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                })
            }else {
                headerView?.videoView.jp_stopPlay()
            }
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var settingsButton: UIButton!
    @IBOutlet weak var titleLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        settingsButton.setImage(viewModel.isCurrentUser ? UIImage(named: "settings") : UIImage(named: "more-horizontal"), for: .normal)
        viewModel.reload = { [weak self] in
            self?.titleLabel.text = self?.viewModel.user.map({$0.firstname + " " + $0.lastname})
            self?.collectionView.reloadData()
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        if viewModel.isCompleteProfile {
            collectionView.isScrollEnabled = false
            settingsButton.isHidden = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if viewModel.isCurrentUser {
            viewModel.getUser()
        }
        hideNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        headerView?.videoView.jp_resume()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        headerView?.videoView.jp_stopPlay()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func settingsTapped(_ sender: Any) {
        guard let user = viewModel.user else {return}
        if viewModel.isCurrentUser {
            let controller = SettingsViewController.instantiate(fromAppStoryboard: .settings)
            self.navigationController?.pushViewController(controller, animated: true)
        }else {
            showProfileOptions(user: user)
        }
    }
    
    private func showProfileOptions(user: User) {

        let controller = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        let block = UIAlertAction(title: "Block \(user.firstname)", style: .destructive) { (_) in
            self.blockUser(userId: user.id)
            self.navigationController?.popViewController(animated: true)
            NotificationCenter.default.post(name: Constants.NotificationName.Reload, object: nil)
        }
        
        let spam = UIAlertAction(title: "Report User", style: .destructive) { (_) in
            self.viewModel.report(user: user)
        }
        //controller.addAction(message)
        controller.addAction(block)
        controller.addAction(spam)
        
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)
    }
    
    private func blockUser(userId: String) {
        spinner(with: "Please wait...", blockInteraction: true)
        viewModel.blockUser(userId: userId) {
            
        }
    }
    
    private func getDynamicLink() {
        guard let user = viewModel.user else {return}
        spinner(with: "Creating link...", blockInteraction: true)
        Helpers.createDynamicLink(user: user, mode: .profile) { [weak self] (url) in
            self?.hideSpinner()
            guard let url = url else { return }
            let vc = UIActivityViewController(activityItems: [url], applicationActivities: nil)
            if UI_USER_INTERFACE_IDIOM() == .pad {
                vc.modalPresentationStyle = .overCurrentContext
                let popover = vc.popoverPresentationController
                popover?.sourceView = self?.view
            }
            self?.present(vc, animated: true, completion: nil)
        }
    }
    
//    private var profileVideoURL: URL?
//    private var profileVideoCoverImage: UIImage?
//    private var profileImage: UIImage?
    private lazy var imagePicker = UIImagePickerController()
}

extension ProfileViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeue(ProfileHeaderCollectionReusableView.self, for: indexPath, forSupplementaryViewOfKind: kind)
        reusableView.viewModel = viewModel
        
        reusableView.onMemories = { [weak self] in
            self?.collectionView.reloadData()
            self?.viewModel.getMemories()
        }
        
        reusableView.onLikedFeeds = { [weak self] in
            self?.collectionView.reloadData()
            self?.viewModel.fetchRemoteLikedFeed()
        }
        
        reusableView.onEditProfile = { [weak self] in
            let controller = SettingViewController()
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        
        reusableView.onFollow = { [weak self, weak reusableView] in
            guard let self = self, let user = self.viewModel.user else {return}
            if user.followingStatus == "true" {
                let alertController = UIAlertController(title: "Postagraph", message: "Are you sure you want to unfollow \(user.firstname)", preferredStyle: .alert)
                let continueButton = UIAlertAction(title: "Continue", style: .default) { (_) in
                    self.viewModel.follow(followingId: user.id, status: "false")
                    reusableView?.viewModel = self.viewModel
                }
                let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(continueButton)
                alertController.addAction(cancel)
                self.present(alertController, animated: true, completion: nil)
            } else {
                self.viewModel.follow(followingId: user.id, status: "true")
                reusableView?.viewModel = self.viewModel
            }
        }
        
        reusableView.onMessage = { [weak self] in
            guard let currentUser = (UIApplication.shared.delegate as? AppDelegate)?.user,
                let user = self?.viewModel.user else { return }
            self?.spinner(with: "Please wait...", blockInteraction: true)
            ChatViewController.createGroup(withUser: user.condensedUser) { [weak self] (chatContact) in
                self?.hideSpinner()
                if let grp = chatContact {
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
        
        reusableView.onFollower = { [weak self] in
            guard let self = self, !self.viewModel.isCompleteProfile else {return}
            if !Helpers.isLoggedIn() {
                self.unauthenticatedBlock(canDismiss: true)
                return
            }
            let controller = FollowViewController.instantiate(fromAppStoryboard: .follow)
            let model = FollowViewModel(type: .follow(type: .follower), userId: self.viewModel.userId)
            controller.viewModel = model
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        reusableView.onFollowing = { [weak self] in
            guard let self = self, !self.viewModel.isCompleteProfile else {return}
            if !Helpers.isLoggedIn() {
                self.unauthenticatedBlock(canDismiss: true)
                return
            }
            let controller = FollowViewController.instantiate(fromAppStoryboard: .follow)
            let model = FollowViewModel(type: .follow(type: .following), userId: self.viewModel.userId)
            controller.viewModel = model
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        reusableView.onTrips = { [weak self] in
            guard let self = self, let user = self.viewModel.user, !self.viewModel.isCompleteProfile else {return}
            let controller = TripsterListViewController.instantiate(fromAppStoryboard: .tripster)
            let viewModel = TripListViewModel()
            viewModel.viewMode = .AllTrip
            viewModel.userId = self.viewModel.userId
            viewModel.isOnMainTab = false
            controller.hidesBottomBarWhenPushed = true
            controller.viewModel = viewModel
            
            let notTripViewModel = NoTripViewModel(user: user)
            controller.noTripVC.viewModel = notTripViewModel
            
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        reusableView.onSavedForLater = { [weak self] in
            let recordingsViewController = RecordingsViewController.instantiate(fromAppStoryboard: .video)
            recordingsViewController.hidesBottomBarWhenPushed = true
            recordingsViewController.isShowingSavedRecordings = true
            self?.navigationController?.pushViewController(recordingsViewController, animated: true)
        }
        
        reusableView.onMyBookings = { [weak self] in
            let bookingsViewController = MyHotelsBookingsViewController.instantiate(fromAppStoryboard: .hotels)
            bookingsViewController.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(bookingsViewController, animated: true)
        }
        
        reusableView.onLikedPlaces = { [weak self] in
            let controller = PlacesVC.instantiate(fromAppStoryboard: .places)
            self?.navigationController?.pushViewController(controller, animated: true)
        }
        
        reusableView.onInviteYourFriends = { [weak self] in
            let inviteController = InviteContainerController.instantiate(fromAppStoryboard: .invite)
            self?.navigationController?.pushViewController(inviteController, animated: true)
        }
        
        reusableView.onQuickInvite = { [weak self] in
            self?.getDynamicLink()
        }
        
        reusableView.onProfileImage = { [weak self] in
            if self?.viewModel.isCompleteProfile == true {
                self?.showUploadPhoto()
            }else {
                self?.showActionSheet()
            }
        }
        
        reusableView.onFullScreen = { [unowned self, unowned reusableView] in
            
            guard let url = (try? self.viewModel?.user?.profileVideo.asURL()) ?? nil else {return}
            
            self.collectionView.setContentOffset(.zero, animated: true)
            reusableView.isFullScreenMode = !reusableView.isFullScreenMode
            self.collectionView.isScrollEnabled = !reusableView.isFullScreenMode
            self.titleLabel.superview?.isHidden = reusableView.isFullScreenMode
            kAppDelegate.setupSound(isPrimary: reusableView.isFullScreenMode)
            if reusableView.isFullScreenMode {
                reusableView.videoView?.jp_playVideo(with: url, bufferingIndicator: JPVideoPlayerBufferingIndicator(), controlView: nil, progressView: nil){ (v, model) in
                    model.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                }
                reusableView.videoView.jp_muted = false
            }else {
                reusableView.videoView.jp_playVideoMute(with: url, bufferingIndicator: JPVideoPlayerBufferingIndicator(), progressView: nil, configuration: { (v, model) in
                    model.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                })
            }
        }
        reusableView.onSkip = { [weak self] in
            self?.goHome()
        }
        reusableView.onUploadVideo = { [weak self] in
            self?.showUploadVideo()
        }
        
        headerView = reusableView
        return reusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(TripListMemoryCollectionViewCell.self, for: indexPath)
        
        let memory = viewModel.feeds[indexPath.row]
        cell.imageView.image = nil
        cell.viewCountLabel.text = "\(memory.viewcount)"
        if let url = URL(string: memory.imageURL) {
            cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageView.sd_setImage(with: url, completed: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let controller = FeedDetailVC.instantiate(fromAppStoryboard: .feed)
        controller.feeds = viewModel.feeds
        controller.selectedFeedIndex = indexPath.item
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 4)/3
        let height = width*163/124
        return CGSize(width: width, height: height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let height = view.frame.height + 52 + (viewModel.isCurrentUser ? 184 : 0)
        return CGSize(width: collectionView.frame.width, height: height)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if collectionView.visibleSupplementaryViews(ofKind: UICollectionView.elementKindSectionHeader).first == nil {
            headerView?.videoView.jp_stopPlay()
        }else {
            headerView?.videoView.jp_resume()
        }
    }
    
}

extension ProfileViewController: JPVideoPlayerDelegate {
    
    func shouldShowDefaultControlAndIndicatorViews() -> Bool {
        return false
    }
    
    func shouldShowBlackBackgroundWhenPlaybackStart() -> Bool {
        return false
    }
    
}

extension ProfileViewController: UIImagePickerControllerDelegate {
    
    private func showActionSheet() {
        if !viewModel.isCurrentUser {
            if let url = try? viewModel.user?.profileImage.asURL() ?? nil {
                let imgVC = TRImageViewController.getVC(imgURL: url)
                self.present(imgVC, animated: true, completion: nil)
                imgVC.backButton.isHidden = false
            }
            return
        }
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.appBlack, forKey: "titleTextColor")
        
        let viewPhoto = UIAlertAction(title: "View Image", style: .default) { _ in
            if let url = try? self.viewModel.user?.profileImage.asURL() ?? nil {
                let imgVC = TRImageViewController.getVC(imgURL: url)
                self.present(imgVC, animated: true, completion: nil)
                imgVC.backButton.isHidden = false
                return
            }
        }
        viewPhoto.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let video = UIAlertAction(title: "Video Upload", style: .default) { (_) in
            self.openCamera(isCamera: true, isPhoto: false)
        }
        video.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let library = UIAlertAction(title: "Video Library", style: .default) { (_) in
            self.openCamera(isCamera: false, isPhoto: false)
        }
        library.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .destructive) { (_) in
            self.openCamera(isCamera: true, isPhoto: true)
        }
        takePhoto.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .destructive) { (_) in
            self.openCamera(isCamera: false, isPhoto: true)
        }
        photoLibrary.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let removePhoto = UIAlertAction(title: "Remove Photo", style: .destructive) { (_) in
            self.spinner(with: "One moment...", blockInteraction: true)
            self.viewModel.uploadProfileImage(url: "", completion: {
                self.hideSpinner()
                self.viewModel.getUser()
            })
        }
        removePhoto.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let removeVideo = UIAlertAction(title: "Remove Video", style: .destructive) { (_) in
            self.spinner(with: "One moment...", blockInteraction: true)
            self.viewModel.uploadProfileVideo(videoUrl: "", videoThumbnailUrl: nil, completion: {
                self.hideSpinner()
                self.viewModel.getUser()
            })
        }
        removeVideo.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let hasPhoto: Bool
        if let urlString = self.viewModel.user?.profileImage, !urlString.isEmpty, let _ = try? urlString.asURL() {
            hasPhoto = true
        }else {
            hasPhoto = false
        }
        
        if hasPhoto {
            alertController.addAction(viewPhoto)
        }
        alertController.addAction(video)
        alertController.addAction(library)
        alertController.addAction(takePhoto)
        alertController.addAction(photoLibrary)
        
        if hasPhoto {
            alertController.addAction(removePhoto)
        }
        
        if let urlString = viewModel?.user?.profileVideo, !urlString.isEmpty, let _ = try? urlString.asURL() {
            alertController.addAction(removeVideo)
        }
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    private func showUploadVideo() {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.appBlack, forKey: "titleTextColor")
        
        let video = UIAlertAction(title: "Video Upload", style: .default) { (_) in
            self.openCamera(isCamera: true, isPhoto: false)
        }
        video.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let library = UIAlertAction(title: "Video Library", style: .default) { (_) in
            self.openCamera(isCamera: false, isPhoto: false)
        }
        library.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let removeVideo = UIAlertAction(title: "Remove Video", style: .destructive) { (_) in
            self.spinner(with: "One moment...", blockInteraction: true)
            self.viewModel.uploadProfileVideo(videoUrl: "", videoThumbnailUrl: nil, completion: {
                self.hideSpinner()
                self.viewModel.getUser()
            })
        }
        removeVideo.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        alertController.addAction(video)
        alertController.addAction(library)
        
        if let urlString = viewModel?.user?.profileVideo, !urlString.isEmpty, let _ = try? urlString.asURL() {
            alertController.addAction(removeVideo)
        }
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    private func showUploadPhoto() {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        cancel.setValue(UIColor.appBlack, forKey: "titleTextColor")
        
        let viewPhoto = UIAlertAction(title: "View Image", style: .default) { _ in
            if let url = try? self.viewModel.user?.profileImage.asURL() ?? nil {
                let imgVC = TRImageViewController.getVC(imgURL: url)
                self.present(imgVC, animated: true, completion: nil)
                imgVC.backButton.isHidden = false
                return
            }
        }
        viewPhoto.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let takePhoto = UIAlertAction(title: "Take Photo", style: .destructive) { (_) in
            self.openCamera(isCamera: true, isPhoto: true)
        }
        takePhoto.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let photoLibrary = UIAlertAction(title: "Photo Library", style: .destructive) { (_) in
            self.openCamera(isCamera: false, isPhoto: true)
        }
        photoLibrary.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let removePhoto = UIAlertAction(title: "Remove Photo", style: .destructive) { (_) in
            self.spinner(with: "One moment...", blockInteraction: true)
            self.viewModel.uploadProfileImage(url: "", completion: {
                self.hideSpinner()
                self.viewModel.getUser()
            })
        }
        removePhoto.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        let hasPhoto: Bool
        if let urlString = self.viewModel.user?.profileImage, !urlString.isEmpty, let _ = try? urlString.asURL() {
            hasPhoto = true
        }else {
            hasPhoto = false
        }
        
        if hasPhoto {
            alertController.addAction(viewPhoto)
        }
        alertController.addAction(takePhoto)
        alertController.addAction(photoLibrary)
        
        if hasPhoto {
            alertController.addAction(removePhoto)
        }
        
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    private func openCamera(isCamera: Bool, isPhoto: Bool) {
        if isCamera {
            let controller = CameraVC.instantiate(fromAppStoryboard: .video)
            if isPhoto {
                controller.recordType = .simpleCamera
                controller.cameraMode = .Image
                controller.didCaptureImage = {[weak self] (image, error) in
                    if let image = image {
                        self?.uploadProfileImage(image: image) { (url) in
                            
                        }
                    } else {
                        self?.showAlert(message: "App is not able to take picture right now. Please try again later.")
                    }
                }
            }else {
                controller.recordType = .profile
                controller.didFinishRecording = { [weak self] (videoURL, coverImage) in
                    self?.uploadProfileVideoImage(profileVideoCoverImage: coverImage, profileVideo: videoURL)
                    //                self?.profileVideo = videoURL
                    //                self?.profileVideoCoverImage = coverImage
                }
            }
            let navController = UINavigationController(rootViewController: controller)
            navController.isNavigationBarHidden = true
            self.present(navController, animated: true, completion: nil)
        } else {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            
            if isPhoto {
                imagePicker.mediaTypes = [kUTTypeImage as String]
            } else {
                imagePicker.mediaTypes = [kUTTypeMovie as String]
            }
            
//            imagePicker.modalPresentationStyle = .currentContext
//            imagePicker.navigationBar.barStyle = .blackOpaque
//            imagePicker.navigationBar.tintColor = UIColor.white
//            imagePicker.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//            imagePicker.navigationBar.backgroundColor = UIColor.appRed
            present(imagePicker, animated: true, completion: nil)
        }
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
        var needsCropping: Bool = false
        if mediaType as? String == kUTTypeMovie as String,
            let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
            let asset = AVAsset(url: videoURL)
            if asset.duration.seconds > 7 {
                // alert = "Video must be less or equal to 6 seconds long."
                needsCropping = true
            }else {
                let thumbnail = getThumbnail(asset: asset)
                uploadProfileVideoImage(profileVideoCoverImage: thumbnail, profileVideo: videoURL)
            }
        }else if mediaType as? String == kUTTypeImage as String,
            let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
            uploadProfileImage(image: image) {(url) in

            }
        }
        picker.dismiss(animated: true, completion: {
//            if let alert = alert {
//                self.showAlert(message: alert)
//            }
            if needsCropping {
                let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as! URL
                let cropVC: VideoCropperViewController = Router.get()
                     cropVC.videoURL = videoURL
                cropVC.maxDuration = 6
                cropVC.completion = { [weak self] url in
                    guard let self = self else {return}
                    let asset = AVAsset(url: url)
                    let thumbnail = self.getThumbnail(asset: asset)
                    self.uploadProfileVideoImage(profileVideoCoverImage: thumbnail, profileVideo: videoURL)
                }
                self.navigationController?.pushViewController(cropVC, animated: true)
            }
        })
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
    
    private func uploadProfileImage(image: UIImage, completion: @escaping ((String?) ->())) {
        self.spinner(with: "Uploading...", blockInteraction: true)
        Helpers.uploadToS3(image: image) { [weak self] (s3URL, error) in
            DispatchQueue.main.async {
                if let url = s3URL {
                    self?.viewModel.uploadProfileImage(url: url, completion: {
                        self?.hideSpinner()
                        self?.viewModel.getUser()
                        completion(url)
                    })
                } else {
                    self?.hideSpinner()
                    completion(nil)
                }
            }
        }
    }
    
    private func uploadProfileVideoImage(profileVideoCoverImage:UIImage?,profileVideo:URL?) {
        guard let img = profileVideoCoverImage, profileVideo != nil else {
            return
        }
        self.spinner(with: "Uploading...", blockInteraction: true)
        Helpers.uploadToS3(image: img) { [weak self] (s3URL, error) in
            DispatchQueue.main.async {
                self?.uploadVideo(profileVideo:profileVideo,completion: { (videoURL) in
                    if let url = videoURL {
                        self?.viewModel.uploadProfileVideo(videoUrl: url, videoThumbnailUrl: s3URL, completion: {
                            self?.hideSpinner()
                            self?.viewModel.getUser()
                        })
                    }else {
                        self?.hideSpinner()
                    }
                })
            }
        }
    }
    
    private func uploadVideo(profileVideo:URL?, completion: @escaping ((String?) ->())) {
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
    
//    private func updateUser() {
//        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else {
//            return
//        }
//        MBProgressHUD.showCustomHud(to: self.view, animated: true).label.text = "One moment..."
//        uploadProfileImage { (profileImageURL) in
//            self.uploadProfileVideoImage(completion: { (imageURL, videoURL) in
//                user.profileImage = profileImageURL ?? user.profileImage
//                user.profileVideoThumb = imageURL ?? user.profileVideoThumb
//                user.profileVideo = videoURL ?? user.profileVideo
////                self.updateAccount(user: user)
//            })
//        }
//
//    }
//
//    private func uploadTapped() {
//        if !viewModel.isCurrentUser {return}
//
//        let controller = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actinSheetStyle())
//        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//
//        let video = UIAlertAction(title: "Video Upload", style: .default) { (_) in
//            let controller = CameraVC.instantiate(fromAppStoryboard: .video)
//            controller.recordType = .profile
//            controller.didFinishRecording = { [weak self] (videoURL, coverImage) in
//                self?.profileVideoURL = videoURL
//                self?.profileVideoCoverImage = coverImage
//            }
//            let navController = UINavigationController(rootViewController: controller)
//            navController.navigationBar.tintColor = UIColor.white
//            navController.navigationBar.barTintColor = UIColor.appRed
//            navController.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
//            navController.isNavigationBarHidden = true
//            self.present(navController, animated: true, completion: nil)
//        }
//        let camera = UIAlertAction(title: "Take Photo", style: .default) { (_) in
//            self.openCamera(isCamera: true)
//        }
//        let photoLibrary = UIAlertAction(title: "Photo Library", style: .default) { (_) in
//            self.openCamera(isCamera: false, isPhoto: true)
//        }
//        let library = UIAlertAction(title: "Video Library", style: .default) { (_) in
//            self.openCamera(isCamera: false)
//        }
//
//        controller.addAction(video)
//        controller.addAction(library)
//        controller.addAction(camera)
//        controller.addAction(photoLibrary)
//
//
//        controller.addAction(cancel)
//        present(controller, animated: true, completion: nil)
//    }
//

//
//    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
//        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
//
//        if mediaType as? String == kUTTypeMovie as String {
//            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
//                self.uploadVideo(videoURL: videoURL)
//            }
//        }  else if mediaType as? String == kUTTypeImage as String {
//            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
//                self.profileImage = image
////                self.profileImageView.image = image
//            }
//        }
//        dismiss(animated: true, completion: nil)
//
//    }
//
//    func uploadVideo(videoURL:URL) {
//        let asset = AVURLAsset(url: videoURL , options: nil)
//        let imgGenerator = AVAssetImageGenerator(asset: asset)
//        imgGenerator.appliesPreferredTrackTransform = true
//        do {
//            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
//            let image = UIImage(cgImage: cgImage)
//            profileVideoCoverImage = image
//            profileVideoURL = videoURL
//        } catch {
//            print(error)
//        }
//
//    }
//

//
//    private func uploadProfileVideoImage(completion: @escaping ((String?, String?) ->())) {
//        guard let img = profileVideoCoverImage else {
//            completion(nil, nil)
//            return
//        }
//        Helpers.uploadToS3(image: img) { (s3URL, error) in
//            DispatchQueue.main.async {
//                self.uploadVideo(completion: { (videoURL) in
//                    if let url = videoURL {
//                        let param = [
//                            "video_url": url,
//                            "video_thumb_url": s3URL ?? "",
//                            "user_id": Helpers.userId
//                        ]
//                        APIController.makeRequest(request: .uploadProfileVideo(param: param), completion: { (_) in
//
//                        })
//                    }
//                    completion(s3URL, videoURL)
//                })
//            }
//        }
//    }
//
//    private func uploadVideo(completion: @escaping ((String?) ->())) {
//        guard let urlString = profileVideoURL else {
//            completion(nil)
//            return
//        }
//        do {
//            let data = try Data.init(contentsOf: urlString)
//            Helpers.uploadVideoToS3(data: data) { (s3URL, error) in
//                DispatchQueue.main.async {
//                    completion(s3URL)
//                }
//            }
//        } catch {
//            completion(nil)
//            showAlert(message: "Video upload failed.")
//            print(error)
//        }
//    }

}
