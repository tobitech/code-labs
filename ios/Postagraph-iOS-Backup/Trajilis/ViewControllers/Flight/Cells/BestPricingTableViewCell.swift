//
//  BestPricingTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 01/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class BestPricingTableViewCell: UITableViewCell {

    @IBOutlet var fareLabel: UILabel!
    @IBOutlet var classNameLabel: UILabel!

    static var identifier: String {
        return String(describing: self)
    }

    func configure(best: BestPricing) {
        classNameLabel.text = best.flights.first?.bookingClass?.name
        fareLabel.text = "\(best.totalAmount?.currency ?? "") \(best.totalAmount?.amount ?? "")"
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
}
