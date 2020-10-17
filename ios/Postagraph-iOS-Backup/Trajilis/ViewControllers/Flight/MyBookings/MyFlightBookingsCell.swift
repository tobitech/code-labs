//
//  TrendingTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 13/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class MyFlightBookingsCell: UITableViewCell {

    
    @IBOutlet weak var lblTicketNum:UILabel!
    @IBOutlet weak var lblDate:UILabel!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblDeparture:UILabel!
    @IBOutlet weak var lblArrival:UILabel!
    @IBOutlet weak var lblType:UILabel!
    @IBOutlet weak var btnViewDetails:UIButton!
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }

    static var name: String {
        return reuseIdentifier
    }

    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        self.btnViewDetails.setTitleColor(.appRed, for: .normal)
    }

    override func layoutSubviews() {
        super.layoutSubviews()
       
    }
    func resetCell() {
        self.btnViewDetails.isUserInteractionEnabled = false
        self.lblDate.text = nil
        self.lblTicketNum.text = nil
        self.lblDate.text = nil
        self.lblPrice.text = nil
        self.lblName.text = nil
        self.lblDeparture.text = nil
        self.lblArrival.text = nil
        self.lblType.text = nil
        
    }
    func fillData(booking:PGFlightBookingDetail) {
        ///if let value = booking.ord
        self.lblTicketNum.text = "Ticket No: \(String(describing: booking.control_number))"
        if let fname = booking.passengers.first?.firstName,let lname = booking.passengers.first?.lastName {
            self.lblName.text = "\(fname) \(lname)"
        }
        if let origin = booking.itinerary.first?.origin,let destination = booking.itinerary.last?.destination {
            self.lblDeparture.text = origin.code
            self.lblArrival.text = destination.code
        }
        if let price = booking.priceString {
            self.lblPrice.text = price
        }
        
        self.lblDate.text = Helpers.formattedDateFromString(dateString: booking.created_at, withFormat: "EEE, MMM dd, HH:mm",inputDateFormat: "yyyy-MM-dd HH:mm:ss")
        //self.lblType.text = "ONE WAY"
        self.lblType.text = nil
    }
    
}
