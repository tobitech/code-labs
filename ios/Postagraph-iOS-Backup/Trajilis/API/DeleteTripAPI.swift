//
//  DeleteTripAPI.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/17/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation

protocol DeleteTripAPI {
    
}

extension DeleteTripAPI {
    
    func deleteTrip(trip: Trip, userId: String, success: @escaping () -> (), failure: @escaping (String) -> ()) {
        APIController.makeRequest(request: .deleteTrip(tripId: trip.tripId, userId: userId)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(let e):
                    failure(e.desc)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary,
                        let status = meta["status"] as? String, status == "200" else {
                            failure(kDefaultError)
                            return
                    }
                    success()
                }
            }
        }
    }
    
}
