//
//  ExploreViewModel.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/27/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation

class ExploreViewModel {
    
    var feeds = [Feed]()
    private var currentPage = 0
    private var limit = 50
    private var isLastContent = false
    private var isCallInProgress: Bool = false
    
    
    func fetchExploreFeeds(completion: @escaping (String?) -> ()) {
        guard Helpers.isLoggedIn(), !isCallInProgress else { return }
        
        isCallInProgress = true
        APIController.makeRequest(request: .feedsExplore(userId: Helpers.userId, count: currentPage, limit: limit)) { [weak self] (response) in
            
            guard let self = self else { return }
            
            self.isCallInProgress = false
            switch response {
            case .failure(_):
                completion(kDefaultError)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let feedDictArray = json?["feeds"] as? [JSONDictionary] else { return }
                let feeds = feedDictArray.map{ Feed.init(json: $0) }
                
                if feeds.count > 5 {
                    try? DataStorage.shared.dataStorage.setObject(result.data, forKey: EXPLORE_FEED_CACHE_KEY)
                }
                self.isLastContent = feeds.isEmpty
                if !feeds.isEmpty && feeds.count < self.limit {
                    self.isLastContent = true
                }
                if self.currentPage > 0 {
                    self.feeds.append(contentsOf: feeds)
                } else {
                    self.feeds = feeds
                }
                completion(nil)
            }
        }
    }
    
}
