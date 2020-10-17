//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos

class PGHotelPaymentSummaryView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblRoomPrice:UILabel!
    @IBOutlet weak var lblRoomTitle:UILabel!
    @IBOutlet weak var lblRoomTaxNFees:UILabel!
    @IBOutlet weak var lblTotalPrice:UILabel!
    @IBOutlet weak var lblPriceInfo:UILabel!
    @IBOutlet weak var lblTotalPriceTitle:UILabel!
    @IBOutlet weak var btnCreditCard:TrajilisButton!
    @IBOutlet weak var btnApplePay:TrajilisButton!
    @IBOutlet weak var viewPaymentOptions:UIView!
    class func getView() -> PGHotelPaymentSummaryView {
        let view  = Bundle.main.loadNibNamed("PGHotelPaymentSummaryView", owner: self, options: nil)!.first as! PGHotelPaymentSummaryView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.btnCreditCard.bgColor = .appRed
        view.btnCreditCard.tag = 1
        view.btnApplePay.tag = 0
        view.btnCreditCard.setGradient = true
        view.lblTotalPrice.textColor = .appRed
        view.lblTotalPriceTitle.textColor = .appRed
        view.btnCreditCard.isSelected = true
        view.lblPriceInfo.text = nil
        return view
    }
    
    func fillValue(amount:PGHotelAmount) {
        
        let currencCode = CurrencyManager.shared.getSymbol(forCurrency: amount.currencyCode)
        self.lblRoomPrice.text = "\(currencCode)\(amount.amountBeforeTax.rounded(toPlaces: 2))"
        self.lblRoomTaxNFees.text = "\(currencCode)\(amount.getTax().rounded(toPlaces: 2))"
        self.lblTotalPrice.text = "\(currencCode)\(amount.amountAfterTax.rounded(toPlaces: 2))"
        
    }
    func setPayment(isCreditCard:Bool) {
        if isCreditCard {
            self.btnCreditCard.isSelected = true
            self.btnApplePay.isSelected = false
        } else {
            self.btnCreditCard.isSelected = false
            self.btnApplePay.isSelected = true
        }
        
        self.setButton(btn: self.btnApplePay)
        self.setButton(btn: self.btnCreditCard)
    }
    func setButton(btn:TrajilisButton) {
        if btn.isSelected {
            btn.bgColor = UIColor.appRed
            btn.imageView?.tintColor = .white
            btn.tintColor = .white
            btn.setTitleColor(UIColor.white, for: .normal)
            btn.setGradient = true
            
        } else {
            btn.bgColor = UIColor.white
            btn.imageView?.tintColor = .lightGray
            btn.tintColor = .gray
            btn.setTitleColor(UIColor.lightGray, for: .normal)
            btn.setGradient = false
        }
        
    }
    
}
