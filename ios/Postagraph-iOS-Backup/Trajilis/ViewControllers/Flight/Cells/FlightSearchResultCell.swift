//
//  FlightSearchResultCell.swift
//  Trajilis
//
//  Created by user on 04/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SDWebImage

class FlightSearchResultCell: UITableViewCell {
    
    @IBOutlet weak var cheapestLbl: UILabel!
    @IBOutlet weak var airlineNameLbl: UILabel!
    @IBOutlet weak var airlineLogoImV: UIImageView!
    @IBOutlet weak var classLbl: UILabel!
    @IBOutlet weak var dateLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var duraionLbl: UILabel!
    @IBOutlet weak var amountLbl: UILabel!
    @IBOutlet weak var nonStopLbl: UILabel!
    
    var flightDetails: FlightDetails! {
        didSet {
            airlineNameLbl.text = flightDetails.flightInfo?.first?.operatingDetails.fullName
            if let urlString = flightDetails.flightInfo?.first?.marketingDetails.logoSmall {
                airlineLogoImV.sd_setImage(with: URL(string: urlString), completed: nil)
            }
            duraionLbl.text = "\(flightDetails.duration ?? "")h"
            amountLbl.text = "\(CurrencyManager.shared.getUserCurrencySymbol())\(flightDetails.amount ?? "")"
            timeLbl.text = "\(flightDetails.flightInfo?.first?.timeOfDeparture ?? "") - \(flightDetails.flightInfo?.first?.timeOfArrival ?? "") "
            
            if let count = flightDetails.flightInfo?.count {
                if count == 1 {
                    nonStopLbl.text = "Non-Stop"
                } else if count > 1 {
                    nonStopLbl.text = "\(count - 1) Stop"
                }
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
