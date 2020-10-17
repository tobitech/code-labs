//
//  UIColor.swift
//  ThreeRingControl
//
//  Created by Oluwatobi Omotayo on 31/03/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

public extension UIColor {
  var darkened: UIColor {
    var hue = CGFloat()
    var saturation = CGFloat()
    var brightness = CGFloat()
    var alpha = CGFloat()
    
    getHue(
      &hue,
      saturation: &saturation,
      brightness: &brightness,
      alpha: &alpha
    )
    
    return UIColor(
      hue: min(hue * 1.1, 1),
      saturation: saturation,
      brightness: brightness * 0.7,
      alpha: alpha
    )
  }
}
