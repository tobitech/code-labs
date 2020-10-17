//
//  TripDetailUserListViewModel.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/17/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation

final class TripDetailUserListViewModel {
    
    var members: [TripMember]
    var tripId: String
    let isAdmin: Bool
    
    init(members: [TripMember], tripId: String) {
        self.members = members
        self.tripId = tripId
        
        if let val = members.first(where: {$0.userId == Helpers.userId})?.isAdmin, val == "true" {
            isAdmin = true
        }else {
            isAdmin = false
        }
    }
    
    func deleteUserFromTrip(member: TripMember) {
        let param = [
            "trip_id": tripId,
            "other_user_id": member.userId,
            "user_id": Helpers.userId
        ]
        members.removeAll(where: {$0.userId == member.userId})
        APIController.makeRequest(request: .deleteUserFromTrip(param: param)) { (_) in
        }
    }
    
    func leaveTheTrip() {
        let param = [
            "is_accept": "false",
            "trip_id": tripId,
            "user_id": Helpers.userId
        ]
        APIController.makeRequest(request: .acceptOrRejectTripInvite(param: param)) { (_) in
        }
    }
    
}
