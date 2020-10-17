//
//  ProfileTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet var placeCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followersCountLabel: UILabel!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var detailContainerView: UIView!
    @IBOutlet var centerImageView: UIImageView!
    @IBOutlet var bgImageView: UIImageView!
    @IBOutlet var bottomProfileImageView: UIImageView!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var menuButton: UIButton!
    
    @IBOutlet var followButton: UIButton!
    @IBOutlet var shortQuoteLabel: UILabel!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var closeButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        detailContainerView.layer.cornerRadius = 15
        detailContainerView.layer.masksToBounds = true
        
        centerImageView.layer.cornerRadius = centerImageView.bounds.height/2
        centerImageView.layer.masksToBounds = true
        
        bottomProfileImageView.layer.cornerRadius = bottomProfileImageView.bounds.height/2
        bottomProfileImageView.layer.masksToBounds = true
    }
    
    func configure(with user: User) {
        followersCountLabel.text = user.followerCount
        followingCountLabel.text = user.followingCount
//        placeCountLabel.text = user.pla
        likeCountLabel.text = user.profileLikeCount
        nameLabel.text = user.firstname + " " + user.lastname
        usernameLabel.text = user.username
        locationLabel.text = user.city + ", " + user.country
        shortQuoteLabel.text = user.status
        if let url = URL.init(string: user.profileImage) {
            Helpers.retrieveImage(imageURL: url) { (image) in
                if let img = image {
                    self.bgImageView.image = img.resize(targetSize: CGSize.init(width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height))
                    self.centerImageView.image = img.resize(targetSize: CGSize.init(width: 60, height: 60))
                    self.bottomProfileImageView.image = img.resize(targetSize: CGSize.init(width: 60, height: 60))
                }
            }
        }
    }
    
    @IBAction func menuTapped(_ sender: Any) {
        
    }
    
    @IBAction func followTapped(_ sender: Any) {
        
    }
    
    @IBAction func likeTapped(_ sender: Any) {
        
    }
    
    @IBAction func closeTapped(_ sender: Any) {
    }
    
    @IBAction func likesTapped(_ sender: Any) {
    }
    
    @IBAction func followersTapped(_ sender: Any) {
    }
    
    @IBAction func placeTapped(_ sender: Any) {
    }
    
    @IBAction func followingTapped(_ sender: Any) {
    }
    
}
