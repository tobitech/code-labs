//
//  Dimmable.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

public protocol Dimmable { }

public extension Dimmable where Self: UIViewController {
    public func dim(_ direction: Direction, color: UIColor = UIColor.black, alpha: CGFloat = 0.0, speed: Double = 0.0) {
        
        switch direction {
        case .in:
            
            // Create and add a dim view
            let dimView = UIView(frame: view.frame)
            dimView.backgroundColor = color
            dimView.alpha = 0.0
            view.addSubview(dimView)
            
            // Deal with Auto Layout
            dimView.translatesAutoresizingMaskIntoConstraints = false
            view.addConstraints(NSLayoutConstraint
                .constraints(withVisualFormat: "|[dimView]|", options: [],
                             metrics: nil, views: ["dimView": dimView]))
            view.addConstraints(NSLayoutConstraint
                .constraints(withVisualFormat: "V:|[dimView]|", options: [],
                             metrics: nil, views: ["dimView": dimView]))
            // Animate alpha (the actual "dimming" effect)
            UIView.animate(withDuration: speed, animations: { () -> Void in
                dimView.alpha = alpha
            })
        case .out:
            UIView.animate(withDuration: speed, animations: { () -> Void in
                self.view.subviews.last?.alpha = alpha
            }, completion: { (_) -> Void in
                self.view.subviews.last?.removeFromSuperview()
            })
        }
    }
}

extension UINavigationController: Dimmable {
    
}

extension UIViewController: Dimmable {
    
}
