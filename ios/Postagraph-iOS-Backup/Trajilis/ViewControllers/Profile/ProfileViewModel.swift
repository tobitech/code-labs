//
//  ProfileViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class Pagination {
    var isCallInProgress: Bool = false
    var isLastContent: Bool = false
    var currentPage: Int = 0
    var limit: Int = 100
}

final class ProfileViewModel {
    
    enum Mode {
        case memories, likedFeeds
    }
    
    let isCurrentUser: Bool
    var userId: String
    var user: User?
    
    var reload:(() -> Void)?

    var inviteCount = "0"
    var mode: Mode = .memories
    var isCompleteProfile: Bool = false
    
    private var memoriesPagination = Pagination()
    private var tripsPagination = Pagination()
    private var likedFeedsPagination = Pagination()
    
    var feeds: [Feed] {
        return mode == .memories ? memoriesFeeds : likedFeeds
    }
    private var memoriesFeeds: [Feed] = []
    private var likedFeeds: [Feed] = []
    private var trips = [Trip]()
    
    init(userId: String) {
        self.isCurrentUser = userId == Helpers.userId
        self.userId = userId
        getUser()
        getMemories()
        tripsPagination.limit = 1000
//        getTripList(inviteCode: "ACCEPTED")
    }

//    func getPendingInviteCount() {
//        APIController.makeRequest(request: .pendingTripInvite) { (response) in
//            switch response {
//            case .failure(_):
//                break
//            case .success(let result):
//                guard let json = try? result.mapJSON() as? JSONDictionary,
//                let data = json?["data"] as? JSONDictionary,
//                let count = data["count"] as? String else { return }
//                self.inviteCount = count
//                self.reload?()
//            }
//        }
//    }

    func getUser() {
        APIController.makeRequest(request: .getUser(userId: Helpers.userId, otherUserId: userId)) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? JSONDictionary else { return }
                self.user = User.init(json: data)
                if self.userId == Helpers.userId {
                    kAppDelegate.user = self.user
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

    func follow(followerId: String, followingId: String, status: String) {
        APIController.makeRequest(request: .follow(follower: followerId, following: followingId, status: status)) { (_) in
            Helpers.getCurrentUser()
        }
    }

    func likeProfile(userId: String, status: String) {
        guard let user = user else { return }
        let parameters = [
            "entity_id": userId,
            "user_id": Helpers.userId,
            "user_image": user.profileImage,
            "user_name": user.username,
            "value": status
        ]

        APIController.makeRequest(request: .likeProfile(param: parameters)) { (_) in
            
        }
    }

    func report(user: User) {
        APIController.makeRequest(request: .report(feedId: user.id, userId: Helpers.userId, type: "user")) { (_) in }
    }
    
    func getMemories() {
        if memoriesPagination.isCallInProgress || memoriesPagination.isLastContent {
            return
        }
        memoriesPagination.isCallInProgress = true
        APIController.makeRequest(request: .userFeed(otherUserId: userId, count: memoriesPagination.currentPage, limit: memoriesPagination.limit)) { (response) in
            self.memoriesPagination.isCallInProgress = false
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let feedDictArray = json?["feeds"] as? [JSONDictionary] else { return }
                let feeds = feedDictArray.map{ Feed.init(json: $0) }
//                try? DataStorage.shared.dataStorage.setObject(result.data, forKey: MY_PROFILE_FEED_CACHE_KEY)
                self.memoriesPagination.isLastContent = feeds.count < self.memoriesPagination.limit
                if self.memoriesPagination.currentPage > 0 {
                    self.memoriesFeeds.append(contentsOf: feeds)
                } else {
                    self.memoriesFeeds = feeds
                }
                self.memoriesPagination.currentPage += 1
                self.reload?()
            }
        }
    }
    
    func fetchRemoteLikedFeed() {
        if likedFeedsPagination.isCallInProgress || likedFeedsPagination.isLastContent {
            return
        }
        likedFeedsPagination.isCallInProgress = true
        APIController.makeRequest(request: .getLikedFeed(userId: userId, count: likedFeedsPagination.currentPage, limit: likedFeedsPagination.limit)) { (response) in
            self.likedFeedsPagination.isCallInProgress = false
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
                self.likedFeedsPagination.isLastContent = feeds.count < self.likedFeedsPagination.limit
                if self.likedFeedsPagination.currentPage > 0 {
                    self.likedFeeds.append(contentsOf: feeds)
                } else {
                    self.likedFeeds = feeds
                }
                self.likedFeedsPagination.currentPage += 1
                self.reload?()
            }
        }
    }
    
    func follow(followingId: String, status: String) {
        guard let user = user else {return}
        user.followingStatus = status
        if status == "true" {
            user.followingCount = "\((Int(user.followingCount) ?? 0) + 1)"
        }else {
            user.followingCount = "\((Int(user.followingCount) ?? 0) - 1)"
        }
        APIController.makeRequest(request: .follow(follower: Helpers.userId, following: followingId, status: status)) { (_) in
            Helpers.getCurrentUser()
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
    
    func uploadProfileImage(url: String, completion: @escaping () ->()) {
        let param = [
            "image_url": url,
            "user_id": Helpers.userId
        ]
        APIController.makeRequest(request: .uploadProfileImage(param: param), completion: { (_) in
            completion()
        })
    }
    
}
