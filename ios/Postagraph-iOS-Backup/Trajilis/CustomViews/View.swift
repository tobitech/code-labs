//
//  View.swift
//  Trajilis
//
//  Created by Moses on 29/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

//@IBDesignable
class View : UIView {
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
    
    @IBInspectable
    public var backgroundClr: UIColor = UIColor.black.withAlphaComponent(0.4) {
        didSet {
            self.backgroundColor = backgroundClr
        }
    }

    @IBInspectable
    var addShadow: Bool = false

    @IBInspectable
    var shadowColor: UIColor = UIColor.appRed
    
    @IBInspectable
    public var identifier : String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = backgroundClr
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        if addShadow {
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            layer.masksToBounds = false
            layer.shadowRadius = 1.0
            layer.shadowOpacity = 0.5
            layer.shadowPath = UIBezierPath(roundedRect: layer.bounds,
                                            cornerRadius: cornerRadius).cgPath
        }
    }
    
}
