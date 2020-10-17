//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PlaceTimingsView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var stackView:UIStackView!
   
    
    class func getView() -> PlaceTimingsView {
        let view  = Bundle.main.loadNibNamed("PlaceTimingsView", owner: self, options: nil)!.first as! PlaceTimingsView
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    func setTiming(timings:[String]) {
        for timing in timings {
            let label = UILabel()
            label.text = timing
            label.font = UIFont(name: "Lato", size: 15)
            label.textColor = UIColor.darkGray
            self.stackView.addArrangedSubview(label)
        }
    }
    
}
