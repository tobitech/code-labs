//
//  SearchDealsTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/26/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class SearchDealsTableViewCell: UITableViewCell {

    @IBOutlet weak var dealBgImageView: UIImageView!
    @IBOutlet weak var cityNameLabel: UILabel!
    @IBOutlet weak var costLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        dealBgImageView.superview?.set(cornerRadius: 4)
    }

}
