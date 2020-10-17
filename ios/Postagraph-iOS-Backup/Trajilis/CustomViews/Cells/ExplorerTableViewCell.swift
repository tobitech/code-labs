//
//  ExplorerTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 17/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class ExplorerTableViewCell: UITableViewCell {

    @IBOutlet weak var backView:UIView!
    @IBOutlet weak var imgCityPhoto:UIImageView!
    @IBOutlet weak var lblCityName:UILabel!
    @IBOutlet weak var lblFlightFare:UILabel!
    @IBOutlet weak var lblOriginalFare:UILabel!
    @IBOutlet weak var activity:UIActivityIndicatorView!
    
    static var identifier: String {
        return String(describing: self)
    }

    static var Nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.backView.layer.cornerRadius = 8
        self.imgCityPhoto.layer.cornerRadius = 8
        self.imgCityPhoto.layer.masksToBounds = true
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
