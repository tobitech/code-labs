//
//  BottomClosableView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class BottomClosableView: UIView {
    
    @IBOutlet var placesCountLabel: UILabel!
    @IBOutlet var bottomProfileImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var imgContainerView: UIView!
    @IBOutlet var bottomProfilePhotoContainerView: UIView!
    @IBOutlet var contentView: UIView!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followersCountLabel: UILabel!
    @IBOutlet var tripsterCountLabel: UILabel!
    @IBOutlet var detailContainerView: UIView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var menuButton: UIButton!
    
    @IBOutlet var followButton: UIButton!
    @IBOutlet var shortQuoteLabel: UILabel!
    @IBOutlet var messageButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    
    var centerThumbnailTapBlock:(() -> ())?
    var profileOptionsBlock:(() -> ())?
    var tripsterBlock:(() -> ())?
    var noTripsBlock:(() -> ())?
    var placesBlock:(() -> ())?
    var followingBlock:(() -> ())?
    var followersBlock:(() -> ())?
    
    var sendMessageBlock:(() -> ())?
    var likeOrUnlikeBlock:((String) -> ())?
    var followOrUnFollowBlock:((String) -> ())?
    var user: User!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("BottomClosableView", owner: self, options: nil)
        addSubview(contentView)
        contentView.fill()
    }

    
    override func layoutSubviews() {
        super.layoutSubviews()
        detailContainerView.layer.cornerRadius = 15
        profileImageView.layer.cornerRadius = profileImageView.bounds.height/2
        profileImageView.layer.masksToBounds = true
        imgContainerView.layer.cornerRadius = profileImageView.bounds.height/2
        imgContainerView.layer.masksToBounds = true
        imgContainerView.layer.shadowColor = UIColor.appRed.cgColor
        imgContainerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        imgContainerView.layer.masksToBounds = false
        imgContainerView.layer.shadowRadius = 1.0
        imgContainerView.layer.shadowOpacity = 1.0
        imgContainerView.layer.shadowPath = UIBezierPath(roundedRect: imgContainerView.layer.bounds,
                                                         cornerRadius: imgContainerView.bounds.height/2).cgPath
        
        
        bottomProfileImageView.layer.cornerRadius = bottomProfileImageView.bounds.height/2
        bottomProfileImageView.layer.masksToBounds = true
        bottomProfilePhotoContainerView.layer.cornerRadius = bottomProfileImageView.bounds.height/2
        bottomProfilePhotoContainerView.layer.masksToBounds = true
        bottomProfilePhotoContainerView.layer.shadowColor = UIColor.appRed.cgColor
        bottomProfilePhotoContainerView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        bottomProfilePhotoContainerView.layer.masksToBounds = false
        bottomProfilePhotoContainerView.layer.shadowRadius = 1.0
        bottomProfilePhotoContainerView.layer.shadowOpacity = 1.0
        bottomProfilePhotoContainerView.layer.shadowPath = UIBezierPath(roundedRect: bottomProfilePhotoContainerView.layer.bounds,
                                                         cornerRadius: bottomProfilePhotoContainerView.bounds.height/2).cgPath
    }
    
    func configure(with user: User) {
        self.user = user
        if let id = UserDefaults.standard.string(forKey: USERID) {
            if user.id == id {
                followButton.isHidden = true
                messageButton.isHidden = true
            }
        }
        
        updateFollowStatus()

        
        followersCountLabel.text = user.followerCount
        followingCountLabel.text = user.followingCount
        tripsterCountLabel.text = user.tripsterCount
        
        nameLabel.text = user.firstname + " " + user.lastname
        usernameLabel.text = user.username
        locationLabel.text = user.city + ", " + user.state
        placesCountLabel.text = user.feedCount
        shortQuoteLabel.text = user.status
        if let url = URL.init(string: user.profileImage) {
            profileImageView.sd_setImage(with: url, completed: nil)
            bottomProfileImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    private func updateFollowStatus() {
        let img = user.followingStatus == "false" ? UIImage(named: "follow") : UIImage(named: "following")
        followButton.setImage(img, for: .normal)
    }
    
    @IBAction func tripsterTapped(_ sender: Any) {
        if let count = tripsterCountLabel.text,let intVal = Int(count),intVal > 0 {
            tripsterBlock?()
        } else {
            noTripsBlock?()
        }
    }
    
    @IBAction func followersTapped(_ sender: Any) {
        followersBlock?()
    }
    
    @IBAction func followingTapped(_ sender: Any) {
        followingBlock?()
    }
    
    @IBAction func placesTapped(_ sender: Any) {
        placesBlock?()
    }
    
    @IBAction func optionTapped(_ sender: Any) {
        profileOptionsBlock?()
    }
    
    @IBAction func followOrUnfollowTapped(_ sender: Any) {
        user.followingStatus = user.followingStatus == "true" ? "false" : "true"
        updateFollowStatus()
        followOrUnFollowBlock?(user.followingStatus)
    }
    
    @IBAction func likeOrUnlikeTapped(_ sender: Any) {
        sendMessageBlock?()
    }
    
    @IBAction func centerThumbnailTapped(_ sender: Any) {
        centerThumbnailTapBlock?()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.detailContainerView.alpha = 0
            self.bottomProfilePhotoContainerView.alpha = 1
        }
    }
    
    @IBAction func bottomProfileTapped(_ sender: Any) {
        UIView.animate(withDuration: 0.3) {
            self.detailContainerView.alpha = 1
            self.bottomProfilePhotoContainerView.alpha = 0
        }
    }
    
}
