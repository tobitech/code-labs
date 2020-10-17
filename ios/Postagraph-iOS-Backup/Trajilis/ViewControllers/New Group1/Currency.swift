//
//  Currency.swift
//  Trajilis
//
//  Created by Moses on 08/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation


struct Currency {
    var countryId = ""
    var countryName = ""
    var currency = ""
    var currencySymbol = ""
    var sortName = ""
    var teleCountry = ""
    
    init(_ json: JSONDictionary) {
        self.countryId = json["country_id"] as? String ?? ""
        self.countryName = json["country_name"] as? String ?? ""
        self.currency = json["currency"] as? String ?? ""
        self.currencySymbol = json["currency_symbol"] as? String ?? ""
        self.sortName = json["sort_name"] as? String ?? ""
        self.teleCountry = json["tele_country_code"] as? String ?? ""
    }
}
