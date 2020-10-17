//
//  FollowViewModel.swift
//  Trajilis
//
//  Created by Moses on 25/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

protocol IFollowViewModel {
    func getFollow(by type: FollowType, count: Int , render: @escaping ((MStateModel<List<Followers>>) -> Void))
    func follow(by event: FollowType, id: String, render: @escaping ((MStateModel<Bool>) -> Void))
}


class FollowViewModel : IFollowViewModel {
    
    func getFollow(by type: FollowType, count: Int, render: @escaping ((MStateModel<List<Followers>>) -> Void)) {
        
        guard let userId = UserDefaults.standard.value(forKey: USERID) as? String else { return }
        
        let state = MState<List<Followers>>.loading
        render(MStateModel<List<Followers>>.init(state: state))
        
        let api = type == .follower ? TrajilisAPI.getFollowers(otherUserId: userId, count: count, limit: 50) : TrajilisAPI.getFollowing(otherUserId: userId, count: count, limit: 50)
        
        APIController.makeRequest(request: api) { (response) in
            
            switch response {
            case .failure(let errorMessage):
                let state = MState<List<Followers>>.error(errorMessage.localizedDescription)
                render(MStateModel<List<Followers>>.init(state: state))
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                
                if let data = json?["data"] as? [JSONDictionary] {
                    let followers = data.compactMap({ Followers.init(json: $0) })
                    let list = List<Followers>.init(list: followers)
                    let state = MState<List<Followers>>.dataLoaded(list, "")
                    render(MStateModel<List<Followers>>.init(state: state))
                } else {
                    let state = MState<List<Followers>>.noData("")
                    render(MStateModel<List<Followers>>.init(state: state))
                }
                
            }
        }
    }
    
    
    func follow(by type: FollowType, id: String, render: @escaping ((MStateModel<Bool>) -> Void) ) {
        
        guard let userId = UserDefaults.standard.value(forKey: USERID) as? String else { return }
        
        let api = type == .follower ? TrajilisAPI.follow(follower: id, following: userId, status: "true") : TrajilisAPI.follow(follower: id, following: userId, status: "false")
        
        APIController.makeRequest(request: api) { (response) in
            
            switch response {
            case .failure(_):
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                
                if let meta = json?["meta"] as? JSONDictionary, let status = meta["status"] as? String, status == "200" {
                    
                    let state = MState<Bool>.dataLoaded(true, "")
                    render(MStateModel<Bool>.init(state: state))
                } else {
                    let state = MState<Bool>.dataLoaded(false, "")
                    render(MStateModel<Bool>.init(state: state))
                }
                
                break
            }
        }
    }
}
