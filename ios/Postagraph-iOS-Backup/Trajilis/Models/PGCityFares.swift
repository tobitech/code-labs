//
//  PGCityFares.swift
//  Trajilis
//
//  Created by bharats802 on 10/05/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation
class PGCityFares {
    var nearestAirport:[Airport] = [Airport]()
    var exploreCities:[PGExploreCity] = [PGExploreCity]()
    init(json: JSONDictionary) {

        if let nAirport = json["nearestAirport"] as? [JSONDictionary],nAirport.count > 0 {
            for airportData in nAirport {
                let airport = Airport(json: airportData)
                nearestAirport.append(airport)
            }
        }
        
        if let cities = json["exploreCities"] as? [String:Any] {
            for key in cities.keys {
                if let cityInfo = cities[key] as? JSONDictionary {
                    let city = PGExploreCity(json: cityInfo)
                    exploreCities.append(city)
                }
            }
        }
        exploreCities.sort { (city1, city2) -> Bool in
            if city1.name < city2.name {
                return true
            }
            return false
        }
    }
}
class PGExploreCity {
    var _id:String! = ""
    var code:String! = ""
    var name:String! = ""
    var state_full:String! = ""
    var city_photo:String! = ""
    var timezone:String! = ""
    var country_name:String! = ""
    var flightDetails:FlightSearchResult?
    
    init(json: JSONDictionary) {     
        if let cityInfo = json["cityInformation"] as? JSONDictionary {
            _id = cityInfo["_id"] as? String ?? ""
            code = cityInfo["code"] as? String ?? ""
            name = cityInfo["name"] as? String ?? ""
            state_full = cityInfo["state_full"] as? String ?? ""
            city_photo = cityInfo["city_photo"] as? String ?? ""
            timezone = cityInfo["timezone"] as? String ?? ""
            country_name = cityInfo["country_name"] as? String ?? ""
        }
        if let flightInformation = json["flightInformation"] as? JSONDictionary {
            flightDetails = FlightSearchResult(json: flightInformation, index: 0)
        }
    }
}
