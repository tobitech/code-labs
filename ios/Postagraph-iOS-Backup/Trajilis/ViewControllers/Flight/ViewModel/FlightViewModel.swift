//
//  FlightViewModel.swift
//  Trajilis
//
//  Created by Perfect Aduh on 03/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation

class FlightViewModel {
    
    let lng = "\(UserDefaults.standard.double(forKey: "longitude"))"
    let lat = "\(UserDefaults.standard.double(forKey: "latitude"))"
    var airportSearchComplete: ((String?, Airport?)->())?
    
    var airports = [Airport]()
    
    init() {
        
    }
    
    func airportSearchByLocation() {
        
        APIController.makeRequest(request: .airportByLatLong(lat: lat, lng: lng)) { [weak
            self](response) in
            guard let `self` = self else { return }
            switch response {
            case .failure(let error):
                self.airportSearchComplete?(error.desc, nil)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary, let data = json?["data"] as? [JSONDictionary] else { return }
                self.airports = data.compactMap{ Airport.init(json: $0) }

                if self.airports.count > 0 {
                    self.airportSearchComplete?(nil, self.airports[0])
                }
            }
        }
        
    }
}
