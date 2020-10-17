//
//  FlightOutboundReturnView.swift
//  Trajilis
//
//  Created by user on 03/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class FlightOutboundReturnView: UIView {

    @IBOutlet weak var routetitleLbl: UILabel!
    @IBOutlet weak var flightTypeSegmentedControl: CustomSegmentedControl!
    @IBOutlet weak var departureDatebl: UILabel!
    @IBOutlet weak var returnDatebl: UILabel!
    @IBOutlet weak var departureDateImgV: UIImageView!
    @IBOutlet weak var returnDateImgV: UIImageView!
    @IBOutlet weak var departureDateButton: UIButton!
    @IBOutlet weak var returnDateButton: UIButton!
    
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM dd"
        return formatter
    }()
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code

        departureDateImgV.tintColor = UIColor.appGrey
        returnDateImgV.tintColor = UIColor.appGrey
    }
    
    func setDate(isOutbound: Bool, date: Date?) {
        if let date = date {
            let dateString = formatter.string(from: date)
            if isOutbound {
                departureDatebl.text = dateString
                departureDatebl.font = UIFont(name: "PTSans-Bold", size: 16)
                departureDatebl.textColor = UIColor.appRed
                departureDateImgV.tintColor = UIColor.appRed
            } else {
                returnDatebl.text = dateString
                returnDatebl.font = UIFont(name: "PTSans-Bold", size: 16)
                returnDatebl.textColor = UIColor.appRed
                returnDateImgV.tintColor = UIColor.appRed
            }
        } else {
            if isOutbound {
                departureDatebl.text = "Tap to Select"
                departureDatebl.font = UIFont(name: "PTSans-Regular", size: 16)
                departureDatebl.textColor = UIColor.appGrey
                departureDateImgV.tintColor = UIColor.appGrey
            } else {
                returnDatebl.text = "Tap to Select"
                returnDatebl.font = UIFont(name: "PTSans-Regular", size: 16)
                returnDatebl.textColor = UIColor.appGrey
                returnDateImgV.tintColor = UIColor.appGrey
            }
        }
    }
}
