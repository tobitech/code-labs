//
//  NearbyFilterPlaceTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/27/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class NearbyFilterPlaceTableViewCell: UITableViewCell {
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var selectionImageView: UIImageView!
    @IBOutlet weak var placeNameLabel: UILabel!
    
    var placeIsSelected: Bool = false {
        didSet {
            selectionImageView.tintColor = placeIsSelected ? UIColor(hexString: "#D63D41") : UIColor(hexString: "#e8e8e8")
            selectionImageView.image = placeIsSelected ? UIImage(named: "selected") : UIImage(named: "unselected")
        }
    }
    
}
