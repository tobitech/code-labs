//
//  SettingsRepresentable.swift
//  Cloudy
//
//  Created by Bart Jacobs on 04/12/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

protocol SettingsRepresentable {

    var text: String { get }
    var accessoryType: UITableViewCellAccessoryType { get }

}
