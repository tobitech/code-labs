//
//  FeedViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
let EXPLORE_FEED_CACHE_KEY = "EXPLORE_FEED_CACHE_KEY"
let TERMINAL_FEED_CACHE_KEY = "TERMINALFEEDCACHEKEY"
let MY_PROFILE_FEED_CACHE_KEY = "MYPROFILEFEEDCACHE"
let MY_LIKED_FEED_CACHE_KEY = "MYLIKEDFEEDCACHEKEY"

enum VideoListType {
    case places(id: String)
    case terminal
    case profile(id: String)
    case hash(tag: String)
    case likedFeed
    case singleFeed(feedId: String)
    case othersPlaces(id:String)
    case withFeeds(feeds: [Feed])
    case memories(id:String)
    
    var id: String {
        switch self {
        case .profile(let id), .places(let id),.memories(let id):
            return id
        default:
            return ""
        }
    }
}

final class FeedViewModel {
    
    var feeds = [Feed]()
    var selectedFeedIndex: Int = 0
    var reload:(() -> ())?
    var currentPage = 0
    var limit = 30
    var isLastContent = false
    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
    var updateNotification:((String?) -> ())?
    var updateMessageCount:((String?) -> ())?
    var spamReport:(() -> ())?
    
    var loadedPlace:((Place) -> ())?
    var isCallInProgress:Bool = false
    var user: User?
    let type: VideoListType
    var otherUserId: String
    var tripId:String?
    
    
    init(type: VideoListType) {
        self.type = type
        otherUserId = type.id
 
        guard let isConnected = Network.reachability?.isConnectedToNetwork else {
            fetchRemoteFeeds()
            return
        }
        
        if !isConnected {
            fetchCachedFeeds()
            return
        }
        fetchRemoteFeeds()
    }
    
    func fetchRemoteFeeds() {
        switch type {
        case .othersPlaces(let id):
            fetchOtherUserRemoteFeed(id: id)
        case .places(let id):
            fetchRemotePlaceFeeds(id: id)
        case .profile(let id):
            getUser(otherUserId: id)
        case .terminal:
            fetchTerminalFeed()
        case .hash(let tag):
            fetchHashTagFeeds(tag: tag)
        case .likedFeed:
            fetchRemoteLikedFeed()
        case .singleFeed(let feedId):
            getFeed(id: feedId)
        case .memories(let id):
            fetchRemoteMemoriesFeeds(id: id)
        case .withFeeds(let feeds):
            self.feeds = feeds
            self.reload?()
        
        }
    }
    
    func fetchCachedFeeds() {
        switch type {
        case .profile(let id):
            if id == Helpers.userId {
                fetchCachedUserFeeds(id: id)
            }
        case .terminal:
            fetchCachedTerminalFeeds()
        case .likedFeed:
            fetchCachedLikedFeed()
        default:
            break
        }
    }
    
    func loadMore() {
        if Network.reachability?.status == .unreachable { return }
        
        if isCallInProgress {
            return
        }
        
        currentPage += limit
        switch type {
        case .othersPlaces(let id):
            fetchOtherUserRemoteFeed(id: id)
        case .places(let id):
            fetchRemotePlaceFeeds(id: id)
        case .profile:
            fetchUserFeed()
        case .terminal:
            fetchTerminalFeed()
        case .hash(let tag):
            fetchHashTagFeeds(tag: tag)
        case .likedFeed:
            fetchRemoteLikedFeed()
        default:
            break
        }
    }
    
    func like(feed: Feed) {
        guard let user = appDelegate?.user else {
            return
        }
        let param = [
            "entity_id": feed.id,
            "user_id": user.id,
            "user_image": user.profileImage,
            "user_name": user.username,
            "value": feed.likeStatus
        ]
        APIController.makeRequest(request: .likeFeed(param: param)) { (_) in
            
        }
    }
    
    func repostToPosta(feed: Feed, completion: @escaping ((String?) -> ())) {
        guard let user = appDelegate?.user else {
            return
        }
        APIController.makeRequest(request: .repostFeed(userId: user.id, feedId: feed.id)) { (response) in
            switch response {
            case .failure(_):
                completion("Request failed. Try again later.")
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else { return }
                if let status = meta["status"] as? String, status == "200" {
                    completion(nil)
                }
            }
        }
    }
    
