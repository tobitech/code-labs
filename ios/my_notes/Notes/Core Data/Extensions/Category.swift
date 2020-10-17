//
//  Category.swift
//  Notes
//
//  Created by Bart Jacobs on 07/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

extension Category {

    var color: UIColor? {
        get {
            guard let hex = colorAsHex else { return nil }
            return UIColor(hex: hex)
        }

        set(newColor) {
            if let newColor = newColor {
                colorAsHex = newColor.toHex
            }
        }
    }

}
