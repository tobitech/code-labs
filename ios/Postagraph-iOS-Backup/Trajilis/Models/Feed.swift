//
//  Feed.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

final class Feed {
    let profileImageType: String
    let rating: String
    let tripName: String
    let username: String
    let title: String
    let url: String
    let cdnUrl: String
    let country: String
    let userId: String
    let component: String
    let firstname: String
    let userImage: String
    var likeCount: String
    var likeStatus: String
    var pinCount: String
    var pinStatus: String
    let userCity: String
    let createdOn: String
    let state: String
    let id: String
    let placeId: String
    let hashTag: String
    let tripId: String
    let workAt: String
    let lastname: String
    let feedLocation: String
    let feedType: String
    let parentId: String
    var viewcount: Int = 0
    
    var commentCount: String
    let address: String
    let imageURL: String
    let taggedUsers: [CondensedUser]
    let feed_visibility:String
    init(json: JSONDictionary) {
        userImage = json["user_image"] as? String ?? ""
        userId = json["user_id"] as? String ?? ""
        profileImageType = json["profile_image_type"] as? String ?? ""
        username = json["user_name"] as? String ?? ""
        rating = json["rating"] as? String ?? ""
        tripName = json["trip_name"] as? String ?? ""
        title = json["title"] as? String ?? ""
        createdOn = json["createdon"] as? String ?? ""
        url = json["url"] as? String ?? ""
//        if let createdOn = Double(createdOn), createdOn > 1564540620 {
//            cdnUrl = json["cdn_url"] as? String ?? ""
//        }else {
//            cdnUrl = url
//        }
        cdnUrl = url
        country = json["country"] as? String ?? ""
        component = json["component"] as? String ?? ""
        firstname = json["f_name"] as? String ?? ""
        likeCount = json["like_count"] as? String ?? ""
        likeStatus = json["like_status"] as? String ?? ""
        pinCount = json["pin_count"] as? String ?? ""
        pinStatus = json["pin_status"] as? String ?? ""
        userCity = json["user_city"] as? String ?? ""
        state = json["state"] as? String ?? ""
        id = json["id"] as? String ?? ""
        placeId = json["place_id"] as? String ?? ""
        hashTag = json["hash_tag"] as? String ?? ""
        tripId = json["trip_id"] as? String ?? ""
        workAt = json["work_at"] as? String ?? ""
        lastname = json["l_name"] as? String ?? ""
        feedLocation = json["feed_location"] as? String ?? ""
        feedType = json["feed_type"] as? String ?? ""
        commentCount = json["comment_count"] as? String ?? ""
        address = json["address"] as? String ?? ""
        imageURL = json["image_url"] as? String ?? ""
        let parentId = json["parent_id"] as? String ?? ""
        if parentId == "000000000000000000000000" {
            self.parentId = ""
        }else {
            self.parentId = parentId
        }
        
        viewcount = json["viewcount"] as? Int ?? 0
        
        feed_visibility =  json["feed_visibility"] as? String ?? ""
        if let dictArray = json["taged_user"] as? [JSONDictionary] {
            taggedUsers = dictArray.compactMap{ CondensedUser.init(json: $0) }
        } else {
            taggedUsers = []
        }
        
    }
    func getIDForUser(userName:String) -> String? {
        let filtered = taggedUsers.filter { (user) -> Bool in
            if user.username == userName {
                return true
            }
            return false
        }
        return filtered.first?.userId
    }
    func getUserName() -> String {
        return firstname + " " + lastname
    }
}

struct CondensedUser: Equatable {
    let userImage: String
    let userId: String
    let profileImageType: String
    let username: String
    let firstName: String?
    let lastName: String?
    
    static func ==(lhs: CondensedUser, rhs: CondensedUser) -> Bool {
        return lhs.userId == rhs.userId
    }
}

extension CondensedUser {
    init(json: JSONDictionary) {
        userImage = json["user_image"] as? String ?? ""
        userId = json["user_id"] as? String ?? ""
        profileImageType = json["profile_image_type"] as? String ?? ""
        username = json["user_name"] as? String ?? ""
        firstName = json["first_name"] as? String
        lastName = json["last_name"] as? String
    }
}

struct CondensedFeed {
    let component: String
    let id: String
    let type: String
    let imageURL: String
    let url: String
}

extension CondensedFeed {
    init(json: JSONDictionary) {
        component = json["component"] as? String ?? ""
        id = json["feed_id"] as? String ?? ""
        type = json["feed_type"] as? String ?? ""
        imageURL = json["image_url"] as? String ?? ""
        url = json["url"] as? String ?? ""
    }
}
