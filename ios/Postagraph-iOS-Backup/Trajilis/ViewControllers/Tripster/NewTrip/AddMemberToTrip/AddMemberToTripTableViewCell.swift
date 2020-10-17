//
//  AddMemberToTripTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/16/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class AddMemberToTripTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var selectedIndicatorImageView: UIImageView?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.rounded()
        userImageView.set(borderWidth: 1, of: UIColor(hexString: "#e5e5e5"))
    }
    
    var userIsSelected: Bool = false {
        didSet {
            selectedIndicatorImageView?.tintColor = userIsSelected ? UIColor(hexString: "#D63D41") : UIColor(hexString: "#e8e8e8")
            selectedIndicatorImageView?.image = userIsSelected ? UIImage(named: "selected") : UIImage(named: "unselected")
        }
    }
    
    var user: CondensedUser? {
        didSet {
            setData()
        }
    }
    
    private func setData() {
        let text = [user?.firstName ?? "", user?.lastName ?? ""].filter({!$0.isEmpty}).joined(separator: " ")
        addressLabel.text = text
        addressLabel.isHidden = text.isEmpty
        nameLable.text = user?.username
        let placeHolderImage = UIImage(named: "userAvatar")
        userImageView.image = placeHolderImage
        if let urlString = user?.userImage, let url = URL(string: urlString) {
            userImageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
    }

}
