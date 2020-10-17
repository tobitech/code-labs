//
//  TripMemoryTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class TripMemoryTableViewCell: UITableViewCell {

    @IBOutlet var timeAgoLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var bgImageView: UIImageView!

    static var identifier: String {
        return String(describing: self)
    }

    static var Nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        profileImageView.makeRounded()
        bgImageView.layer.cornerRadius = 8
        bgImageView.layer.masksToBounds = true
    }

    func configure(feed: Feed) {
        profileImageView.makeRounded()
        bgImageView.layer.cornerRadius = 8
        bgImageView.layer.masksToBounds = true

        timeAgoLabel.text = Helpers.timeStampToTimeStringType(timeStamp: feed.createdOn)

        nameLabel.isHidden = feed.firstname.isEmpty && feed.lastname.isEmpty

        nameLabel.text = feed.firstname + " " + feed.lastname
        usernameLabel.text = feed.username + "@"

        if let url = URL.init(string: feed.userImage) {
            profileImageView.sd_setImage(with: url, completed: nil)
        }

        if let url = URL.init(string: feed.imageURL) {
            bgImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
}
