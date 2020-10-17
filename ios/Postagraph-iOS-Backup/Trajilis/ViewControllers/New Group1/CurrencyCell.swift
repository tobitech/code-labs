//
//  CurrencyCell.swift
//  Trajilis
//
//  Created by Moses on 07/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class CurrencyCell: UITableViewCell {
    static let name = "CurrencyCell"
    @IBOutlet weak var name : UILabel!
    @IBOutlet weak var toggle : UISwitch!
    
    var off : Bool = false {
        didSet {
            if off {
                toggle.setOn(false, animated: true)
            }
        }
    }
    
    var handle : ((IndexPath, Currency, Bool) -> Void)?
    var currency : Currency! {
        didSet {
            name.text = currency.countryName
        }
    }
    var indexPath : IndexPath!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    @IBAction private func toggle(_ event: UISwitch) {
        handle?(indexPath, currency, event.isOn)
    }
}