    func delete(feed: Feed, completion: @escaping ((String?) -> ())) {
        guard let user = appDelegate?.user else {
            completion("Request failed. Try again later.")
            return
        }
        APIController.makeRequest(request: .deleteFeed(feedId: feed.id, userId: user.id)) { (response) in
            switch response {
            case .failure(_):
                completion("Request failed. Try again later.")
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else { return }
                if let status = meta["status"] as? String, status == "200" {
                    if let idx = self.feeds.firstIndex(where: { feed.id == $0.id }) {
                        self.deleteCachedTerminalFeeds(id: feed.id)
                        self.feeds.remove(at: idx)
                        completion(nil)
                    }
                }
            }
        }
    }
    
    func hide(feed: Feed) {
        guard let user = appDelegate?.user else { return }
        APIController.makeRequest(request: .hideFeed(feedId: feed.id, userId: user.id)) { (response) in
            switch response {
            case .failure(_):
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else { return }
                if let status = meta["status"] as? String, status == "200" {
                    if let idx = self.feeds.firstIndex(where: { feed.id == $0.id }) {
                        self.deleteCachedTerminalFeeds(id: feed.id)
                        self.feeds.remove(at: idx)
                        self.reload?()
                    }
                }
            }
        }
    }
    
    func report(user: User) {
        APIController.makeRequest(request: .report(feedId: user.id, userId: Helpers.userId, type: "user")) { (_) in }
    }
    
    func report(feed: Feed, completion: @escaping ((String) -> ())) {
        guard let user = appDelegate?.user else { return }
        APIController.makeRequest(request: .report(feedId: feed.id, userId: user.id, type: "feed")) { (response) in
            switch response {
            case .failure(_):
                completion(kDefaultError)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else {
                        completion(kDefaultError)
                        return
                }
                if let status = meta["status"] as? String, status == "200" {
                    completion(("Thanks, we have been notified of this post."))
                } else {
                    completion(kDefaultError)
                }
            }
        }
    }
    
    func follow(followerId: String, followingId: String, status: String) {
        APIController.makeRequest(request: .follow(follower: followerId, following: followingId, status: status)) { (_) in
            Helpers.getCurrentUser()
        }
    }
    
    func likeProfile(userId: String, status: String) {
        guard let user = appDelegate?.user else { return }
        let parameters = [
            "entity_id": userId,
            "user_id": user.id,
            "user_image": user.profileImage,
            "user_name": user.username,
            "value": status
        ]
        
        APIController.makeRequest(request: .likeProfile(param: parameters)) { (_) in
            
        }
    }
    
    func uploadProfileVideo(videoUrl: String, videoThumbnailUrl: String?, completion: @escaping ()->()) {
        let param = [
            "video_url": videoUrl,
            "video_thumb_url": videoThumbnailUrl ?? "",
            "user_id": Helpers.userId
        ]
        APIController.makeRequest(request: .uploadProfileVideo(param: param), completion: { (_) in
            completion()
        })
    }
    
    func pin(feed:Feed, toTrip: Trip, completion: @escaping (() -> ())) {
        
        let feedId = feed.id
        let tripId = toTrip.tripId
        
        let param = [
            "user_id": Helpers.userId,
            "entity_id": feedId,
            "trip_id":tripId
        ]
        feed.pinStatus = "true"
        feed.pinCount = "\((Int(feed.pinCount) ?? 0) + 1)"
        APIController.makeRequest(request: .pinFeedToTrip(param: param)) { (_) in
            completion()
        }
    }
    
    func markFeedViewed(feedId:String, completion: @escaping ()->()) {
        let param = [
            "user_id": Helpers.userId,
            "entity_id": feedId
        ]
        
        APIController.makeRequest(request: .addFeedViewCount(param: param)) { (_) in
            completion()
        }
    }
    
}

//Mark:- Terminal
extension FeedViewModel {
    
    fileprivate func fetchTerminalFeed() {
        guard let isConnected = Network.reachability?.isConnectedToNetwork,isConnected else {
            fetchCachedTerminalFeeds()
            return
        }
        fetchRemoteTerminalFeeds()
    }
    
