//
//  Comment.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 06/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

final class Comment {
    let id: String
    var likeCount: String
    var replyCount: String
    let component: String
    let taggedUsers: [CondensedUser]
    let time: String
    var likeStatus: Bool
    let profileImageType: String
    let userId: String
    let username: String
    let userImage: String
    var parentComment: String?

    init(json: JSONDictionary) {
        id = json["comment_id"] as? String ?? ""
        likeCount = json["like_count"] as? String ?? ""
        replyCount = json["reply_count"] as? String ?? ""
        component = json["component"] as? String ?? ""
        if let dictArray = json["taged_user"] as? [JSONDictionary] {
            taggedUsers = dictArray.compactMap{ CondensedUser.init(json: $0) }
        } else {
            taggedUsers = []
        }
        time = json["comment_time"] as? String ?? ""
        likeStatus = (json["like_status"] as? String ?? "") == "true" ? true : false
        profileImageType = json["profile_image_type"] as? String ?? ""
        userId = json["user_id"] as? String ?? ""
        username = json["user_name"] as? String ?? ""
        userImage = json["user_image"] as? String ?? ""
    }
}
