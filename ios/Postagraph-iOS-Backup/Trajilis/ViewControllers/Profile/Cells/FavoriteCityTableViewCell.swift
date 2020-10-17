//
//  FavoriteCityTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FavoriteCityTableViewCell: UITableViewCell {
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var bgImageView: UIImageView!
    
    static var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

}
