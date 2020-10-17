//
//  Trip.swift
//  Trajilis
//
//  Created by Perfect Aduh on 01/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

enum kTripVisibility: String {
    case PUBLIC
    case PRIVATE
}
final class Trip {
    
    let tripName: String
    let location: String
    let userId: String
    let tripId: String
    let desc: String
    let endDate: String
    let startDate: String
    var chatGroupId: String
    let memberCount: String
    let memoryCount: String
    var members: [TripMember]
    let feed_visibility:String
    var memories = [Feed]()
    var adminUser: TripMember?
    var onMemoriesAdded: (()->())?
    
    init(json: JSONDictionary) {
        tripName = json["trip_name"] as? String ?? ""
        location = json["location"] as? String ?? ""
        userId = json["user_id"] as? String ?? ""
        tripId = json["trip_id"] as? String ?? ""
        desc = json["description"] as? String ?? ""
        endDate = json["end_date"] as? String ?? ""
        startDate = json["start_date"] as? String ?? ""
        memberCount = json["member_count"] as? String ?? ""
        memoryCount = json["memory_count"] as? String ?? ""
        
        // we are getting "000000000000000000000000" for no group
        if let grpId = json["chat_group_id"] as? String, !grpId.isEmpty, grpId != "000000000000000000000000" {
            chatGroupId = grpId
        } else {
            chatGroupId = ""
        }
        
        feed_visibility = json["visibility"] as? String ?? json["feed_visibility"] as? String ?? ""
        if let dicArray = json["members"] as? [JSONDictionary] {
            members = dicArray.compactMap{TripMember.init(json: $0)}
        } else {
            members = []
        }
        
        if members.count > 0 {
            adminUser = members.first{ $0.isAdmin == "true"}
        }
    }
    
    func shouldShowChat() -> Bool {
        guard !chatGroupId.isEmpty && members.count > 1 else {return false}
        return members.contains(where: {$0.userId == Helpers.userId})
    }
   

    func getTripMemory() {
        APIController.makeRequest(request: .getTripMemories(userid:Helpers.userId,tripId: tripId, count: 0, limit: 20)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["feeds"] as? [JSONDictionary] else { return }
                    let feeds = data.compactMap{ Feed.init(json: $0) }
                    self.memories = feeds
                    self.onMemoriesAdded?()
                }
            }
        }
    }
}

struct TripMember {
    let firstName: String
    let lastName: String
    let inviteStatus: String
    let isAdmin: String
    let isBlocked: String
    let memberMemoryCount: String
    let userId: String
    let userImage: String
    let userName: String
    
    init(json: JSONDictionary) {
        firstName = json["first_name"] as? String ?? ""
        lastName = json["last_name"] as? String ?? ""
        inviteStatus = json["invite_status"] as? String ?? ""
        isAdmin = json["is_admin"] as? String ?? ""
        isBlocked = json["is_blocked"] as? String ?? ""
        memberMemoryCount = json["member_memory_count"] as? String ?? ""
        userId = json["user_id"] as? String ?? ""
        userImage = json["user_image"] as? String ?? ""
        userName = json["user_name"] as? String ?? ""
    }
    
    var condensedUser: CondensedUser {
        return CondensedUser(userImage: userImage, userId: userId, profileImageType: "", username: userName, firstName: firstName, lastName: lastName)
    }
}

