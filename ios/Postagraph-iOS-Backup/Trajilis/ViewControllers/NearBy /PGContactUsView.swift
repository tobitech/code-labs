//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGContactUsView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    class func getView() -> PGContactUsView {
        let view  = Bundle.main.loadNibNamed("PGContactUsView", owner: self, options: nil)!.first as! PGContactUsView
        view.translatesAutoresizingMaskIntoConstraints = false        
        return view
    }
    
}
