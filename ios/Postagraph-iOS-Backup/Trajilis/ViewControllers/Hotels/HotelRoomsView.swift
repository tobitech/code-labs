//
//  HotelCheckInOutView.swift
//  Trajilis
//
//  Created by bharats802 on 16/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class HotelRoomsView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var lblRooms:UILabel!
    @IBOutlet weak var btnRoomAdd:TrajilisButton!
    @IBOutlet weak var btnRoomMinus:TrajilisButton!
    
    @IBOutlet weak var viewRooms:UIView!
    

    
    class func getView() -> HotelRoomsView {
        let view  = Bundle.main.loadNibNamed("HotelRoomsView", owner: self, options: nil)!.first as! HotelRoomsView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.setupControls()
        return view
    }
    func setupControls() {
        self.lblRooms.text = "1"
        self.lblRooms.textColor = .appRed
        self.btnRoomAdd.backgroundColor = .appRed
        self.btnRoomMinus.backgroundColor = .appRed
        self.btnRoomMinus.setGradient = true
        self.btnRoomAdd.setGradient = true
    }
    
}
