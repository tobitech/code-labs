//
//  HeaderWithLineView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 31/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit


class HeaderWithLineView: UIView {

    @IBOutlet var contentView: UIView!
    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var subHeaderLabel: UILabel!
    
    @IBOutlet var lineView: UIView!
    
    @IBInspectable var headerFontSize: CGFloat = 24 {
        didSet {
            headerLabel.font = UIFont.ptSansBold(with: headerFontSize)
        }
    }
    
    @IBInspectable var subHeaderFontSize: CGFloat = 16 {
        didSet {
            subHeaderLabel.font = UIFont.ptSansRegular(with: subHeaderFontSize)
        }
    }
    
    @IBInspectable var headerText: String = "" {
        didSet {
            headerLabel.text = headerText
        }
    }
    
    @IBInspectable var subHeaderText: String = "" {
        didSet {
            subHeaderLabel.text = subHeaderText
        }
    }
        
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        lineView.layer.cornerRadius = lineView.layer.bounds.height/2
        lineView.layer.masksToBounds = true
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("HeaderWithLineView", owner: self, options: nil)
        addSubview(contentView)
        contentView.fill()
    }
}
