//
//  Place.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 22/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

final class Place {
    let id: String
    let lastFeedImage: String
    let distance: String
    let feedCount: Int
    let rating: Double
    let icon: String
    let name: String
    
    init(json: JSONDictionary) {
        self.id = json["place_id"] as? String ?? ""
        self.lastFeedImage = json["last_place_feed_image"] as? String ?? ""
        self.distance = json["place_distance"] as? String ?? ""
        self.feedCount = json["place_feed_count"] as? Int ?? 0
        self.rating = json["place_rating"] as? Double ?? 0
        self.icon = json["place_icon"] as? String ?? ""
        self.name = json["place_name"] as? String ?? ""
    }
}
