//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGHotelBookingConfirmationView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    @IBOutlet weak var imgView1:UIImageView!
    @IBOutlet weak var lblBookingStatus:UILabel!
    @IBOutlet weak var lblBookingID:UILabel!
    @IBOutlet weak var lblOrderNumber:UILabel!
    @IBOutlet weak var viewCard:CardView!
    
    class func getView() -> PGHotelBookingConfirmationView {
        let view  = Bundle.main.loadNibNamed("PGHotelBookingConfirmationView", owner: self, options: nil)!.first as! PGHotelBookingConfirmationView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.viewCard.backgroundColor = .appRed
        return view
    }
    
}