    func fetchCachedTerminalFeeds() {
        DataStorage.shared.dataStorage.async.object(forKey: TERMINAL_FEED_CACHE_KEY) { (result) in
            switch result {
            case .error(_):
                self.reload?()
            case .value(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary {
                    if let feedDictArray = json?["feeds"] as? [JSONDictionary] {
                        self.feeds = feedDictArray.map{ Feed.init(json: $0) }
                        self.reload?()
                    }
                }
            }
        }
    }
    func deleteCachedTerminalFeeds(id:String) {
        DataStorage.shared.dataStorage.async.object(forKey: TERMINAL_FEED_CACHE_KEY) { (result) in
            switch result {
            case .error(_):
                    break
            case .value(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary {
                    if let feedDictArray = json?["feeds"] as? [JSONDictionary] {
                        let feeds = feedDictArray.filter({ (data) -> Bool in
                            if let feedid = data["id"] as? String,feedid != id {
                                return true
                            }
                            return false
                        })
                        do {
                            let jsond = try JSONSerialization.data(withJSONObject:["feeds":feeds], options: [])
                            try? DataStorage.shared.dataStorage.setObject(jsond, forKey: TERMINAL_FEED_CACHE_KEY)
                        } catch {
                            print(error)
                        }
                    }
                }
            }
        }
    }
    
    func fetchRemoteTerminalFeeds() {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        
        isCallInProgress = true
        APIController.makeRequest(request: .feeds(userId: id, count: currentPage, limit: limit)) { (response) in
            
            self.isCallInProgress = false
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let feedDictArray = json?["feeds"] as? [JSONDictionary] else { return }
                let feeds = feedDictArray.map{ Feed.init(json: $0) }
                if feeds.count > 5 {
                    try? DataStorage.shared.dataStorage.setObject(result.data, forKey: TERMINAL_FEED_CACHE_KEY)
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
                self.reload?()
            }
        }
    }
}

//Mark:- Profile
extension FeedViewModel {
    fileprivate func getUser(otherUserId: String) {
        
        guard let id = UserDefaults.standard.string(forKey: USERID) else {
            self.reload?()
            return
        }
        APIController.makeRequest(request: .getUser(userId: id, otherUserId: otherUserId)) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? JSONDictionary else { return }
                self.user = User.init(json: data)
                self.reload?()
            }
            self.fetchUserRemoteFeed()
        }
    }
    
    fileprivate func getCachedUser() {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
        self.user = user
    }
    
    fileprivate func fetchUserFeed() {
        fetchUserRemoteFeed()
    }
    
    func fetchCachedUserFeeds(id: String) {
        getCachedUser()
        DataStorage.shared.dataStorage.async.object(forKey: MY_PROFILE_FEED_CACHE_KEY) { (result) in
            switch result {
            case .error(_):
                self.reload?()
            case .value(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary {
                    if let feedDictArray = json?["feeds"] as? [JSONDictionary] {
                        self.feeds = feedDictArray.map{ Feed.init(json: $0) }
                        self.reload?()
                    }
                }
                
            }
        }
    }
    
    fileprivate func fetchOtherUserRemoteFeed(id:String) {
        
        isCallInProgress = true
        APIController.makeRequest(request: .userFeed(otherUserId: id, count: currentPage, limit: limit)) { (response) in
            
            self.isCallInProgress = false
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let feedDictArray = json?["feeds"] as? [JSONDictionary] else { return }
                let feeds = feedDictArray.map{ Feed.init(json: $0) }
                try? DataStorage.shared.dataStorage.setObject(result.data, forKey: MY_PROFILE_FEED_CACHE_KEY)
                self.isLastContent = feeds.isEmpty
                if self.currentPage > 0 {
                    self.feeds.append(contentsOf: feeds)
                } else {
                    self.feeds = feeds
                }
                self.reload?()
            }
        }
    }
    fileprivate func fetchUserRemoteFeed() {
        isCallInProgress = true
        APIController.makeRequest(request: .userFeed(otherUserId: type.id, count: currentPage, limit: limit)) { (response) in
            self.isCallInProgress = false
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let feedDictArray = json?["feeds"] as? [JSONDictionary] else { return }
                let feeds = feedDictArray.map{ Feed.init(json: $0) }
                try? DataStorage.shared.dataStorage.setObject(result.data, forKey: MY_PROFILE_FEED_CACHE_KEY)
                self.isLastContent = feeds.isEmpty
                if self.currentPage > 0 {
                    self.feeds.append(contentsOf: feeds)
                } else {
                    self.feeds = feeds
                }
                self.reload?()
            }
        }
    }
    
    func blockUser(userId: String, completion: @escaping (() -> ())) {
        APIController.makeRequest(request: .blockUser(blockUserId: userId)) { (_) in
            completion()
        }
    }
}

