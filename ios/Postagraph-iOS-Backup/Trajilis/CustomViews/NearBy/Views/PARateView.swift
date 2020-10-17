//
//  PARateView.swift
//  Trajilis
//
//  Created by Perfect Aduh on 29/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit


//@IBDesignable

class PARateView: UIView {
    
    var rating: Int = 0
    fileprivate var starStack = [UIImageView]()
    var didTapStar: (() ->())?
    
    public override init(frame: CGRect) {
        super.init(frame: frame)
        updateView()
    }
    
    required public init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)!
        updateView()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateView()
    }
    
    @IBInspectable var numberOfStars: Int = 5 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var starWidth: CGFloat = 33 {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable var starHeight: CGFloat = 32 {
        didSet {
            updateView()
        }
    }
    
    override class var layerClass: AnyClass {
        get {
            return CAGradientLayer.self
        }
    }
    
    
    @objc private func handleStarTap() {
        self.didTapStar?()
    }
    
    
    private func updateView () {
        
        starStack.removeAll()
        subviews.forEach{$0.removeFromSuperview()}
        
        let columnWidth = frame.width / CGFloat(numberOfStars)
        
        for i in 0..<numberOfStars {
            
            let cell = UIView(frame: CGRect(x: CGFloat(i) * (columnWidth), y: 0, width: columnWidth, height: frame.height))
            addSubview(cell)
            
            let star = UIImageView(frame: CGRect(x : (cell.frame.width - starWidth)/2, y: (cell.frame.height - starHeight)/2, width: starWidth, height: starHeight))
            star.image = UIImage(named: "filled_star")?.withRenderingMode(.alwaysTemplate)
           // star.tintColor =  Color.secondaryColor
            cell.addSubview(star)
            starStack.append(star)
            let tap  = UITapGestureRecognizer(target: self, action: #selector(self.handleStarTap))
            star.addGestureRecognizer(tap)
            
            self.didTapStar = {
                if self.starStack.count == self.numberOfStars {
                    for j in 0..<self.starStack.count {
                        if j  <= self.rating - 1  {
                            self.starStack[j].image = UIImage(named: "filled_star")
                        }else{
                            self.starStack[j].image = UIImage(named: "outlined_star")
                        }
                    }
                }
            }
        }
    }
}

