//
//  SearchView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 01/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class SearchView: UIView {

    @IBOutlet var headerLabel: UILabel!
    @IBOutlet var contentView: UIView!
    @IBOutlet var containerView: UIView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var suggestedButton: UILabel!

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
        
        for subview in searchBar.subviews.last!.subviews {
            if subview.isKind(of: NSClassFromString("UISearchBarTextField")!) {
                for v in subview.subviews {
                    if v.isKind(of: NSClassFromString("_UISearchBarSearchFieldBackgroundView")!) {
                        v.removeFromSuperview()
                    }
                }
            }
        }
        
//        containerView.layer.cornerRadius = 25
//        containerView.layer.borderColor = UIColor.init(red: 10/255.0, green: 31/255.0, blue: 68/255.0, alpha: 0.1).cgColor
//        containerView.layer.borderWidth = 1
//        containerView.clipsToBounds = true
//        containerView.layer.shadowColor = UIColor.init(red: 10/255.0, green: 31/255.0, blue: 68/255.0, alpha: 0.1).cgColor
//        containerView.layer.shadowOffset = CGSize(width: 5.0, height: 5.0)
//        containerView.layer.masksToBounds = false
//        containerView.layer.shadowRadius = 1.0
//        containerView.layer.shadowOpacity = 0.5
//        containerView.layer.shadowPath = UIBezierPath(roundedRect: containerView.bounds,
//                                                            cornerRadius: containerView.layer.cornerRadius).cgPath
        suggestedButton.layer.cornerRadius = suggestedButton.bounds.height/2
        suggestedButton.layer.masksToBounds = true
    }

    private func commonInit() {
        Bundle.main.loadNibNamed("SearchView", owner: self, options: nil)
        addSubview(contentView)
        contentView.fill()
    }
}
