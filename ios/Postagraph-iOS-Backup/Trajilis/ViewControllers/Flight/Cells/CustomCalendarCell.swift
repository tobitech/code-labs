//
//  CustomCalendarCell.swift
//  Trajilis
//
//  Created by Oluwatobi Omotayo on 29/09/2019.
//  Copyright © 2019 Oluwatobi Omotayo. All rights reserved.
//

import Foundation
import UIKit
import FSCalendar

enum DateSelectionType: Int {
    case none
    case single
    case leftBorder
    case middle
    case rightBorder
}

class CustomCalendarCell: FSCalendarCell {
    weak var selectionLayer: CAShapeLayer!
    
    var selectionType: DateSelectionType = .none {
        didSet {
            setNeedsLayout()
        }
    }
    
    required init!(coder aDecoder: NSCoder!) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init!(frame: CGRect) {
        super.init(frame: frame)
        
        let selectionLayer = CAShapeLayer()
        selectionLayer.fillColor = UIColor.appRed.cgColor
        selectionLayer.actions = ["hidden": NSNull()]
        self.contentView.layer.insertSublayer(selectionLayer, below: self.titleLabel!.layer)
        self.selectionLayer = selectionLayer
        
        self.shapeLayer.isHidden = true
        
        let view = UIView(frame: self.bounds)
        view.makeCornerRadius(cornerRadius: 4.0)
        view.backgroundColor = UIColor(hexString: "#F6F6F6")
        self.backgroundView = view
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.backgroundView?.frame = self.bounds.insetBy(dx: 4, dy: 4)
        self.selectionLayer.frame = self.contentView.bounds.insetBy(dx: 4, dy: 4)
        
        if selectionType == .middle {
            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds, cornerRadius: 4.0).cgPath
        } else if selectionType == .leftBorder {
            
            let leftRadius = CGSize(width: 16, height: 16)
            let rightRadius = CGSize(width: 4, height: 4)
            self.selectionLayer.path = UIBezierPath(shouldRoundRect: self.selectionLayer.bounds, topLeftRadius: leftRadius, topRightRadius: rightRadius, bottomLeftRadius: leftRadius, bottomRightRadius: rightRadius).cgPath
        } else if selectionType == .rightBorder {
            let rightRadius = CGSize(width: 16, height: 16)
            let leftRadius = CGSize(width: 4, height: 4)
            self.selectionLayer.path = UIBezierPath(shouldRoundRect: self.selectionLayer.bounds, topLeftRadius: leftRadius, topRightRadius: rightRadius, bottomLeftRadius: leftRadius, bottomRightRadius: rightRadius).cgPath
        } else if selectionType == .single {
            self.selectionLayer.path = UIBezierPath(roundedRect: self.selectionLayer.bounds, cornerRadius: 4.0).cgPath
        }
    }
    
    override func configureAppearance() {
        super.configureAppearance()
        if self.isPlaceholder {
            self.titleLabel.textColor = UIColor(hexString: "#ECECEC")
            self.backgroundView?.backgroundColor = UIColor(hexString: "#FCFCFC")
        } else {
            self.backgroundView?.backgroundColor = UIColor(hexString: "#F6F6F6")
        }
    }
    
}
