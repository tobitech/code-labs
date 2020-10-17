//
//  TripListViewModel.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/17/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation

enum kViewMode:Int {
    case CurrentTrips = 0
    case AllTrip = 1
    case Invited = 2
    case ForPin = 3
    case Public = 4
}

final class TripListViewModel: DeleteTripAPI {
    
    var tripListResponse = [Trip]()
    var userId: String = ""
    var currentPage:Int = 0
    var isPublicTrips = false
    var viewMode: kViewMode = .AllTrip
    var isOnMainTab:Bool = true
    var onInviteTripCountUpdate: ((String?) -> ())?
    
    func fetchInvitedTrips(success: @escaping () -> (), failure: @escaping (String) -> ()) {
        APIController.makeRequest(request: .getTripList(userId: Helpers.userId, invitationStatus: "INVITED", count: 0, limit: 1000)) { [weak self] (response) in
            switch response {
            case .failure(_):
                failure("No invitation found.")
            case .success(let value):
                guard let self = self,
                    let json = try? value.mapJSON() as? JSONDictionary,
                    let tripData = json?["data"] as? [JSONDictionary] else {
                        failure("No invitation found.")
                        return
                }
                let tripList = tripData.map{Trip.init(json: $0)}
                for trip in tripList {
                    trip.members = trip.members.filter({$0.userId != Helpers.userId})
                }
                if tripList.isEmpty {
                    failure("No invitation found.")
                }
                self.handleTriplist(list: tripList)
                success()
            }
        }
    }
    
    func getCurrentTrips(success: @escaping () -> (), failure: @escaping (String) -> ()) {
        let timestamp = Date().timeIntervalSince1970
        let timeStampStr : String! = String(format:"%.0f", timestamp)
        let userId = self.userId
        let param: JSONDictionary = [
            "current_date": timeStampStr,
            "user_id": userId
        ]
        APIController.makeRequest(request: .getCurrentTrips(param: param)) {[weak self] (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(let e):
                    failure(e.desc)
                case .success(let result):
                    guard let self = self,
                        let json = try? result.mapJSON() as? JSONDictionary,
                        let tripData = json?["data"] as? [JSONDictionary] else {
                            failure(kDefaultError)
                            return
                    }
                    let tripList = tripData.map{Trip.init(json: $0)}
                    self.handleTriplist(list: tripList)
                    success()
                }
            }
        }
    }
    
    func getTripList(inviteCode: String, success: @escaping () -> (), failure: @escaping (String) -> ()) {
        APIController.makeRequest(request: .getTripList(userId: userId, invitationStatus: inviteCode, count: 0, limit: 1000)) { [weak self] (response) in
            switch response {
            case .failure(_):
                failure(kDefaultError)
            case .success(let value):
                guard let self = self,
                    let json = try? value.mapJSON()  as? JSONDictionary,
                    let tripData = json?["data"] as? [JSONDictionary] else { return }
                let tripList = tripData.map{Trip.init(json: $0)}
                self.handleTriplist(list: tripList)
                success()
            }
        }
    }
    
    func deleteTrip(trip: Trip, success: @escaping (Int) -> (), failure: @escaping (String) -> ()) {
        self.deleteTrip(trip: trip, userId: userId, success: {
            if let indexOfTrip = self.tripListResponse.firstIndex(where: {$0.tripId == trip.tripId}) {
                self.tripListResponse.remove(at: indexOfTrip)
                success(indexOfTrip)
            }else {
                failure(kDefaultError)
            }
        }, failure: failure)
    }
    
    private func handleTriplist(list: [Trip]) {
        for trip in list {
            trip.getTripMemory()
        }
        self.tripListResponse = list
        //        if tripList.count > 0 {
        //            if self.currentPage > 0 {
        //                self.tripListResponse.append(contentsOf: tripList)
        //            } else {
        //                self.tripListResponse.append(contentsOf: tripList)
        //            }
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
    
    func fetchTrendingTrips(onSuccess: @escaping ()->(), onFailure: @escaping (String) -> ()) {
        APIController.makeRequest(request: .trendingTrip(userId: Helpers.userId, count: 0, limit: 1000)) { [weak self] (response) in
            switch response {
            case .failure(let e):
                onFailure(e.desc)
            case .success(let result):
                guard let self = self,
                    let json = try? result.mapJSON() as? JSONDictionary,
                    let tripData = json?["data"] as? [JSONDictionary] else {
                        return onFailure(kDefaultError)
                }
                let tripList = tripData.map{Trip.init(json: $0)}
                self.handleTriplist(list: tripList)
                onSuccess()
            }
        }
    }
    
    func getPendingInviteCount() {
        APIController.makeRequest(request: .pendingTripInvite) { (response) in
            switch response {
            case .failure(_):
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? JSONDictionary,
                    let count = data["count"] as? String else { return }
                if count == "0" {
                    self.onInviteTripCountUpdate?(nil)
                }else {
                    self.onInviteTripCountUpdate?(count)
                }
            }
        }
    }
    
}
