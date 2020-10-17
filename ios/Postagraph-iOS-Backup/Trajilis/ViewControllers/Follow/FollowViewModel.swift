//
//  FollowViewModel.swift
//  Trajilis
//
//  Created by Moses on 25/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

enum TableType {
    case feedViewers(feedId: String)
    case likers(feedId: String)
    case pins(feedId: String)
    case follow(type: FollowType)
    case friend

    var isRemoteSearch: Bool {
        switch self {
        case .friend:
            return true
        default:
            return false
        }
    }
}

class FollowViewModel {

    var reload:(() -> Void)?
    var followers = [Followers]()
    var filteredFollowers = [Followers]()
    let limit = 100
    let type: TableType!
    var currentPage = 0
    var isLastContent = false
    var searchText = ""
    var isSearching = false
    var searchPlaceHolderText: String  {
        switch type! {
        case .follow(let type):
            switch type {
            case .follower: return "Search followers"
            case .following: return "Search followings"
            }
        case .likers:
            return "Search likers"
        case .feedViewers(let feedId):
            return "Search viewers"
        case .friend:
            return "Search friend"
        case .pins:
            return "Search pinner"
        }
    }

    var userId = ""

    var title: String {
        switch type! {
        case .follow(let type):
            return type.rawValue.capitalized
        case .likers:
            return "Likes"
        case .feedViewers(let feedId):
            return "Viewed"
        case .friend:
            return "Search Friend"
        case .pins:
            return "Pinners"
        }
    }

    init(type: TableType, userId: String = Helpers.userId) {
        self.type = type
        self.userId = userId
        loadData()
    }

    func loadData(isLoadingMore: Bool = false) {
        if isLoadingMore {
            currentPage += limit
        }
        switch type! {
        case .likers(let feedId):
            getLikers(feedId: feedId, isLoadingMore: isLoadingMore)
        case .follow(let type):
            getFollow(type: type, isLoadingMore: isLoadingMore)
        case .feedViewers(let feedId):
            getFeedViewer(feedId: feedId, isLoadingMore: isLoadingMore)
        case .friend:
            if isSearching {
                searchUser(searchText: searchText, isLoadingMore: isLoadingMore)
            } else {
                getSuggestedFriends(isLoadingMore: isLoadingMore)
            }
        case .pins(let feedId):
            getPins(feedId: feedId, isLoadingMore: isLoadingMore)
        }
    }

    func search(text: String) {
        switch type! {
        case .friend:
            if text.isEmpty {
                getSuggestedFriends(isLoadingMore: false)
            } else {
                searchUser(searchText: text)
            }
        default:
            filteredFollowers = followers.filter({ (follower) -> Bool in
                return follower.username.lowercased().contains(text.lowercased())
            })
            reload?()
        }
    }

    private func searchUser(searchText: String, isLoadingMore: Bool = false) {
        APIController.makeRequest(request: .searchUsers(searchParam: searchText, count: currentPage, limit: limit)) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                if let data = json?["data"] as? [JSONDictionary] {
                    let followers = data.compactMap({ Followers.init(json: $0) })
                    self.isLastContent = followers.isEmpty
                    if isLoadingMore {
                        self.followers.append(contentsOf: followers)
                    } else {
                        self.followers = followers
                    }
                }
                self.reload?()
            }
        }
    }

    private func getSuggestedFriends(isLoadingMore: Bool = false) {
        APIController.makeRequest(request: .getSuggestion(count: currentPage, limit: limit)) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                if let data = json?["suggetion"] as? [JSONDictionary] {
                    let followers = data.compactMap({ Followers.init(json: $0) })
                    self.isLastContent = followers.isEmpty
                    if isLoadingMore {
                        self.followers.append(contentsOf: followers)
                    } else {
                        self.followers = followers
                    }
                }
                self.reload?()
            }
        }
    }

    private func getLikers(feedId: String, isLoadingMore: Bool = false) {
        APIController.makeRequest(request: .likes(feed: feedId, count: currentPage, limit: limit)) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                if let data = json?["data"] as? [JSONDictionary] {
                    let followers = data.compactMap({ Followers.init(json: $0) })
                    self.isLastContent = followers.isEmpty
                    if isLoadingMore {
                        self.followers.append(contentsOf: followers)
                    } else {
                        self.followers = followers
                    }
                }
                self.reload?()
            }
        }
    }
    
    private func getPins(feedId: String, isLoadingMore: Bool = false) {
           APIController.makeRequest(request: .pins(feed: feedId, count: currentPage, limit: limit)) { (response) in
               switch response {
               case .failure(_):
                   self.reload?()
               case .success(let result):
                   guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                   if let data = json?["data"] as? [JSONDictionary] {
                       let followers = data.compactMap({ Followers.init(json: $0) })
                       self.isLastContent = followers.isEmpty
                       if isLoadingMore {
                           self.followers.append(contentsOf: followers)
                       } else {
                           self.followers = followers
                       }
                   }
                   self.reload?()
               }
           }
       }
    
    private func getFeedViewer(feedId: String, isLoadingMore: Bool = false) {
        if isLoadingMore {
            currentPage += limit
        }
        
        let api = TrajilisAPI.getFeedViewers(feedId: feedId, userId: Helpers.userId)
        
        APIController.makeRequest(request: api) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    self.reload?()
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                    if let data = json?["data"] as? [JSONDictionary] {
                        let followers = data.compactMap({ Followers.init(json: $0) })
                        self.isLastContent = followers.isEmpty
                        if isLoadingMore {
                            self.followers.append(contentsOf: followers)
                        } else {
                            self.followers = followers
                        }
                    }
                    self.reload?()
                }
            }
        }
 
    }
    private func getFollow(type: FollowType, isLoadingMore: Bool = false) {
        if isLoadingMore {
            currentPage += limit
        }
        let api = type == .follower ? TrajilisAPI.getFollowers(otherUserId: userId, count: currentPage, limit: limit) : TrajilisAPI.getFollowing(otherUserId: userId, count: currentPage, limit: limit)
        
        APIController.makeRequest(request: api) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    self.reload?()
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                    if let data = json?["data"] as? [JSONDictionary] {
                        let followers = data.compactMap({ Followers.init(json: $0) })
                        self.isLastContent = followers.isEmpty
                        if isLoadingMore {
                            self.followers.append(contentsOf: followers)
                        } else {
                            self.followers = followers
                        }
                    }
                    self.reload?()
                }
            }
        }
    }
    
    @discardableResult
    func follow(follower: Followers) -> Bool {
        var delete: Bool = false
        if userId == Helpers.userId, follower.status, case .follow(let type) = self.type!, type == .following  {
            if let index = followers.firstIndex(where: {$0.userId == follower.userId}) {
                followers.remove(at: index)
            }
            if let index = filteredFollowers.firstIndex(where: {$0.userId == follower.userId}) {
                filteredFollowers.remove(at: index)
            }
            delete = true
        }
        let status = follower.status ? "false" : "true"
        follower.status = !follower.status
        APIController.makeRequest(request: .follow(follower: userId, following: follower.userId, status: status)) { (_) in
            Helpers.getCurrentUser()
        }
        return delete
    }
}
