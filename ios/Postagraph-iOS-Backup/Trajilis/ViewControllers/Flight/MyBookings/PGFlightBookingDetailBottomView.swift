//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGFlightBookingDetailBottomView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
  
    @IBOutlet weak var lblPaxTitle:UILabel!
   @IBOutlet weak var lblPaxDetails:UILabel!
    
    @IBOutlet weak var lblClass:UILabel!
    @IBOutlet weak var lblTrip:UILabel!
    @IBOutlet weak var lblPrice:UILabel!
    
    class func getView() -> PGFlightBookingDetailBottomView {
        let view  = Bundle.main.loadNibNamed("PGFlightBookingDetailBottomView", owner: self, options: nil)!.first as! PGFlightBookingDetailBottomView
        view.translatesAutoresizingMaskIntoConstraints = false
 
        return view
    }
    

}
