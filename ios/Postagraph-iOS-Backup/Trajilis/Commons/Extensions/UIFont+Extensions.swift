//
//  UIFont+Extensions.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 31/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

extension UIFont {
    static func latoRegular(with size: CGFloat) -> UIFont {
        return UIFont(name:"Lato-Regular", size: size)!
    }
    
//    static func appCalibriLightFontWithSize(size: CGFloat) -> UIFont
//    {
//        return UIFont(name: "calibri-light", size: size)!
//    }
    
    static func latoBold(with size: CGFloat) -> UIFont {
        return UIFont(name:"Lato-Bold", size: size)!
    }
    
    static func latoBoldItalic(with size: CGFloat) -> UIFont {
        return UIFont(name:"Lato-BoldItalic", size: size)!
    }
    
    static func playfairDisplayBold(with size: CGFloat) -> UIFont {
        return UIFont(name: "PlayfairDisplay-Bold", size: size)!
    }
    
    static func ptSansBold(with size: CGFloat) -> UIFont {
        return UIFont(name:"PTSans-Bold", size: size)!
    }
    
    static func ptSansRegular(with size: CGFloat) -> UIFont {
        return UIFont(name:"PTSans-Regular", size: size)!
    }
}
