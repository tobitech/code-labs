//
//  PGHotelAmount.swift
//  Trajilis
//
//  Created by bharats802 on 24/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

struct PGHotelAmount {
   
    var amountAfterTax:Double = 0
    var currencyCode:String = ""
    var amountBeforeTax:Double = 0
    var priceInfo: String?
    init(json: JSONDictionary) {
        
        if let value = json["amountAfterTax"] as? Double {
            amountAfterTax = value
        }
        if let value = json["amountBeforeTax"] as? Double {
            amountBeforeTax = value
        }
        currencyCode = json["currencyCode"] as? String ?? ""
        
    }
    func getTax() -> Double {
        return self.amountAfterTax - self.amountBeforeTax
    }
}
