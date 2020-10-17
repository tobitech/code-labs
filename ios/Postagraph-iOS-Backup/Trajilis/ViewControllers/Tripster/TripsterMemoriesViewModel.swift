//
//  TripsterMemoriesViewModel.swift
//  Trajilis
//
//  Created by bibek timalsina on 7/17/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

final class TripsterMemoriesViewModel {
    
    let userId: String
    let trip: Trip
    var reload: (() -> Void)?
    
    var memories = [Feed]()
    var isLastContent = false
    var isLastContentPins = false
    
    var currentPage = 0
    var limit = 100
    
    init(userId: String, trip: Trip, isPublic: Bool = false) {
        self.userId = userId
        self.trip = trip
        getTripMemmories()
    }
    
    func getTripMemmories(isLoadingMore: Bool = false) {
        if !isLoadingMore {
            currentPage = 0
            memories.removeAll()
        } else {
            currentPage += limit
        }
        
        APIController.makeRequest(request: .getTripMemories(userid:userId, tripId: trip.tripId, count: currentPage, limit: limit)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["feeds"] as? [JSONDictionary] else { return }
                    let feeds = data.compactMap{ Feed.init(json: $0) }
                    self.isLastContent = data.isEmpty
                    self.memories.append(contentsOf: feeds)
                    self.reload?()
                }
            }
        }
    }
    
}
