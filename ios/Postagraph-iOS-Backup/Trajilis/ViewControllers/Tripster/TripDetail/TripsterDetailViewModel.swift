//
//  TripsterDetailViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

enum kTripDetailTab: Int {
    case AllMemories, Pins
}

final class TripsterDetailViewModel {

    var reload: (() -> Void)?

    var trip: Trip {
        didSet {
            members = trip.members
        }
    }
    var members = [TripMember]()
    var isAdmin: Bool = false
    var isMember: Bool = false
    var selectedTab :kTripDetailTab = kTripDetailTab.AllMemories
    var memories = [Feed]()
    var tripPins = [Feed]()
    var isLastContent = false
    var isLastContentPins = false
    
    var currentPage = 0
    var currentPagePins = 0
    var limit = 100
    var isPublic: Bool!

    init(trip: Trip, isPublic: Bool = false) {
        self.trip = trip
        self.isPublic = isPublic
        let meAsMember = trip.members.first(where: { $0.userId == Helpers.userId })
        isAdmin = stringToBool(string: meAsMember?.isAdmin)
        isMember = meAsMember != nil
        getTripDetail()
        getTripMemmories()
        getTripPinsMemmories()
    }

    func getTripDetail() {
        APIController.makeRequest(request: .tripsterDetail(id: trip.tripId)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? JSONDictionary else { return }
                    self.trip = Trip(json: data)
                    self.members = self.trip.members
                    self.reload?()
                }
            }
        }
    }

    func getTripMemmories(isLoadingMore: Bool = false) {
        if !isLoadingMore {
            currentPage = 0
            memories.removeAll()
        } else {
            currentPage += limit
        }

        APIController.makeRequest(request: .getTripMemories(userid:Helpers.userId, tripId: trip.tripId, count: currentPage, limit: limit)) { (response) in
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
    
    func getTripPinsMemmories(isLoadingMore: Bool = false) {
        if !isLoadingMore {
            currentPagePins = 0
            tripPins.removeAll()
        } else {
            currentPagePins += limit
        }
        
        APIController.makeRequest(request: .getTripPinsMemories(userid:Helpers.userId, tripId: trip.tripId, count: currentPage, limit: limit)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["feeds"] as? [JSONDictionary] else { return }
                    let feeds = data.compactMap{ Feed.init(json: $0) }
                    self.isLastContentPins = data.isEmpty
                    self.tripPins.append(contentsOf: feeds)
                    self.reload?()
                }
            }
        }
    }
    
    func deleteUserFromTrip(userId: String) {
        let param = [
            "trip_id": trip.tripId,
            "other_user_id": userId,
            "user_id": Helpers.userId
        ]
        
        APIController.makeRequest(request: .deleteUserFromTrip(param: param)) { (_) in
        }
    }
    
    func addUserToTrip(userId: String) {
        let param = [
            "trip_id": trip.tripId,
            "new_added_user": userId,
            "user_id": Helpers.userId
        ]
        APIController.makeRequest(request: .addUserToTrip(param: param)) { _ in }
    }
    
    func leaveTheTrip() {
        let param = [
            "is_accept": "false",
            "trip_id": trip.tripId,
            "user_id": Helpers.userId
        ]
        APIController.makeRequest(request: .acceptOrRejectTripInvite(param: param)) { (_) in
        }
    }
    
    func unpin(feed: Feed) {
        let feedId = feed.id
        
        let param = [
            "user_id": Helpers.userId,
            "entity_id": feedId,
            "trip_id": ""
        ]
//        feed.pinStatus = "false"
//        feed.pinCount = "\((Int(feed.pinCount) ?? 0) - 1)"
//        APIController.makeRequest(request: .pinFeedToTrip(param: param)) { (_) in
//            completion()
//        }
    }
    
    func getGroupById(id:String, onComplete: @escaping (ChatContact?) -> Void) {
        guard Helpers.isLoggedIn() else {
            return onComplete(nil)
        }
        APIController.makeRequest(request: .getChatUsers) { (response) in
            switch response {
            case .failure(_):
                onComplete(nil)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return onComplete(nil) }
                let chats = data.compactMap{ ChatContact.init(json: $0) }
                let group = chats.first(where: {$0.groupId == id})
                onComplete(group)
            }
        }
    }
    
    func stringToBool(string: String?) -> Bool {
        guard let val = string else { return false }
        if val.isEmpty { return false }
        if val == "false" { return false }
        return true
    }
    
}
