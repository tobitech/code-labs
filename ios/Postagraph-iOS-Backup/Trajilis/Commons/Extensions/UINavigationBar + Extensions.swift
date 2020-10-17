//
//  UINavigationBar + Extensions.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/16/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

extension UINavigationBar {

    static func setWhiteAppearance() {
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.isTranslucent = false
        navBarAppearance.barTintColor = .white
    
        let font = UIFont(name: "PTSans-Bold", size: 16)!
        
        navBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor(hexString: "#3f3f3f"),
            NSAttributedString.Key.font: font]
        navBarAppearance.tintColor = UIColor(hexString: "#D63D41")
        navBarAppearance.backIndicatorImage = UIImage(named: "backIcon")
        navBarAppearance.backIndicatorTransitionMaskImage = UIImage(named: "backIcon")
        
        navBarAppearance.shadowImage = UIColor(hexString: "#f9f9f9").image()
        navBarAppearance.setBackgroundImage(UIColor.white.image(), for: .default)
    }
    
    static func setClearAppearance() {
        let navBarAppearance = UINavigationBar.appearance()
        navBarAppearance.shadowImage = UIColor.clear.image()
        navBarAppearance.setBackgroundImage(UIColor.clear.image(), for: .default)
        navBarAppearance.barTintColor = .clear
        navBarAppearance.isTranslucent = true
        
        let font = UIFont(name: "PTSans-Bold", size: 16)!
        navBarAppearance.titleTextAttributes = [
            NSAttributedString.Key.foregroundColor: UIColor.white,
            NSAttributedString.Key.font: font]
    }

}
