//
//  Country.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 01/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

struct Country {
    let id: String
    let name: String
    let currency: String
    let symbol: String
    let sortName: String
    let dialCode: String
    
}

extension Country {
    init(json: JSONDictionary) {
        id = json["country_id"] as? String ?? ""
        name = json["country_name"] as? String ?? ""
        currency = json["currency"] as? String ?? ""
        symbol = json["currency_symbol"] as? String ?? ""
        sortName = json["sort_name"] as? String ?? ""
        dialCode = json["tele_country_code"] as? String ?? ""
    }
    
    var countryFlag: URL? {
        let urlString = "http://www.geonames.org/flags/x/\(sortName.lowercased()).\("gif")"
        return URL(string: urlString)
    }
}

extension String {
    var countryFlag: URL? {
        let urlString = "http://www.geonames.org/flags/x/\(self).\("gif")"
        return URL(string: urlString)
    }
}


struct State {
    let id: String
    let name: String
}

extension State {
    init(json: JSONDictionary) {
        id = json["state_id"] as? String ?? ""
        name = json["state_name"] as? String ?? ""
    }
}


struct City {
    let id: String
    let name: String
}

extension City {
    init(json: JSONDictionary) {
        id = json["city_id"] as? String ?? ""
        name = json["city_name"] as? String ?? ""
    }
}
