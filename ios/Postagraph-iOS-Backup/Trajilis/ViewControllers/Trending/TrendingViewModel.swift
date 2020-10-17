//
//  TrendingViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 13/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

final class TrendingViewModel {

    var currentPage = 0
    var limit = 10
    var isLastCount = false
    var reload: (() -> ())?
    var lng = "0"
    var lat = "0"

    var places = [CondensedPlace]()

    func load(isMore: Bool = false) {
        if isMore {
            currentPage += limit
        } else {
            places.removeAll()
        }
        getTrendingLocations()
    }

    private func getTrendingLocations() {
        APIController.makeRequest(request: .trendingLocation(text: "all", lng: lng, lat: lat, count: currentPage, limit: limit)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    self.reload?()
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["locations"] as? [JSONDictionary] else { return }
                    print(data)
                    let places = data.compactMap{ CondensedPlace.init(json: $0) }
                    self.places.append(contentsOf: places)
                    self.reload?()
                }
            }
        }
    }
}
