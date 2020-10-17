//
//  UIColor+Extensions.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

extension UIColor {
    
    class var appNewPlaceholderColor: UIColor {
        return UIColor(red: 56/255.0, green: 52/255.0, blue: 77/255.0, alpha: 0.5)
    }
    
    class var moderatePasswordBlue: UIColor {
        return UIColor(red: 59/255.0, green: 138/255.0, blue: 228/255.0, alpha: 1.0)
    }
    class var darkBlue: UIColor {
        return UIColor(red: 41/255.0, green: 100/255.0, blue: 148/255.0, alpha: 1.0)
    }
    class var clrGreen: UIColor {
        return UIColor(red: 45/255.0, green: 145/255.0, blue: 70/255.0, alpha: 1.0)
    }
    class var strongPasswordGreen: UIColor {
        return UIColor(red: 58/255.0, green: 203/255.0, blue: 7/255.0, alpha: 1.0)
    }
    
    class var appRed: UIColor {        
        return UIColor(red: 214/255.0, green: 61/255.0, blue: 65/255.0, alpha: 1.0)
    }
    
    class var disabledButtonRed: UIColor {
        return UIColor(red: 214/255.0, green: 61/255.0, blue: 65/255.0, alpha: 0.25)
    }
    
    class var appGrey: UIColor {
        return UIColor(red: 63/255.0, green: 63/255.0, blue: 63/255.0, alpha: 0.5)
    }
    
    class var backgroundLightGrey: UIColor {
        return UIColor(red: 249/255.0, green: 249/255.0, blue: 249/255.0, alpha: 1.0)
    }
    
    class var lineOffGrey: UIColor {
        return UIColor(red: 229/255.0, green: 229/255.0, blue: 229/255.0, alpha: 1.0)
    }
    
    class var appBlack: UIColor {
        return UIColor(red: 56/255.0, green: 52/255.0, blue: 77/255.0, alpha: 1)
    }
    
    class var defaultText: UIColor {
        return UIColor(red: 63/255.0, green: 63/255.0, blue: 63/255.0, alpha: 1.0)
    }
    
    class var textBlack: UIColor {
        return UIColor(red: 80/255.0, green: 80/255.0, blue: 80/255.0, alpha: 1.0)
    }
    
    class var appBG: UIColor {
        return UIColor(red: 246/255.0, green: 246/255.0, blue: 246/255.0, alpha: 1)
    }
    
    func image(size: CGSize =  CGSize(width: 1, height: 1)) -> UIImage? {
        UIGraphicsBeginImageContext(size)
        guard let ctx = UIGraphicsGetCurrentContext() else { return nil }
        self.setFill()
        ctx.fill(CGRect(origin: .zero, size: size))
        let image = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return image
    }
}

extension UIColor {
    convenience init(hexString: String, alpha: CGFloat = 1.0) {
        let hexString: String = hexString.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        let scanner = Scanner(string: hexString)
        if hexString.hasPrefix("#") {
            scanner.scanLocation = 1
        }
        var color: UInt32 = 0
        scanner.scanHexInt32(&color)
        let mask = 0x000000FF
        let redInt = Int(color >> 16) & mask
        let greenInt = Int(color >> 8) & mask
        let blueInt = Int(color) & mask
        let red   = CGFloat(redInt) / 255.0
        let green = CGFloat(greenInt) / 255.0
        let blue  = CGFloat(blueInt) / 255.0
        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }
    func toHexString() -> String {
        var red: CGFloat = 0
        var green: CGFloat = 0
        var blue: CGFloat = 0
        var alpha: CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        let rgb: Int = (Int)(red*255)<<16 | (Int)(green*255)<<8 | (Int)(blue*255)<<0
        return String(format: "#%06x", rgb)
    }
}
