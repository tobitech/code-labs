//
//  ProfileHeaderCollectionReusableView.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/28/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class ProfileHeaderCollectionReusableView: UICollectionReusableView {
    
    @IBOutlet weak var videoView: AVPlayerView!
    @IBOutlet weak var maskRectImageView: UIImageView!
    @IBOutlet weak var videoThumbnailImage: UIImageView!
    @IBOutlet weak var profileImageButton: UIButton!
    @IBOutlet weak var usernameLabel: UILabel!
    @IBOutlet weak var locationLabel: UILabel!
    @IBOutlet weak var followersCountLabel: UILabel!
    @IBOutlet weak var followingCountLabel: UILabel!
    @IBOutlet weak var tripsCountLabel: UILabel!
    @IBOutlet weak var editProfileButton: UIButton!
    @IBOutlet weak var followButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    @IBOutlet weak var skipButton: UIButton!
    @IBOutlet weak var uploadVideoButton: UIButton!
    
    @IBOutlet weak var myProfileActionBlock: UIStackView!
    @IBOutlet weak var memoriesButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var followersStackView: UIStackView!
    @IBOutlet weak var followingStackView: UIStackView!
    @IBOutlet weak var tripsStackView: UIStackView!
    @IBOutlet weak var statusLabel: UILabel!
    
    @IBOutlet weak var calendarImageView: UIImageView!
    @IBOutlet weak var likedPlacesImageView: UIImageView!
    
    @IBOutlet weak var savedForLaterView: UIView!
    @IBOutlet weak var myBookingsView: UIView!
    @IBOutlet weak var likedPlacesView: UIView!
    @IBOutlet weak var inviteYourFriendsView: UIView!
    @IBOutlet weak var personalizedLinkView: UIView!
    @IBOutlet var fullProfileVideoHideViews: [UIView]!
    @IBOutlet weak var uploadProfileVideoView: UIView!
    
    var viewModel: ProfileViewModel! {
        didSet {
            setup()
            
            if let videoURLString = viewModel.user?.profileVideo, !videoURLString.isEmpty && (try? videoURLString.asURL()) != nil {
                skipButton.setTitle("Finish", for: .normal)
                uploadProfileVideoView.isHidden = true
            }else {
                skipButton.setTitle("Skip", for: .normal)
                uploadProfileVideoView.isHidden = !viewModel.isCompleteProfile
            }
            skipButton.isHidden = !viewModel.isCompleteProfile
        }
    }
    
    var isFullScreenMode: Bool = false {
        didSet {
            maskRectImageView.image = isFullScreenMode ? nil : UIImage(named: "maskRect")
            fullProfileVideoHideViews.forEach({$0.isHidden = self.isFullScreenMode})
        }
    }
    
    var onEditProfile: (() -> ())?
    var onFollow: (() -> ())?
    var onMessage: (() -> ())?
    var onMemories: (() -> ())?
    var onLikedFeeds: (() -> ())?
    var onFollower: (() -> ())?
    var onFollowing: (() -> ())?
    var onTrips: (() -> ())?
    
    var onSavedForLater: (() -> ())?
    var onMyBookings: (() -> ())?
    var onLikedPlaces: (() -> ())?
    var onInviteYourFriends: (() -> ())?
    var onProfileImage: (() -> ())?
    var onQuickInvite: (() -> ())?
    var onFullScreen: (() -> ())?
    var onSkip: (()->())?
    var onUploadVideo: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        [editProfileButton, messageButton, followButton, uploadVideoButton, skipButton].forEach({
            $0?.set(borderWidth: 2, of: UIColor(hexString: "#E5E5E5"))
            $0?.set(cornerRadius: 4)
        })
        
        likeButton.setImage(UIImage(named: "heart-empty")?.withRenderingMode(.alwaysTemplate), for: .normal)
        calendarImageView.tintColor = UIColor(hexString: "#D63D41")
        calendarImageView.image = UIImage(named: "calendar")?.withRenderingMode(.alwaysTemplate)
        likedPlacesImageView.tintColor = UIColor(hexString: "#D63D41")
        likedPlacesImageView.image = UIImage(named: "map-pin")?.withRenderingMode(.alwaysTemplate)
        
        profileImageButton.set(borderWidth: 1, of: UIColor(hexString: "#E5E5E5"))
        profileImageButton.rounded()
        
        let followerTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.followerTapped))
        followersStackView.addGestureRecognizer(followerTapGesture)
        
        let followingTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.followingTapped))
        followingStackView.addGestureRecognizer(followingTapGesture)
        
        let tripsTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tripsTapped))
        tripsStackView.addGestureRecognizer(tripsTapGesture)
        
        let savedForLaterTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.savedForLaterTapped))
        savedForLaterView.addGestureRecognizer(savedForLaterTapGesture)
        
        let myBookingsTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.myBookingsTapped))
        myBookingsView.addGestureRecognizer(myBookingsTapGesture)
        
        let likedPlacesTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.likedPlacesTapped))
        likedPlacesView.addGestureRecognizer(likedPlacesTapGesture)
        
        let inviteYourFriendsTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.inviteYourFriendsTapped))
        inviteYourFriendsView.addGestureRecognizer(inviteYourFriendsTapGesture)
        
        let quickInviteTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.quickInviteTapped))
        personalizedLinkView.addGestureRecognizer(quickInviteTapGesture)
        
        let fullScreenTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.fullScreenTapped))
        maskRectImageView.addGestureRecognizer(fullScreenTapGesture)
    }
    
    private func setup() {
        followersStackView.isHidden = viewModel.user?.username.lowercased() == "postagraph" && kAppDelegate.user?.registrationType != "admin"
        
        let url = try? viewModel.user?.profileVideoThumb.asURL()
        videoThumbnailImage.sd_setImage(with: url ?? nil, placeholderImage: UIImage(named: "profileBg"))
        
        let profileURL = try? viewModel.user?.profileImageThumb.asURL()
        profileImageButton.sd_setImage(with: profileURL ?? nil, for: .normal, placeholderImage: UIImage(named: "userProfilePlaceHolderImage"))
        
        usernameLabel.text = (viewModel.user?.username).map({"@"+$0})
        locationLabel.text = [viewModel.user?.city, viewModel.user?.state].compactMap({$0}).joined(separator: ", ")
        followersCountLabel.text    = viewModel.user?.followerCount
        followingCountLabel.text    = viewModel.user?.followingCount
        tripsCountLabel.text        = viewModel.user?.tripsterCount
        
        statusLabel.text = viewModel.user?.status
        statusLabel.isHidden = (viewModel.user?.status ?? "").isEmpty
        if viewModel.isCompleteProfile {
            editProfileButton.isHidden  = true
            followButton.isHidden       = true
            messageButton.isHidden      = true
        }else {
            editProfileButton.isHidden  = !viewModel.isCurrentUser
            followButton.isHidden       = viewModel.isCurrentUser
            messageButton.isHidden      = viewModel.isCurrentUser
        }
        
        myProfileActionBlock.isHidden = !viewModel.isCurrentUser
        
        let title: String
        if viewModel.user?.followingStatus == "true" {
            title = "Following"
            followButton.backgroundColor = UIColor(hexString: "#D63D41")
            followButton.set(borderWidth: 0, of: .clear)
        }else {
            title = "Follow"
            followButton.backgroundColor = .clear
            followButton.set(borderWidth: 2, of: UIColor(hexString: "#e5e5e5"))
        }
        
        followButton.setTitle(title, for: .normal)
        
    }
    
    @objc private func fullScreenTapped() {
        onFullScreen?()
    }
    
    @objc private func followerTapped() {
        onFollower?()
    }
    
    @objc private func followingTapped() {
        onFollowing?()
    }
    
    @objc private func tripsTapped() {
        onTrips?()
    }
    
    @objc private func savedForLaterTapped() {
        onSavedForLater?()
    }
    
    @objc private func myBookingsTapped() {
        onMyBookings?()
    }
    
    @objc private func likedPlacesTapped() {
        onLikedPlaces?()
    }
    
    @objc private func inviteYourFriendsTapped() {
        onInviteYourFriends?()
    }
    
    @objc private func quickInviteTapped() {
        onQuickInvite?()
    }
    
    @IBAction private func follow() {
        onFollow?()
    }
    
    @IBAction private func message() {
        onMessage?()
    }
    
    @IBAction private func editProfile() {
        onEditProfile?()
    }
    
    @IBAction private func memories() {
        viewModel.mode = .memories
        setMode()
        onMemories?()
    }
    
    @IBAction private func likedFeeds() {
        viewModel.mode = .likedFeeds
        setMode()
        onLikedFeeds?()
    }
    
    @IBAction func profileImageTapped(_ sender: Any) {
        onProfileImage?()
    }
    
    @IBAction func uploadVideoTapped(_ sender: Any) {
        onUploadVideo?()
    }
    
    @IBAction func skip(_ sender: Any) {
        onSkip?()
    }
    
    private func setMode() {
        memoriesButton.tintColor = viewModel.mode == .memories ? UIColor(hexString: "#D63D41") : UIColor(hexString: "#3F3F3F", alpha: 0.5)
        likeButton.tintColor = viewModel.mode == .likedFeeds ? UIColor(hexString: "#D63D41") : UIColor(hexString: "#3F3F3F", alpha: 0.5)
    }
    
}
