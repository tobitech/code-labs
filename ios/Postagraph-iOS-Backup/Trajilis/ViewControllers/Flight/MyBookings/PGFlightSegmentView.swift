//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGFlightSegmentView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    @IBOutlet weak var stackView:UIStackView!
    @IBOutlet weak var lblFlightNum:UILabel!
    
    @IBOutlet weak var lblDepCity:UILabel!
    @IBOutlet weak var lblDepAirport:UILabel!
    
    @IBOutlet weak var lblArrCity:UILabel!
    @IBOutlet weak var lblArrAirport:UILabel!
    
    @IBOutlet weak var lblDepDateTime:UILabel!
    @IBOutlet weak var lblArrDateTime:UILabel!
    
    @IBOutlet weak var lblDuration:UILabel!
    @IBOutlet weak var lblOperatedBy:UILabel!

    
    
    class func getView() -> PGFlightSegmentView {
        let view  = Bundle.main.loadNibNamed("PGFlightSegmentView", owner: self, options: nil)!.first as! PGFlightSegmentView
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.lblDepCity.text = "-"
        view.lblDepAirport.text = "-"
        
        view.lblArrCity.text = "-"
        view.lblArrAirport.text = "-"
        
        view.lblDepDateTime.text = "-"
        view.lblArrDateTime.text = "-"
        
        view.lblDuration.text = "-"
        view.lblOperatedBy.text = "-"
        
        return view
    }
    func fillSegment(segment:PGFlightItinarySegment) {
        if let name =  segment.departureLocation?.name {
            if let code = segment.departureLocation?.code {
                self.lblDepCity.text = "\(name) (\(code))"
            } else {
                self.lblDepCity.text = "\(name)"
            }
            if let airName = segment.departureLocation?.airportName {
                self.lblDepAirport.text = airName
            }
        }
        if let name =  segment.arrivalLocation?.name {
            if let code = segment.departureLocation?.code {
                self.lblArrCity.text = "\(name) (\(code))"
            } else {
                self.lblArrCity.text = "\(name)"
            }
            
        }
        if let airName = segment.arrivalLocation?.airportName {
            self.lblArrAirport.text = airName
        }
        
        let depDateString = self.formatter.string(from: segment.departureDateTime)
        self.lblDepDateTime.text = depDateString
        let dateString = self.formatter.string(from: segment.arrivalDateTime)
        self.lblArrDateTime.text = dateString
        self.lblFlightNum.text = "Flight Num: \(segment.flightNumber)"
        
        self.lblDuration.text = segment.arrivalDateTime.offsetFrom(date: segment.departureDateTime)
        
        
        
    }
    fileprivate let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE dd MMM, HH:mm"
        return formatter
    }()
    

}
