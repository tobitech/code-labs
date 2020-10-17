//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGMyBookingsHeaderView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    
    @IBOutlet weak var btnUpcoming:TrajilisButton!
    @IBOutlet weak var btnCompleted:TrajilisButton!
    @IBOutlet weak var btnCancelled:TrajilisButton!
    
    
    class func getView() -> PGMyBookingsHeaderView {
        let view  = Bundle.main.loadNibNamed("PGMyBookingsHeaderView", owner: self, options: nil)!.first as! PGMyBookingsHeaderView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.btnUpcoming.isSelected = true
        //view.btnCancelled.isHidden = true
        view.btnUpcoming.cRadius = 18.5
        view.btnCompleted.cRadius = 18.5
        view.btnCancelled.cRadius = 18.5
        
        view.setupSelectedButton(sender:view.btnUpcoming)
        return view
    }
    
    func setupSelectedButton(sender:TrajilisButton) {
        self.btnUpcoming.isSelected = false
        self.btnCompleted.isSelected = false
        self.btnCancelled.isSelected = false
        
        sender.isSelected = true
        self.setButton(button: self.btnUpcoming)
        self.setButton(button: self.btnCompleted)
        self.setButton(button: self.btnCancelled)
    }
    func setButton(button:TrajilisButton) {
        if button.isSelected {
            button.bgColor = .appRed
            button.setGradient = true
            button.borderWidth = 0
            button.setTitleColor(.white, for: .normal)
        } else {
            button.borderWidth = 1
            button.borderColor = .appRed
            button.bgColor = .white
            button.setGradient = false
            button.setTitleColor(.gray, for: .normal)
        }
    }
}
