//
//  MyFlightBookingTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 9/23/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class MyFlightBookingTableViewCell: UITableViewCell {

    @IBOutlet weak var outbountNamelabel: UILabel!
    @IBOutlet weak var inboundNameLabel: UILabel!
    @IBOutlet weak var outboundDateLabel: UILabel!
    @IBOutlet weak var inboundDateLabel: UILabel!
    @IBOutlet var inBounds: [UIView]!
    @IBOutlet var outBoundBottomConstraint: NSLayoutConstraint!
    @IBOutlet var inBoundBottomConstraint: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        outbountNamelabel.superview?.set(borderWidth: 1, of: UIColor(hexString: "#E5E5E5"))
        outbountNamelabel.superview?.set(cornerRadius: 4)
    }
    
    func set(booking: PGFlightBookingDetail?) {
        outbountNamelabel.text = ""
        if let outbound = booking?.itinerary.first {
            let outboundOriginAirport = outbound.origin?.name ?? ""
            let outboundDestinationAirport = outbound.destination?.name ?? ""
            outbountNamelabel.text = outboundOriginAirport + " to " + outboundDestinationAirport
            outboundDateLabel.text = outbound.segments.first?.arrivalDateTime.toString(dateFormat: "EEE, MMM d")
        }
        
        if booking?.itinerary.count ?? 0 > 1 {
            inBounds.forEach({$0.isHidden = false})
            outBoundBottomConstraint.isActive = false
            inBoundBottomConstraint.isActive = true
            if let inbound = booking?.itinerary.last {
                let inboundOriginAirport = inbound.origin?.name ?? ""
                let inboundDestinationAirport = inbound.destination?.name ?? ""
                inboundNameLabel.text = inboundOriginAirport + " to " + inboundDestinationAirport
                inboundDateLabel.text = inbound.segments.first?.arrivalDateTime.toString(dateFormat: "EEE, MMM d")
            }
        }else {
            outBoundBottomConstraint.isActive = true
            inBoundBottomConstraint.isActive = false
            inBounds.forEach({$0.isHidden = true})
        }
        contentView.layoutIfNeeded()
    }
    
    @IBAction func shareToTripTapped(_ sender: Any) {
    }
    
}
