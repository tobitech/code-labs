
//
//  SideMenuHeaderTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class SideMenuHeaderTableViewCell: UITableViewCell {

    static var identifier: String {
        return String(describing: self)
    }

    @IBOutlet var followersCountLabel: UILabel!
    @IBOutlet var followingCountLabel: UILabel!
    @IBOutlet var PlacesCountLabel: UILabel!
    @IBOutlet var usernameLabel: UILabel!

    var followersBlock:(() -> Void)?
    var followingBlock:(() -> Void)?
    var placesBlock:(() -> Void)?
    var profileBlock:(() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(user: User) {
        followersCountLabel.text = user.followerCount
        followingCountLabel.text = user.followingCount
        usernameLabel.text = "@" + user.username
        PlacesCountLabel.text = user.feedCount
    }

    @IBAction func followersTapped(_ sender: Any) {
        followersBlock?()
    }

    @IBAction func placesTapped(_ sender: Any) {
        placesBlock?()

    }

    @IBAction func profileTapped(_ sender: Any) {
        profileBlock?()
    }

    @IBAction func followingTapped(_ sender: Any) {
        followingBlock?()
    }
}
