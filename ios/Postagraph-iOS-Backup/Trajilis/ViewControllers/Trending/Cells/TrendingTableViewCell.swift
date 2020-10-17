//
//  TrendingTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 13/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage

class TrendingTableViewCell: UITableViewCell {

    @IBOutlet var ratingView: CosmosView!
    @IBOutlet var postCountContainerView: GradientView!
    @IBOutlet var viewButton: UIButton!
    @IBOutlet var placeImageView: UIImageView!
    @IBOutlet var distanceLabel: UILabel!
    @IBOutlet var numberOfPostLabel: UILabel!
    @IBOutlet var subTitleLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!

    static var reuseIdentifier: String {
        return String(describing: self)
    }

    static var name: String {
        return reuseIdentifier
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        self.viewButton.setTitleColor(UIColor.appRed, for: .normal)
        // Initialization code
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        placeImageView.layer.cornerRadius = 5
        placeImageView.layer.masksToBounds = true
    }

    func configure(place: CondensedPlace, isNearBy: Bool = false) {
        distanceLabel.text = place.distance
        ratingView.rating = place.rating
        nameLabel.text = place.name
        if isNearBy {
            numberOfPostLabel.isHidden = true
            subTitleLabel.isHidden = false
            viewButton.isHidden = false
            self.ratingView.isUserInteractionEnabled = false
        } else {
            subTitleLabel.isHidden = true
            viewButton.isHidden = true
            numberOfPostLabel.isHidden = false
            numberOfPostLabel.text = "\(place.count)"
        }
        self.subTitleLabel.isHidden = true
        if let type = place.type,!type.isEmpty {
            self.subTitleLabel.text = type.localized
            self.subTitleLabel.isHidden = false
        }
        
        placeImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        placeImageView.backgroundColor = nil
        if let url = URL(string: place.lastPlaceFeedImage) {
            
            placeImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "logoWhiteBG"))
            
        } else if let url = URL(string: place.icon) {
            placeImageView.sd_setImage(with: url, placeholderImage: UIImage(named: "logoWhiteBG"))
            placeImageView.backgroundColor = UIColor.lightGray
        }
    }

   
    
}
