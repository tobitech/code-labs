//
//  TrajilisNavigationBar.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 30/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class TrajilisNavigationBar: UINavigationBar {

    override func layoutSubviews() {
        super.layoutSubviews()
        hideBottomHairline()
        for subview in self.subviews {
            
            let stringFromClass = NSStringFromClass(subview.classForCoder)
            if stringFromClass.contains("UINavigationBarLargeTitleView") {
                subview.backgroundColor = UIColor.white
            }
        }
    }

}
