//
//  CabinClassFilterVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 21/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class CabinClassFilterVC: BaseVC {
    @IBOutlet var economySwitch: UISwitch!
    @IBOutlet var premiumSwitch: UISwitch!
    @IBOutlet var businessSwitch: UISwitch!
    @IBOutlet var firstSwitch: UISwitch!

    var cabin = FlightClass.economy

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Cabon Class"
        switch cabin {
        case .business:
            businessSwitch.isOn = true
        case .economy:
            economySwitch.isOn = true
        case .premium:
            premiumSwitch.isOn = true
        case .first:
            firstSwitch.isOn = true
        default:
            break
        }
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        economySwitch.isOn = sender == economySwitch
        premiumSwitch.isOn = sender == premiumSwitch
        businessSwitch.isOn = sender == businessSwitch
        firstSwitch.isOn = sender == firstSwitch
        selectedCabin()
    }

    func selectedCabin()  {
        if economySwitch.isOn {
            cabin = FlightClass.economy
        }

        if premiumSwitch.isOn {
            cabin = FlightClass.premium
        }

        if businessSwitch.isOn {
            cabin = FlightClass.business
        }

        if firstSwitch.isOn {
            cabin = FlightClass.first
        }

    }
    
}
