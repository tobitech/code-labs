//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PlaceInfoView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var stackView:UIStackView!
    @IBOutlet weak var ratingView: CosmosView!
    @IBOutlet weak var lblTitle: UILabel!
    @IBOutlet weak var lblPrice: UILabel!
    @IBOutlet weak var lblLocation: UILabel!
    @IBOutlet weak var btnContact: UIButton!
    @IBOutlet weak var btnDirection: UIButton!
    @IBOutlet weak var btnEMail: UIButton!
    @IBOutlet weak var imgView: UIImageView!
    @IBOutlet weak var imgViewWidthCnstrnt: NSLayoutConstraint!
    
    class func getView() -> PlaceInfoView {
        let view  = Bundle.main.loadNibNamed("PlaceInfoView", owner: self, options: nil)!.first as! PlaceInfoView
        view.imgView.layer.cornerRadius = 8
        view.imgView.layer.masksToBounds = true
        view.lblTitle.text = nil
        view.lblLocation.text = nil
        view.lblPrice.text = nil
        view.imgViewWidthCnstrnt.constant = 0
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    func fillWithPlace(gplace:GooglePlace) {
        if let name = gplace.name {
            self.lblTitle.text = name
        }
        if let value = gplace.address {
            self.lblLocation.text = value
        }
        ratingView.rating = gplace.rating        
    }
    func fillWithHotel(hotel:PGHotel) {
        if let name = hotel.hotelName {
            self.lblTitle.text = name
        }
        if let value = hotel.hotelAddress {
            self.lblLocation.text = value
        }
        if let rating = hotel.hotelDescription?.ratings_value {
            ratingView.rating = rating
        }
        //self.stackView.removeAllViews()
        
    }
    func fillWithBooking(booking:PGHotelBookingDetail) {
        if let name = booking.hotel_name {
            self.lblTitle.text = name
        }
        if let value = booking.hotel_city {
            self.lblLocation.text = value
        }
        ratingView.rating = 0
//        if let rating = hotel.hotelDescription?.ratings_value {
//            ratingView.rating = rating
//        }
        //self.stackView.removeAllViews()
        
    }
    
}
