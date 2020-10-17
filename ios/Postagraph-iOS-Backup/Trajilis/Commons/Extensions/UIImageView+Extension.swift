//
//  UIImageView+Extension.swift
//  Trajilis
//
//  Created by Moses on 25/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

extension  UIImageView {
    
    func style(_ containtView: UIView?=nil, cornerRadius: CGFloat?) {
        
        if let rad = cornerRadius {
            self.layer.cornerRadius = rad
        } else {
            self.layer.cornerRadius = self.bounds.height/2
        }
        
        self.layer.masksToBounds = true
        self.layer.shadowColor = UIColor.appRed.cgColor
        self.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        self.layer.masksToBounds = false
        self.layer.shadowRadius = 1.0
        self.layer.shadowOpacity = 1.0
        
        if let view = containtView {
            self.layer.shadowPath = UIBezierPath(roundedRect: view.layer.bounds,
                                                 cornerRadius: view.bounds.height/2).cgPath
        }
    }
    
    func makeRounded() {
        let radius = self.frame.width/2.0
        self.layer.cornerRadius = radius
        self.layer.masksToBounds = true
    }
}
