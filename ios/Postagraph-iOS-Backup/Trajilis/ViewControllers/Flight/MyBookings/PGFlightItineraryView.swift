//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGFlightItineraryView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var lblTitle:UILabel!
    
    @IBOutlet weak var stackView:UIStackView!
    @IBOutlet weak var imgView:UIImageView!
    
    class func getView() -> PGFlightItineraryView {
        let view  = Bundle.main.loadNibNamed("PGFlightItineraryView", owner: self, options: nil)!.first as! PGFlightItineraryView
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    
}
