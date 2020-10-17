//
//  FollowCell.swift
//  Trajilis
//
//  Created by Moses on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import Kingfisher

class FollowCell: UITableViewCell {
    static let name = "FollowCell"
    
    
    @IBOutlet fileprivate weak var button: UIButton!
    @IBOutlet fileprivate weak var name: UILabel!
    @IBOutlet fileprivate weak var userName: UILabel!
    @IBOutlet fileprivate weak var address: UILabel!
    @IBOutlet var thumbnail: UIImageView! {
        didSet {
            thumbnail.style(nil, cornerRadius: 30)
        }
    }
    
    
    var set: ((Followers, IndexPath) -> Void)?
    var indexPath : IndexPath!
    
    var follow: Followers! {
        didSet {
            name.text = follow.name
            userName.text = follow.username
            address.text = follow.country + ", \(follow.city)"
            
            let re = ImageResource.init(downloadURL: URL.init(string: follow.pic)!, cacheKey: follow.pic)
            thumbnail.kf.setImage(with: re)
        }
    }
    
    var type : FollowType! {
        didSet {
            if type == .follower {
                let image = UIImage.init(imageLiteralResourceName: "following")
                button.setImage(image, for: .normal)
            } else {
                let image = UIImage.init(imageLiteralResourceName: "follow")
                button.setImage(image, for: .normal)
            }
        }
    }
    
    
    @IBAction fileprivate func setEvent() {
        set?(follow, indexPath)
    }

}
