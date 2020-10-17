//
//  AirportSelectionTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 06/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class AirportSelectionTableViewCell: UITableViewCell {

    static let kIdentifier = "AirportSelectionTableViewCell"
    @IBOutlet var cityLabel: UILabel!
    @IBOutlet var airportLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    func configure(airport: Airport) {
        cityLabel.text = airport.city
        airportLabel.text = airport.name
    }
    func configure(city: PGCity) {
        cityLabel.text = city.name
        airportLabel.text = !city.state_full.isEmpty ? city.state_full : city.country_name
    }

    func configure(venue: Venue) {
        cityLabel.text = venue.name
        if let address = venue.location?.address {
            airportLabel.text = address
        } else if let city = venue.location?.city {
            airportLabel.text = city
        } else if let formattedAddress = venue.location?.formattedAddress {
            airportLabel.text = formattedAddress.first
        }
    }

}
