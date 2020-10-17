//
//  TripInviteTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 22/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class TripInviteTableViewCell: UITableViewCell {

    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var durationLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    var acceptBlock:(() -> Void)?
    var rejectBlock:(() -> Void)?

    static var identifier: String {
        return String(describing: self)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    func configure(trip: Trip) {
        nameLabel.text = trip.tripName
        locationLabel.text = trip.location
        descriptionLabel.text = trip.desc
        if !trip.endDate.isEmpty && !trip.startDate.isEmpty {
            let start = Helpers.timeStampToDateString(timeStamp: trip.startDate, format: "E, MMM d")
            let end = Helpers.timeStampToDateString(timeStamp: trip.endDate, format: "E, MMM d")
            durationLabel.text = "\(start) to \(end)"
        }        
    }

    @IBAction func acceptTapped(_ sender: Any) {
        acceptBlock?()
    }
    
    @IBAction func rejectTapped(_ sender: Any) {
        rejectBlock?()
    }
    
}
