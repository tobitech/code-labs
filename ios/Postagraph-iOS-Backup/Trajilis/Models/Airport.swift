//
//  Airport.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 06/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

struct Airport {

    static let RECENT_ORIGIN = "RECENT_ORIGIN"
    static let RECENT_DESTINATION = "RECENT_DESTINATION"

    let id: String
    let icao: String?
    let city: String
    let country: String?
    let elevation: String?
    let tz: String?
    let lon: Double?
    let iata: String
    let lat: Double?
    let name: String
    let state: String

    init(json: JSONDictionary) {
        id = json["_id"] as? String ?? ""
        icao = json["icao"] as? String ?? ""
        city = json["city_name"] as? String ??  json["city"] as? String ?? ""        
        country = json["country_name"] as? String ?? ""
        elevation = json["elevation"] as? String ?? ""
        var tz = json["tz"] as? String
        if tz == nil {
            tz = json["timezone"] as? String ?? ""
        }
        self.tz = tz
        lon = json["lon"] as? Double ?? 0
        iata = json["iata"] as? String ?? ""
        lat = json["lat"] as? Double ?? 0
        name = json["name"] as? String ?? ""
        state = json["state"] as? String ?? ""
    }

    func toObject() -> JSONDictionary {
        let dict = [
            "_id": id,
            "icao": icao ?? "",
            "country_name": country ?? "",
            "elevation": elevation ?? "",
            "tz": tz ?? "",
            "lon": lon ?? 0.0,
            "iata": iata,
            "lat": lat ?? 0.0,
            "name": name,
            "state": state,
            "city_name": city
            ] as [String : Any]
        return dict
    }

    func saveRecentLocation(key: String) {
        let data = NSKeyedArchiver.archivedData(withRootObject: self.toObject())
        UserDefaults.standard.set(data, forKey: key)
    }

    static func retrieveAirport(key: String) -> Airport? {
        if let data = UserDefaults.standard.data(forKey: key) {
            if let airportDict = NSKeyedUnarchiver.unarchiveObject(with: data) as? JSONDictionary {
                let airport = Airport(json: airportDict)
                return airport
            }
        }
        return nil
    }
    func getLocation() -> String {
        
        var location = ""
        if !self.city.isEmpty {            
            location.append(self.city)
        }
        if !self.state.isEmpty {
            if !location.isEmpty {
                location.append(", ")
            }
            location.append(self.state)
        }
        if !self.state.isEmpty {
            if !location.isEmpty {
                location.append(", ")
            }
            location.append(self.state)
        }
        if let cntry = self.country,!cntry.isEmpty {
            if !location.isEmpty {
                location.append(", ")
            }
            location.append(cntry)
        }
        if location.isEmpty {
            return "--"
        }
        return location
    }
}
