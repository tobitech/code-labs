//
//  AddMemberToTripViewModel.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/17/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation

class AddMemberToTripViewModel {
    
    enum Mode: Int {
        case add, edit, view, forwardMessage
    }
    
    var searchUserResponse = [CondensedUser]()
    var selectedUsers = [CondensedUser]()
    var excludeUserIds = [String]()
    var searchUserComplete: ((String?) -> ())?
    var mode: Mode = .add {
        didSet {
            if mode == .forwardMessage {
                getUsersForMessageForward()
            }
        }
    }
    var noMemberTitle = ""
    var noMemberSubtitle = ""
    var isSearching = false
    var allowEmpty = false
    
    private var workItem: DispatchWorkItem?
    
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
    
    func searchUser(searchParam: String) {
        if mode == .forwardMessage {
            if searchParam.isEmpty {
                getUsersForMessageForward()
            }else {
                searchUserForMessageForward(searchParam: searchParam)
            }
            return
        }
        
        if searchParam.isEmpty {
            isSearching = false
            return
        }
        
        if mode == .view {
            searchUserResponse = selectedUsers.filter({
                return [$0.username.lowercased(), $0.lastName?.lowercased() ?? "", $0.firstName?.lowercased() ?? ""].first(where: {$0.contains(searchParam.lowercased())}) != nil
            })
            searchUserComplete?(nil)
            return
        }
        searchUserForTrip(searchParam: searchParam)
    }
    
    private func getUsersForMessageForward() {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        isSearching = true
        workItem?.cancel()
        workItem = DispatchWorkItem {
            APIController.makeRequest(request: .getUserForMsgForward(userId: id, count: "0", limit: "100")) { (response) in
                switch response {
                case .failure(_):
                    self.searchUserComplete?(nil)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else { return }
                    let users = data.compactMap{ ForwardUser.init(json: $0) }
                    self.searchUserResponse = self.convert(forwardUsers: users)
                    self.searchUserComplete?(nil)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem!)
    }
    
    private func searchUserForTrip(searchParam: String) {
        guard let userId = UserDefaults.standard.string(forKey: USERID) else { return }
        isSearching = true
        workItem?.cancel()
        workItem = DispatchWorkItem {
            let param: JSONDictionary = [
                "limit": 100,
                "count": 0,
                "user_id": userId,
                "search_string": searchParam,
                "trip_id": ""
            ]
            APIController.makeRequest(request: .searchUserForTrip(param: param)) {[weak self] (response) in
                switch response {
                case .failure(let error):
                    self?.searchUserComplete?(error.desc)
                case .success(let value):
                    guard let json = try? value.mapJSON() as? JSONDictionary, let searchUserTripData = json?["data"] as? [JSONDictionary] else { return }
                    let searchUsersForTrip = searchUserTripData.compactMap{ CondensedUser.init(json: $0) }
                    guard let self = self else {return}
                    if self.excludeUserIds.isEmpty {
                        self.searchUserResponse = searchUsersForTrip
                    }else {
                        self.searchUserResponse = searchUsersForTrip.filter({
                            !self.excludeUserIds.contains($0.userId)
                        })
                    }
                    self.searchUserComplete?(nil)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem!)
    }
    
    private func searchUserForMessageForward(searchParam: String) {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        isSearching = true
        workItem?.cancel()
        workItem = DispatchWorkItem {
            let param = ["limit":"100","count": "0","search_string": searchParam, "user_id": id]
            APIController.makeRequest(request: .serchUserForMsgForward(param: param)) { (response) in
                switch response {
                case .failure(_):
                    self.searchUserComplete?(nil)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else { return }
                    let users = data.compactMap{ ForwardUser.init(json: $0) }
                    if self.excludeUserIds.isEmpty {
                        self.searchUserResponse = self.convert(forwardUsers: users)
                    }else {
                        let filtereduser = users.filter({
                            !self.excludeUserIds.contains($0.entity_id)
                        })
                        self.searchUserResponse = self.convert(forwardUsers: filtereduser)
                    }
                    self.searchUserComplete?(nil)
                }
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: workItem!)
    }
    
    private func convert(forwardUsers: [ForwardUser]) -> [CondensedUser] {
        return forwardUsers.map { (user) in
            return CondensedUser(userImage: user.entity_image, userId: user.entity_id, profileImageType: "", username: user.entity_name, firstName: nil, lastName: nil)
        }
    }
    
}
