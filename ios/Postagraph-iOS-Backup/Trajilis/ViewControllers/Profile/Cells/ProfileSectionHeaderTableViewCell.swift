//
//  ProfileSectionHeaderTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class ProfileSectionHeaderTableViewCell: UITableViewCell {

    @IBOutlet var inviteButton: SSBadgeButton!
    @IBOutlet var optionButton: UIButton!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var separatorLineView: UIView!

    static var reuseIdentifier: String {
        return String(describing: self)
    }

    var optionButtonBlock: (() -> Void)?
    var inviteButtonBlock: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        inviteButton.badgeBackgroundColor = .red
        inviteButton.setImage(UIImage(named: "Invitation")?.withRenderingMode(.alwaysOriginal), for: .normal)
        inviteButton.badgeEdgeInsets = UIEdgeInsets(top: 5, left: 0, bottom: 0, right: 15)
    }

    @IBAction func inviteTapped(_ sender: Any) {
        inviteButtonBlock?()
    }

    @IBAction func optionTapped(_ sender: Any) {
        optionButtonBlock?()
    }

}
