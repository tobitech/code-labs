//
//  AddMemberToTripCollectionViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/16/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class AddMemberToTripCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.rounded()
        imageView.set(borderWidth: 1, of: UIColor(hexString: "#E5E5E5"))
    }
    
}
