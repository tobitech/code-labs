//
//  SearchPeopleTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/26/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class SearchPeopleTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLable: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.rounded()
        userImageView.set(borderWidth: 1, of: UIColor(hexString: "#e5e5e5"))
    }
    
    var user: Followers? {
        didSet {
            setData()
        }
    }
    
    private func setData() {
        addressLabel.text = user?.name ?? ""
        nameLable.text = user?.username
        let placeHolderImage = UIImage(named: "userAvatar")
        userImageView.image = placeHolderImage
        if let url = try? user?.pic.asURL() {
            userImageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
    }

}
