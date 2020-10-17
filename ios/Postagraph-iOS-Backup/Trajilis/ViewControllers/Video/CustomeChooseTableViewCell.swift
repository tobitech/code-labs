//
//  CustomeChooseTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class CustomeChooseTableViewCell: UITableViewCell {

    static let kIdentifier = "CustomeChooseTableViewCell"

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var imageV: UIImageView!

    override func layoutSubviews() {
        super.layoutSubviews()
        imageV.layer.cornerRadius = 20
        imageV.layer.masksToBounds = true
    }
    
}