//Mark:- Places
extension FeedViewModel {
    func fetchRemotePlaceFeeds(id: String) {
        if id.isEmpty {
            fetchUserFeed()
        } else {
            isCallInProgress = true
            APIController.makeRequest(request: .placeFeed(placeId: id, count: currentPage, limit: limit)) { (response) in
                
                self.isCallInProgress = false
                switch response {
                case .failure(_):
                    self.reload?()
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let feedDictArray = json?["feeds"] as? [JSONDictionary],
                        let locationDict = json?["location"] as? JSONDictionary else { return }
                    let feeds = feedDictArray.map{ Feed.init(json: $0) }
                    let place = Place.init(json: locationDict)
                    self.loadedPlace?(place)
                    self.isLastContent = feeds.isEmpty
                    if self.currentPage > 0 {
                        self.feeds.append(contentsOf: feeds)
                    } else {
                        self.feeds = feeds
                    }
                    self.reload?()
                }
            }
        }
        
    }
    func fetchRemoteMemoriesFeeds(id: String) {
        if let tripid = self.tripId {
            APIController.makeRequest(request: .getTripMemories(userid:id,tripId: tripid, count: 0, limit: 1000)) { (response) in
                switch response {
                case .failure(_):
                    self.reload?()
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let feedDictArray = json?["feeds"] as? [JSONDictionary] else { return }
                    let feeds = feedDictArray.map{ Feed.init(json: $0) }
                    self.isLastContent = feeds.isEmpty
                    if self.currentPage > 0 {
                        self.feeds.append(contentsOf: feeds)
                    } else {
                        self.feeds = feeds
                    }
                    self.reload?()
                }
            }
        }
    }
}

//Mark:- HashTag
extension FeedViewModel {
    func fetchHashTagFeeds(tag: String) {
        isCallInProgress = true
        APIController.makeRequest(request: .hashTagFeed(hashTag: tag, count: currentPage, limit: limit)) { (response) in
            self.isCallInProgress = false
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let feedDictArray = json?["feeds"] as? [JSONDictionary] else { return }
                let feeds = feedDictArray.map{ Feed.init(json: $0) }
                self.isLastContent = feeds.isEmpty
                if self.currentPage > 0 {
                    self.feeds.append(contentsOf: feeds)
                } else {
                    self.feeds = feeds
                }
                self.reload?()
            }
        }
    }
}

//Mark:- Liked Feed
extension FeedViewModel {
    fileprivate func fetchRemoteLikedFeed() {
        isCallInProgress = true
        APIController.makeRequest(request: .getLikedFeed(userId: Helpers.userId, count: currentPage, limit: limit)) { (response) in
            self.isCallInProgress = false
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let feedDictArray = json?["feeds"] as? [JSONDictionary] else { return }
                let feeds = feedDictArray.map{ Feed.init(json: $0) }
                if feeds.count > 5 {
                    try? DataStorage.shared.dataStorage.setObject(result.data, forKey: MY_LIKED_FEED_CACHE_KEY)
                }
                self.isLastContent = feeds.isEmpty
                if self.currentPage > 0 {
                    self.feeds.append(contentsOf: feeds)
                } else {
                    self.feeds = feeds
                }
                self.reload?()
            }
        }
    }
    
    fileprivate func fetchCachedLikedFeed() {
        DataStorage.shared.dataStorage.async.object(forKey: MY_LIKED_FEED_CACHE_KEY) { (result) in
            switch result {
            case .error(_):
                self.reload?()
            case .value(let data):
                if let json = try? JSONSerialization.jsonObject(with: data, options: []) as? JSONDictionary {
                    if let feedDictArray = json?["feeds"] as? [JSONDictionary] {
                        self.feeds = feedDictArray.map{ Feed.init(json: $0) }
                        self.reload?()
                    }
                }
                
            }
        }
    }
}


//Mark:- Single Feed

extension FeedViewModel {
    fileprivate func getFeed(id: String) {
        APIController.makeRequest(request: .getFeed(feedId: id)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(let e):
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? JSONDictionary else { return }
                    let feed = Feed.init(json: data)
                    self.feeds = [feed]
                    self.reload?()
                }
            }
        }
    }
}
