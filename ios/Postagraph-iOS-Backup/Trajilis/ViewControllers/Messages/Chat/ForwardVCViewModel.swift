//
//  MessageViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

final class ForwardVCViewModel {

    let limit:Int = 20
    var reload:(() -> ())?
    var searchedUsers = [ForwardUser]()
    var allUsers = [ForwardUser]()
    var currentUsersPage:Int = 0
    init() {}
 
    func fetchUsers() {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        APIController.makeRequest(request: .getUserForMsgForward(userId: id, count: "\(limit * self.currentUsersPage)", limit: "\(limit)")) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):                
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                let users = data.compactMap{ ForwardUser.init(json: $0) }
                if users.count > 0 {
                    self.allUsers.append(contentsOf: users)
                    self.currentUsersPage = self.currentUsersPage + 1
                }
                self.reload?()
            }
        }
    }
    
    func search(text: String) {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        let param = ["limit":"1000","count": "0","search_string": text, "user_id": id]
        APIController.makeRequest(request: .serchUserForMsgForward(param: param)) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                let users = data.compactMap{ ForwardUser.init(json: $0) }
                self.searchedUsers.removeAll()
                if users.count > 0 {
                    self.searchedUsers.append(contentsOf: users)
                }
                self.reload?()
            }
        }
    }

}


struct ForwardUser {
    var entity_image: String
    var entity_name: String
    var entity_id: String
    init(json:JSONDictionary) {
        self.entity_id = json["entity_id"] as? String  ?? ""
        self.entity_name = json["entity_name"] as? String ?? ""
        self.entity_image = json["entity_image"] as? String ?? ""
    }
}
