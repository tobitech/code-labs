//
//  FlightInfoView.swift
//  Trajilis
//
//  Created by bharats802 on 20/03/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PriceBreakup: UIView {

   
    @IBOutlet weak var lblTraveler:UILabel!
    @IBOutlet weak var lblBasePrice:UILabel!
    @IBOutlet weak var lblTaxNFee:UILabel!
    @IBOutlet weak var lblSubTotal:UILabel!
    
    class func getView() -> PriceBreakup {
        let view  = Bundle.main.loadNibNamed("PriceBreakup", owner: self, options: nil)!.first as! PriceBreakup
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    func setLabels(isHeader:Bool = false) {
        if isHeader {
            self.lblTraveler.font = UIFont(name: "Lato-Bold", size: 13)
            
        } else {
            self.lblTraveler.font = UIFont(name: "Lato", size: 13)
            
            self.lblTraveler.text = nil
            self.lblBasePrice.text = nil
            self.lblTaxNFee.text = nil
            self.lblSubTotal.text = nil
        }
        self.lblBasePrice.font = self.lblTraveler.font
        self.lblTaxNFee.font = self.lblTraveler.font
        self.lblSubTotal.font = self.lblTraveler.font
        
    }
}
