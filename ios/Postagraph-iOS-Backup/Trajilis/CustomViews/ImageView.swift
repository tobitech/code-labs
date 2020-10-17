//
//  ImageView.swift
//  Trajilis
//
//  Created by Moses on 29/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

//@IBDesignable
class ImageView : UIImageView {
    @IBInspectable
    public var cornerRadius: CGFloat = 0.0 {
        didSet {
            self.layer.cornerRadius = cornerRadius
        }
    }
    
    @IBInspectable
    public var borderWidth: CGFloat = 0.0 {
        didSet {
            self.layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    public var borderColor: UIColor = UIColor.clear {
        didSet {
            self.layer.borderColor = borderColor.cgColor
        }
    }
}
