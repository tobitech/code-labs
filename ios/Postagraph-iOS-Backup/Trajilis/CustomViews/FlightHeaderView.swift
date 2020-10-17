//
//  FlightHeaderView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 28/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FlightHeaderView: UIView {
    @IBOutlet var travelLocationLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var dateOfTravel: UILabel!
    @IBOutlet var coachLabel: UILabel!
    @IBOutlet var numberOfTravelerLabel: UILabel!

    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("FlightHeaderView", owner: self, options: nil)
        addSubview(contentView)
        contentView.fill()
    }

    func configure(dateOfTravel: String, flightClass: String, traveler: String, location: String) {
        self.dateOfTravel.text = dateOfTravel.uppercased()
        coachLabel.text = flightClass.uppercased()
        numberOfTravelerLabel.text = traveler.uppercased()
        travelLocationLabel.text = location.uppercased()
    }

}
