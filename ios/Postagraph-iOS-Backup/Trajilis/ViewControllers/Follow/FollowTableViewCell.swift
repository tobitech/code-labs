//
//  FollowTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/22/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class FollowTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var followButton: UIButton!
    
    var followOrUnfollow: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.rounded()
        userImageView.set(borderWidth: 1, of: UIColor(hexString: "#e5e5e5"))
        followButton.set(cornerRadius: 2)
    }
    
    var user: Followers? {
        didSet {
            setData()
        }
    }
    
    private func setData() {
        addressLabel.text = [user?.country, user?.city].compactMap({$0}).filter({!$0.isEmpty}).joined(separator: ", ")
        nameLable.text = user?.username
        let placeHolderImage = UIImage(named: "userAvatar")
        userImageView.image = placeHolderImage
        if let urlString = user?.pic, let url = URL(string: urlString) {
            userImageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
        
        
        if user?.userId == Helpers.userId {
            followButton.isUserInteractionEnabled = false
            followButton.alpha = 0
        }else {
            followButton.isUserInteractionEnabled = true
            followButton.alpha = 1
        }
        
        let title: String
        if user?.status ?? false {
            title = "Following"
            followButton.backgroundColor = UIColor(hexString: "#D63D41")
            followButton.set(borderWidth: 0, of: .clear)
            followButton.setTitleColor(.white, for: .normal)
        }else {
            title = "Follow"
            followButton.backgroundColor = .white
            followButton.set(borderWidth: 1, of: UIColor(hexString: "#e5e5e5"))
            followButton.setTitleColor(UIColor(hexString: "#D63D41"), for: .normal)
        }
        
        followButton.setTitle(title, for: .normal)
    }
    
    @IBAction private func follow() {
        followOrUnfollow?()
    }
    
}
