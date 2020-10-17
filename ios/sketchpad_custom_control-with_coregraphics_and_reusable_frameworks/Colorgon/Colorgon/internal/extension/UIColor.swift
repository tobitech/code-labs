//
//  UIColor.swift
//  Colorgon
//
//  Created by Oluwatobi Omotayo on 31/03/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//


import simd
import UIKit
extension UIColor {
    convenience init(unitCubeColor: SIMD3<Float>, value: Float) {
        let color = unitCubeColor * value
        self.init(
            _colorLiteralRed: color.x,
            green: color.y,
            blue: color.z,
            alpha: 1
        )
    }
}
