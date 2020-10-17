//
//  FollowCell.swift
//  Trajilis
//
//  Created by Moses on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class FollowCell: UITableViewCell {
    static let name = "FollowCell"
    
    
    @IBOutlet  weak var button: UIButton!
    @IBOutlet fileprivate weak var name: UILabel!
    @IBOutlet fileprivate weak var userName: UILabel!
    @IBOutlet fileprivate weak var address: UILabel!
    @IBOutlet var thumbnail: UIImageView! {
        didSet {
            thumbnail.contentMode = .scaleAspectFill
            thumbnail.makeRounded()
            thumbnail.layer.borderColor = UIColor.appRed.cgColor
            thumbnail.layer.borderWidth = 0.5
        }
    }

    var followOrUnfollow: (() -> Void)?

    func configure(follow: Followers) {
        name.text = follow.name
        userName.text = follow.username
        address.text = follow.country + ", \(follow.city)"
        if follow.pic.count > 0, let url = URL(string: follow.pic) {
            thumbnail.sd_setImage(with: url, placeholderImage: UIImage(named: "avtar"))
        }
        button.isUserInteractionEnabled = true
        var image = follow.status ? UIImage.init(imageLiteralResourceName: "following") : UIImage.init(imageLiteralResourceName: "follow")
        if follow.userId == Helpers.userId {
            image = UIImage.init(imageLiteralResourceName: "following")
            button.isUserInteractionEnabled = false
        }
        button.setImage(image, for: .normal)
    }
    @IBAction fileprivate func setEvent() {
        followOrUnfollow?()
    }
}
