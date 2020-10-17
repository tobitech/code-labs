//
//  NewTripViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 17/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

final class NewTripViewModel: DeleteTripAPI {

    var searchUserForTripResponse = [CondensedUser]()
    var selectedUsers = [CondensedUser]()

    var currentPage = 0
    var limit = 100
    var isLastCount = false
    var reload: (() -> ())?

    var trip: Trip?
    var isEdit = false

    var searchUserForTripComplete: ((String?) -> ())?
    var saveNewTripComplete: ((String?) -> ())?

    @discardableResult
    func add(user: CondensedUser?) -> Bool {
        guard let user = user else {return false}
        if let index = selectedUsers.firstIndex(where: { user.userId == $0.userId }) {
            selectedUsers.remove(at: index)
            return false
        } else {
            selectedUsers.append(user)
            return true
        }
    }

    func isSelected(user: CondensedUser) -> Bool {
        return selectedUsers.contains(where: { user.userId == $0.userId })
    }


    func saveNewTrip(tripName: String, startDate: String, endDate: String, location: String, description: String, invitedUser: String, lat: String, long: String, visibility:String) {
        guard let userId = UserDefaults.standard.string(forKey: USERID) else { return }

        var jsonParam: JSONDictionary = [
            "description": description,
            "end_date": endDate,
            "start_date": startDate,
            "location": location,
            "lon": long,
            "lat": lat,
            "invited_user": invitedUser,
            "user_id": userId,
            "visibility": visibility,
            "trip_name": tripName
        ]

        let api: TrajilisAPI
        if isEdit && self.trip != nil {
            jsonParam["invited_user"] = trip!.members.map{ $0.userId }
            if let tripId = self.trip?.tripId {
                jsonParam["trip_id"] = tripId
            }
            
            api = TrajilisAPI.addUserToTrip(param: jsonParam)
        } else {
            api = TrajilisAPI.saveTrip(param: jsonParam)
        }

        APIController.makeRequest(request: api) {[weak self] (response) in
            switch response {
            case .failure(let error):
                self?.saveNewTripComplete?(error.desc)
            case .success(let value):
                guard let json = try? value.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary,
                    let status = meta["status"] as? String else { return }
                if status == "200" {
                    self?.saveNewTripComplete?(nil)
                } else {
                    self?.saveNewTripComplete?(meta["message"] as? String ?? "")
                }
                print("JSON \(String(describing: json?.debugDescription))")

            }
        }

    }

//    func searchUserForTrip(searchParam: String, tripId: String) {
//        guard let userId = UserDefaults.standard.string(forKey: USERID) else { return }
//        let param: JSONDictionary = [
//            "limit": limit,
//            "count": currentPage,
//            "user_id": userId,
//            "search_string": searchParam,
//            "trip_id": tripId
//        ]
//        APIController.makeRequest(request: .searchUserForTrip(param: param)) {[weak self] (response) in
//            switch response {
//            case .failure(let error):
//                self?.searchUserForTripComplete?(error.desc)
//            case .success(let value):
//                guard let json = try? value.mapJSON() as? JSONDictionary, let searchUserTripData = json?["data"] as? [JSONDictionary] else { return }
//                let searchUsersForTrip = searchUserTripData.compactMap{ CondensedUser.init(json: $0) }
//                guard let sSelf = self else { return }
//                if sSelf.currentPage > 0 {
//                    sSelf.searchUserForTripResponse.append(contentsOf: searchUsersForTrip)
//                }else {
//                    sSelf.searchUserForTripResponse = searchUsersForTrip
//                }
//                self?.searchUserForTripComplete?(nil)
//            }
//        }
//    }
    
    func deleteTrip(success: @escaping () -> (), failure: @escaping (String) -> ()) {
        self.deleteTrip(trip: self.trip!, userId: Helpers.userId, success: success, failure: failure)
    }

}
