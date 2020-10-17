//
//  ProfileHeaderTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class ProfileHeaderTableViewCell: UITableViewCell {

    @IBOutlet var editButton: UIButton!
    @IBOutlet var likeButton: UIButton!
    @IBOutlet var placesCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var followersCountLabel: UILabel!
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var playButton: UIButton!
    @IBOutlet var backgroundImageView: UIImageView!
    @IBOutlet var profleImageView: UIImageView!
    @IBOutlet var messageButton: TrajilisButton!
    @IBOutlet var followOrUnfollowButton: UIButton!

    var editBlock:(() -> Void)?
    var likeBlock:(() -> Void)?
    var placeBlock:(() -> Void)?
    var followingBlock:(() -> Void)?
    var followersBlock:(() -> Void)?
    var playBlock:(() -> Void)?
    var messageBlock:(() -> Void)?
    var followBlock:(() -> Void)?
    var profileBlock: (() -> Void)?
    var likeOrUnlikeBlock:((String) -> ())?
    var followOrUnFollowBlock:((String) -> ())?

    var backTapped: (() -> Void)?

    static var identifier: String {
        return String(describing: self)
    }

    var user: User!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profleImageView.layer.cornerRadius = profleImageView.bounds.height/2
        profleImageView.layer.masksToBounds = true
    }

    func configure(user: User, bgImage: UIImage?) {
        profleImageView.layer.cornerRadius = profleImageView.bounds.height/2
        profleImageView.layer.masksToBounds = true
        self.user = user
        nameLabel.text = user.firstname + " " + user.lastname
        usernameLabel.text = "@ \(user.username)"
        cityLabel.text = user.city + ", \(user.state)"
        followersCountLabel.text = user.followerCount
        followingCountLabel.text = user.followingCount
        placesCountLabel.text = user.feedCount

        if let url = URL.init(string: user.profileImage) {
            profleImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "profile"), completed: nil)
        }

        if let url = URL.init(string: user.profileVideoThumb) {
            backgroundImageView.sd_setImage(with: url, completed: nil)
            playButton.isHidden = false
        } else {
            playButton.isHidden = true
        }


        let isCurrentUser = Helpers.userId == user.id

        followOrUnfollowButton.isHidden = isCurrentUser

        updateFollowStatus()
        updateLike()

    }

    private func updateLike() {
        let img = user.profileLikeStatus == "true" ? UIImage(named: "heart-filled") : UIImage(named: "heart-red-border")
        likeButton.setImage(img, for: .normal)
    }

    private func updateFollowStatus() {
        let img = user.followingStatus == "false" ? UIImage(named: "followButton") : UIImage(named: "following")
        followOrUnfollowButton.setImage(img, for: .normal)
    }

    @IBAction func profileTapped(_ sender: Any) {
        profileBlock?()
    }

    @IBAction func editTapped(_ sender: Any) {
        editBlock?()
    }

    @IBAction func backTapped(_ sender: Any) {
        backTapped?()
    }
    @IBAction func likeTapped(_ sender: Any) {
        user.profileLikeStatus = user.profileLikeStatus == "true" ? "false" : "true"
        updateLike()
        likeOrUnlikeBlock?(user.profileLikeStatus)
    }

    @IBAction func placeTapped(_ sender: Any) {
        placeBlock?()
    }

    @IBAction func followingTapped(_ sender: Any) {
        followingBlock?()
    }

    @IBAction func followersTapped(_ sender: Any) {
        followersBlock?()
    }

    @IBAction func playTapped(_ sender: Any) {
        playBlock?()
    }

    @IBAction func messageTapped(_ sender: Any) {
        messageBlock?()
    }

    @IBAction func followTapped(_ sender: Any) {
        user.followingStatus = user.followingStatus == "true" ? "false" : "true"
        updateFollowStatus()
        followOrUnFollowBlock?(user.followingStatus)
    }
}
