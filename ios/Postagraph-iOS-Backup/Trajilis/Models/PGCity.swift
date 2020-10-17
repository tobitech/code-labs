//
//  PGHotel.swift
//  Trajilis
//
//  Created by bharats802 on 15/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

struct PGCity {
    
    var cityId:String!
    var longitude:String!
    var code:String!
    var country_name:String!
    var state_short:String!
    var latitude:String!
    var city_photo:String!
    var name:String!
    var state_full:String!
    
    
    init(json: JSONDictionary) {
        cityId = json["_id"] as? String ?? ""
        longitude = json["longitude"] as? String ?? ""
        code = json["code"] as? String ?? ""
        country_name = json["country_name"] as? String ?? ""
        state_short = json["state_short"] as? String ?? ""
        latitude = json["latitude"] as? String ?? ""
        city_photo = json["city_photo"] as? String ?? ""
        name = json["name"] as? String ?? ""
        state_full = json["state_full"] as? String ?? ""
        if let locatonDict = json["location"] as? [String: Any],
        let coordinates = locatonDict["coordinates"] as? [Double],
            let long = coordinates.first, let lat = coordinates.last {
            longitude = "\(long)"
            latitude = "\(lat)"
        } else {
            longitude = ""
            latitude = ""
        }
    }
    
    
    
 
}
