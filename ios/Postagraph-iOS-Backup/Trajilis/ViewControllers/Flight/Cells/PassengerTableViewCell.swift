//
//  PassengerTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 27/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PassengerTableViewCell: UITableViewCell {

    @IBOutlet var infantStackView: UIStackView!
    @IBOutlet var childStackView: UIStackView!
    @IBOutlet var infantCountLabel: UILabel!
    @IBOutlet var childFareLabel: UILabel!
    @IBOutlet var childClassLabel: UILabel!
    @IBOutlet var childCountLabel: UILabel!
    @IBOutlet var fareLabel: UILabel!
    @IBOutlet var classLabel: UILabel!
    @IBOutlet var adultsCountLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(outgoing: FlightSearchResult, incoming: FlightSearchResult? = nil, cabinClass:FlightClass) {
        let adult = outgoing.details.first(where: { $0.passengerType == "ADT" })?.totalPassenger ?? 0
        let child = outgoing.details.first(where: { $0.passengerType == "CH" })?.totalPassenger ?? 0
        let infant = outgoing.details.first(where: { $0.passengerType == "INF" })?.totalPassenger ?? 0

        adultsCountLabel.text = "\(adult) Adult"

        if let incoming = incoming {
            fareLabel.text = "\(kUserCurrencySymbol)\(incoming.totalAggAmount.rounded(toPlaces: 2))"
        } else {
            fareLabel.text = "\(kUserCurrencySymbol)\(outgoing.totalAggAmount.rounded(toPlaces: 2))"
        }

        let children = child > 0 ? "Children" : "Child"
        childCountLabel.text = "\(child) \(children)"

        infantCountLabel.text = "\(infant) Infant"

        childStackView.isHidden = child == 0
        infantStackView.isHidden = infant == 0

//        let code = outgoing.details.first?.cabin ?? ""
        classLabel.text = cabinClass.abbr.capitalized

    }

}
