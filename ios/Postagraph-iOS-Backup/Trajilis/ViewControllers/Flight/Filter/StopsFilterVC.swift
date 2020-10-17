//
//  StopsFilterVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 21/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class StopsFilterVC: BaseVC {
    @IBOutlet var twoStopsSwitch: UISwitch!
    @IBOutlet var oneStopSwitch: UISwitch!
    @IBOutlet var nonStopSwitch: UISwitch!

    var stops = FlightType.all

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flight Stops"
        switch stops {
        case .nonStop:
            nonStopSwitch.isOn = true
        case .connecting:
            oneStopSwitch.isOn = true
        default:
            break
        }
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        twoStopsSwitch.isOn = sender == twoStopsSwitch
        oneStopSwitch.isOn = sender == oneStopSwitch
        nonStopSwitch.isOn = sender == nonStopSwitch
        selectedStops()
    }

    public func selectedStops() {
        if nonStopSwitch.isOn {
            stops = FlightType.nonStop
        }

        if oneStopSwitch.isOn {
            stops = FlightType.connecting
        }

        if twoStopsSwitch.isOn {
            stops = FlightType.all
        }
    }

}
