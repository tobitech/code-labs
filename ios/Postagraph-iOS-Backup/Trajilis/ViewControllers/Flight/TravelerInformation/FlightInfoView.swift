//
//  FlightInfoView.swift
//  Trajilis
//
//  Created by bharats802 on 20/03/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FlightInfoView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var lblDeparture:UILabel!
    @IBOutlet weak var lblArrival:UILabel!
    @IBOutlet weak var lblDates:UILabel!
    
    @IBOutlet weak var btnTravellers:UIButton!
    @IBOutlet weak var btnPrice:UIButton!
    @IBOutlet weak var btnPayment:UIButton!
    @IBOutlet weak var viewCompleteProfileBtn:UIView!
    @IBOutlet weak var imgView:UIImageView!
    
    @IBOutlet weak var btnCompleteYourProfile:UIButton!
    class func getView() -> FlightInfoView {
        
        let view  = Bundle.main.loadNibNamed("FlightInfoView", owner: self, options: nil)!.first as! FlightInfoView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.btnCompleteYourProfile.backgroundColor = UIColor.appRed
        view.setEnabled(btn: view.btnTravellers)
        return view
        
    }
    func setEnabled(btn:UIButton) {
        self.btnPrice.setTitleColor(UIColor.gray, for: .normal)
        self.btnTravellers.setTitleColor(UIColor.gray, for: .normal)
        self.btnPayment.setTitleColor(UIColor.gray, for: .normal)
        btn.setTitleColor(btn.tintColor, for: .normal)
    }

}
