//
//  Followers.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

class Followers : Searchable {
    
    var value: String = ""
    var profileImageType: String = ""
    var city: String = ""
    var country: String = ""
    var pic: String = ""
    var status: Bool = false
    var userId: String = ""
    var workAt: String = ""
    var username: String = ""
    var name: String = ""
    
    var state: String = ""
    
    init(json: JSONDictionary) {
        self.profileImageType = json["profile_image_type"] as? String ??  ""
        self.city = json["city"] as? String ?? ""
        self.country = json["country"] as? String ?? ""
        if let pic = json["pic"] as? String {
            self.pic =  pic
        } else if let pic = json["profile_image"] as? String {
            self.pic = pic
        } else if let pic = json["user_image"] as? String {
            self.pic = pic
        }

        if let status = json["status"] as? String {
            self.status = status == "true" ? true : false
        } else if let status = json["following_status"] as? String {
            self.status = status == "true" ? true : false
        }

        if let id = json["userid"] as? String {
            self.userId = id
        } else if let id = json["user_id"] as? String {
            self.userId = id
        }
        self.workAt = json["work_at"] as? String ?? ""
        if let uname = json["username"] as? String {
            self.username = uname
        } else if let uname = json["user_name"] as? String {
            self.username = uname
        }
        if let name = json["name"] as? String {
            self.name = name
        } else if let name = json["full_name"] as? String {
            self.name = name
        }
        self.state = json["state"] as? String ?? ""
        self.value = name + " " + username
    }

    var condensedUser: CondensedUser {
        return CondensedUser.init(userImage: pic, userId: userId, profileImageType: "", username: username, firstName: "", lastName: "")
    }
}
