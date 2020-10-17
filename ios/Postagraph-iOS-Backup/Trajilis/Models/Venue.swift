//
//  Venue.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 14/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

struct Venue {
    let name: String
    let id: String
    var searchPlaceIcon: String
    let location: Location?


}

extension Venue {
    init(json: JSONDictionary) {
        searchPlaceIcon = ""
        /*
         I have no idea what is this
         I have no idea what is the purpose
         For the sake of time and my sanity
         I will leave it the way it is
         Previous developer code:
         let tempArr : NSArray! = (dict.value(forKey: "categories")) as! NSArray
         let tempDict : NSDictionary! = tempArr[0] as! NSDictionary
         let strPrefix: String = ((tempDict.value(forKey: "icon") as! NSDictionary).value(forKey: "prefix")) as! String
         let strSuffix: String = ((tempDict.value(forKey: "icon") as! NSDictionary).value(forKey: "suffix")) as! String
         print(strPrefix)
         print(strSuffix)
         let searchPlaceIcon = String(describing: ("\(strPrefix)512\(strSuffix)"))
         */
        if let categories = json["categories"] as? [JSONDictionary] {
            if let category = categories.first {
                if let icon = category["icon"] as? JSONDictionary {
                    if let prefix = icon["prefix"] as? String, let suffix = icon["suffix"] as? String {
                        searchPlaceIcon = "\(prefix)512\(suffix)"
                    }
                }
            }
        }
        name = json["name"] as? String ?? ""
        id = json["id"] as? String ?? ""
        if let dict = json["location"] as? JSONDictionary {
            location = Location.init(json: dict)
        } else {
            location = nil
        }
    }
}

struct Location {
    let cc: String?
    let city: String?
    let country: String?
    let distance: Double?
    let address: String?
    let formattedAddress: [String]?
    let lat: String?
    let lng: String?
    let state: String?
}

extension Location {
    init(json: JSONDictionary) {
        cc = json["cc"] as? String
        city = json["city"] as? String
        address = json["address"] as? String
        country = json["country"] as? String
        distance = json["distance"] as? Double
        formattedAddress = json["formattedAddress"] as? [String]
        lat = json["lat"] as? String
        lng = json["lng"] as? String
        state = json["state"] as? String
    }
}
