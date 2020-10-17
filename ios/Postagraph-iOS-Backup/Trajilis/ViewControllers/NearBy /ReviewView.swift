//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class ReviewView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var lblTime:UILabel!
    @IBOutlet weak var lblReview:UILabel!
    @IBOutlet weak var ratingView:CosmosView!
    @IBOutlet weak var imgView:UIImageView!
    
    class func getView() -> ReviewView {
        let view  = Bundle.main.loadNibNamed("ReviewView", owner: self, options: nil)!.first as! ReviewView
        view.translatesAutoresizingMaskIntoConstraints = false
        
        view.lblName.text = nil
        view.lblTime.text = nil
        view.lblReview.text = nil
        view.imgView.layer.cornerRadius = 20
        view.imgView.layer.borderColor = UIColor.appRed.cgColor
        view.imgView.layer.borderWidth = 1
        return view
    }
    
    
    
}
