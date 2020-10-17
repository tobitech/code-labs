//
//  GardientView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 12/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

public class GradientView: UIView {

    @IBInspectable var leftColor: UIColor = UIColor.init(hexString: "#F05964")
    @IBInspectable var rightColor: UIColor = UIColor.init(hexString: "#D11915")

    @IBInspectable var setGradient: Bool = false {
        didSet {
            if setGradient {
                removeSublayer()
                setColors()
                setDirection(Direction.Horizontal)
                bkgLayer!.cornerRadius = cRadius
            } else {
                removeSublayer()
            }
        }
    }

    @IBInspectable
    var borderColor: UIColor = UIColor.clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }

    @IBInspectable var cRadius: CGFloat = 0.0

    @IBInspectable
    var borderWidth: CGFloat = 0.0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }

    @IBInspectable
    var addShadow: Bool = false

    @IBInspectable
    var bgColor: UIColor = UIColor.white {
        didSet {
            backgroundColor = bgColor
        }
    }

    @IBInspectable
    var shadowColor: UIColor = UIColor.appRed {
        didSet {
            backgroundColor = bgColor
        }
    }

    public struct Direction {
        public static let Horizontal = "Horizontal"
        public static let Vertical = "Vertical"
    }

    public var bkgLayer:CAGradientLayer?

    override public func awakeFromNib() {
        super.awakeFromNib()

        self.backgroundColor = UIColor.black
    }

    public func setColors() {
        bkgLayer = CAGradientLayer()
        bkgLayer!.frame = self.bounds
        bkgLayer!.colors = [leftColor.cgColor, rightColor.cgColor]
        bkgLayer!.name = "bkgLayer"
        layer.masksToBounds = true
        layer.insertSublayer(bkgLayer!, at: 0)
    }

    public func setDirection(_ direction: String) {
        if direction == GradientView.Direction.Horizontal {
            bkgLayer?.startPoint = CGPoint(x: 0, y: 0.5)
            bkgLayer?.endPoint = CGPoint(x: 1, y: 0.5)
        } else {
            bkgLayer?.startPoint = CGPoint(x: 0.5, y: 0)
            bkgLayer?.endPoint = CGPoint(x: 0.5, y: 1)
        }
    }

    public func removeSublayer() {
        if let sublayers = layer.sublayers {
            for l in sublayers {
                if l.name == "bkgLayer" {
                    l.removeFromSuperlayer()
                }
            }
        }
    }

    override public func layoutSubviews() {
        super.layoutSubviews()
        if setGradient {
            removeSublayer()
            setColors()
            setDirection(Direction.Horizontal)
            bkgLayer!.cornerRadius = cRadius
        }
        backgroundColor = bgColor
        layer.cornerRadius = cRadius
        layer.masksToBounds = true
        if addShadow {
            layer.shadowColor = shadowColor.cgColor
            layer.shadowOffset = CGSize(width: 0.0, height: 2.0)
            layer.masksToBounds = false
            layer.shadowRadius = 1.0
            layer.shadowOpacity = 0.5
            layer.shadowPath = UIBezierPath(roundedRect: layer.bounds,
                                            cornerRadius: cRadius).cgPath
        }
    }

}
