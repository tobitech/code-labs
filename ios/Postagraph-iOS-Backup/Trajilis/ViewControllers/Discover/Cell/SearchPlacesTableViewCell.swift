//
//  SearchPlacesTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/26/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage
import CoreLocation

class SearchPlacesTableViewCell: UITableViewCell {

    var place: CondensedPlace? {
        didSet {
            setup()
        }
    }
    var location: CLLocation? {
        didSet {
            if let location = location {
                distanceLabel.text = "\(round((place?.location?.distance(from: location) ?? 0)/1609.344))mi"
            }else {
                distanceLabel.text = ""
            }
        }
    }
    
    @IBOutlet weak var placeImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var typeLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var ratingView: CosmosView!

    override func awakeFromNib() {
        super.awakeFromNib()
        placeImageView.superview?.set(cornerRadius: 2)
    }
    
    func setup() {
        placeImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        placeImageView.image = nil
        
        if let url = try? place?.lastPlaceFeedImage.asURL() {
            placeImageView.sd_setImage(with: url)
        }
        //        cell.viewCountStackView.isHidden = true
        ratingView.isHidden = false
        distanceLabel.isHidden = false
        ratingView.rating = place?.rating ?? 0
        nameLabel.text = place?.name
        typeLabel.text = place?.type
        nameLabel.numberOfLines = 1
    }

}
