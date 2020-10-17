//
//  SettingsViewUnitsViewModel.swift
//  Cloudy
//
//  Created by Bart Jacobs on 01/12/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

struct SettingsViewUnitsViewModel {

    // MARK: - Properties

    let unitsNotation: UnitsNotation

    // MARK: - Public Interface

    var text: String {
        switch unitsNotation {
        case .imperial: return "Imperial"
        case .metric: return "Metric"
        }
    }

    var accessoryType: UITableViewCellAccessoryType {
        if UserDefaults.unitsNotation() == unitsNotation {
            return .checkmark
        } else {
            return .none
        }
    }

}

extension SettingsViewUnitsViewModel: SettingsRepresentable {

}
