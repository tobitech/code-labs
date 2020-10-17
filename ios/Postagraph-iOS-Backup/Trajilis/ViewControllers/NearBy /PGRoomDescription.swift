//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGRoomDescription: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var lblPrice:UILabel!
    @IBOutlet weak var btnChange:UIButton!
    
    
    class func getView() -> PGRoomDescription {
        let view  = Bundle.main.loadNibNamed("PGRoomDescription", owner: self, options: nil)!.first as! PGRoomDescription
        view.lblPrice.textColor = .appRed
        view.btnChange.setTitleColor(.appRed, for: .normal)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func fillValue(room:PGHotelRoom) {
        self.lblDesc.text =  room.roomDescription
        let currency = CurrencyManager.shared.getSymbol(forCurrency: room.currencyCode)
        self.lblPrice.text =  "\(currency)\(room.totalFare)"
    }
    
}
