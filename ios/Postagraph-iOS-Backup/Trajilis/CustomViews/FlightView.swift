//
//  FlightView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 27/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FlightView: UIView {

    @IBOutlet var layoverView: UIView!
    @IBOutlet var layoverDurationLabel: UILabel!
    @IBOutlet var flightClassLabel: UILabel!
    @IBOutlet var airlineLogoImageView: UIImageView!
    @IBOutlet var flightNumberLabel: UILabel!
    @IBOutlet var airlineLabel: UILabel!
    @IBOutlet var arrivalLocation: UILabel!
    @IBOutlet var departLocation: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var dateOfArrivalLabel: UILabel!
    @IBOutlet var timeOfArrivalLabel: UILabel!
    @IBOutlet var dateOfDepartureLabel: UILabel!
    @IBOutlet var timeOfDepartureLabel: UILabel!
    @IBOutlet var lblOperatedBy: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var layoverTopAndBottomConstraints: [NSLayoutConstraint]!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("FlightView", owner: self, options: nil)
        addSubview(contentView)
        contentView.fill()
    }

    func configure(with flight: Flight, noLayover: Bool) {
        if let logo = flight.operatingCompany?.logo, let url = URL(string:logo) {
            airlineLogoImageView.sd_setImage(with: url, completed: nil)
        }
        for constraint in layoverTopAndBottomConstraints {
            constraint.constant = noLayover ? 0 : 30
        }
        layoverView.isHidden = noLayover
//        flightClassLabel.text = "Econs"
        
        
        
        
        flightNumberLabel.text = "Flight \(flight.flightNumber)"
        airlineLabel.text = flight.operatingCompany?.full_name ?? ""
        
        if let arrlLoc = flight.arrivalAirport?.getLocation(),!arrlLoc.isEmpty,let iata = flight.arrivalAirport?.iata {
            arrivalLocation.text = "\(iata) - \(String(describing: arrlLoc))"
        }
        if let depLoc = flight.departureAirport?.getLocation(),!depLoc.isEmpty,let iata = flight.departureAirport?.iata {
            departLocation.text  = "\(iata) - \(String(describing: depLoc))"
        }
        self.lblOperatedBy.isHidden =  true
        if let mcompany = flight.marketingCompany, let ocompany = flight.operatingCompany, let name = ocompany.full_name, !name.isEmpty, mcompany.full_name != ocompany.full_name {
            self.lblOperatedBy.text = "Operated by \(ocompany.full_name ?? "")"
            self.lblOperatedBy.isHidden =  false
        }
        durationLabel.text = formatDuration(duration: flight.flightDuration)
        dateOfArrivalLabel.text = "\(Helpers.formattedDateFromString(dateString: flight.dateOfArrival, withFormat: "EEE, MMM dd"))"
        dateOfDepartureLabel.text = "\(Helpers.formattedDateFromString(dateString: flight.dateOfDeparture, withFormat: "EEE, MMM dd"))"
        timeOfArrivalLabel.text = Helpers.convertTimeFrom24hrsTo12hrs(date: flight.arrivalDate)
        timeOfDepartureLabel.text = Helpers.convertTimeFrom24hrsTo12hrs(date: flight.departureDate)
    }

    func formatDuration(duration: String) -> String {
        if duration.contains(".") {
            let components = duration.components(separatedBy: ".")
            return "\(components.first ?? "") h : \(components.last ?? "") m"
        }
        return "\(duration) mins"

    }

}
