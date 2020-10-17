//
//  FollowCollectionViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 20/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FollowCollectionViewCell: UICollectionViewCell {
    static let identifier = "FollowCollectionViewCell"

    @IBOutlet fileprivate var userName: UILabel!

    @IBOutlet var thumbnail: UIImageView! 

    override func layoutSubviews() {
        super.layoutSubviews()
        thumbnail.contentMode = .scaleToFill
        thumbnail.makeRounded()
        thumbnail.layer.borderWidth = 0.5
        thumbnail.layer.borderColor = UIColor.appRed.cgColor
        self.backgroundColor = .clear
    }
 
    func configureWithUser(user: CondensedUser) {
        userName.text = user.username
        if let url = URL.init(string: user.userImage) {
            thumbnail.sd_setImage(with: url, completed: nil)
        }
    }
}
