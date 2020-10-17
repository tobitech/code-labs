//
//  BlockCell.swift
//  Trajilis
//
//  Created by Moses on 08/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SDWebImage

class BlockCell: UITableViewCell {
    static let name = "BlockCell"
    
    @IBOutlet fileprivate weak var name: UILabel!
    @IBOutlet fileprivate weak var userName: UILabel!
    @IBOutlet fileprivate weak var address: UILabel!
    @IBOutlet var thumbnail: UIImageView! {
        didSet {
            thumbnail.style(nil, cornerRadius: 30)
        }
    }
    
    var indexPath : IndexPath!
    var user : User! {
        didSet {
            name.text = user.firstname + " " + user.lastname
            userName.text = user.username
            address.text = user.country + ", \(user.city)"
            thumbnail.sd_setImage(with: URL.init(string: user.profileImage)!, completed: nil)
        }
    }
    
    var event : ((User, IndexPath) -> Void )?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction private func blockEvent() {
        event?(user, indexPath)
    }
}
