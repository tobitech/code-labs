//
//  PGHotelListCell.swift
//  Trajilis
//
//  Created by bharats802 on 16/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage

class PGHotelListCell: UITableViewCell {

    static var identifier:String = "PGHotelListCell"
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblLocation:UILabel!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var viewRating:CosmosView!
    @IBOutlet weak var imgView:UIImageView!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.contentView.backgroundColor = .clear
        self.lblPrice.textColor = .appRed

        self.viewRating.tintColor = .appRed        
        self.viewRating.isUserInteractionEnabled = false
        Helpers.setupRatingView(view: viewRating)
        self.selectionStyle = .none
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    func fillHotel(hotel:PGHotel) {
        self.lblTitle.text = hotel.hotelName
        self.lblLocation.text = hotel.hotelAddress
        self.lblPrice.text = hotel.getMinimumPrice()
        if let rating = hotel.hotelDescription?.ratings_value {
            self.viewRating.rating = rating
        }
        self.imgView.image = nil
        if let strUrl = hotel.hotelImage,strUrl.count > 0,let url = URL(string:strUrl) {
            self.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.imgView.sd_setImage(with: url, placeholderImage: UIImage(named: "mapsmall"))            
        } else {
            self.imgView.image = UIImage(named:"mapsmall")
        }
    }
    
}
