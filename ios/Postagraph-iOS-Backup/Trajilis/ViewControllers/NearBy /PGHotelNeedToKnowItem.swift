//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGHotelNeedToKnowItem: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    @IBOutlet weak var imgView1:UIImageView!
    @IBOutlet weak var lblItem1:UILabel!
    
    
    class func getView() -> PGHotelNeedToKnowItem {
        let view  = Bundle.main.loadNibNamed("PGHotelNeedToKnowItem", owner: self, options: nil)!.first as! PGHotelNeedToKnowItem
        view.translatesAutoresizingMaskIntoConstraints = false
        view.lblItem1.isHidden = false
        return view
    }
    
}
