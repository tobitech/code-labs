//
//  FlightSectionHeaderTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 27/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FlightSectionHeaderTableViewCell: UITableViewCell {

    @IBOutlet var gradView: GradientView!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var locationLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
