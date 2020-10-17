//
//  Notification.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 12/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

enum NotificationType: String {
    case likeProfile = "like_profile"
    case post = "post"
    case comment = "comment"
    case commentReply = "reply_on_comment"
    case likeComment = "like_comment"
    case follow = "follow"
    case profileImage = "profile_image"
    case newRegistration = "new_register"
    case like = "like"
    case tagComment = "tag_comment"
    case tagPost = "tag_post"
    case tagReply = "tag_reply"
    case tagUserLikeComment = "tag_user_like_comment"
    case addInNewGroup = "add_in_new_group"
    case createNewGroup = "create_new_group"
    case trip = "trip"
}

final class TrajilisNotification {
    let senderId: String
    let senderName: String
    let soundURL: String
    let message: String
    let badgeCount: String
    let senderImage: String
    let profileImageType: String
    let date: String
    let groupId: String
    let updateHistoryId: String
    var isRead: Bool
    let isBadged: Bool
    let notificationType: NotificationType?
    let id: String
    let receiverID: String
    let entityId: String
    
    init(json: JSONDictionary) {
        senderId = json["sender_id"] as? String ?? ""
        senderName = json["sender_name"] as? String ?? ""
        soundURL = json["sound_url"] as? String ?? ""
        message = json["message"] as? String ?? ""
        badgeCount = json["badge_count"] as? String ?? ""
        senderImage = json["sender_image"] as? String ?? ""
        profileImageType = json["profile_image_type"] as? String ?? ""
        date = json["date"] as? String ?? ""
        groupId = json["group_id"] as? String ?? ""
        entityId = json["entity_id"] as? String ?? ""
        updateHistoryId = json["update_history_id"] as? String ?? ""
        if let read = json["is_read"] as? String {
            isRead = read.lowercased() == "false" ? false : true
        } else {
            isRead = false
        }
        if let badge = json["isbadged"] as? String {
            isBadged = badge.lowercased() == "false" ? false : true
        } else {
            isBadged = false
        }
        if let type = json["noti_type"] as? String {
            notificationType = NotificationType.init(rawValue: type)
        } else {
            notificationType = nil
        }
        id = json["notification_id"] as? String ?? ""
        receiverID = json["receiver_id"] as? String ?? ""
    }
}
