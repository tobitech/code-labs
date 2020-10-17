//
//  CustomImageView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class CustomImageView: UIImageView {
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
    public var identifier : String = ""
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = backgroundClr
        self.layer.borderColor = borderColor.cgColor
        self.layer.borderWidth = borderWidth
        
    }

}
