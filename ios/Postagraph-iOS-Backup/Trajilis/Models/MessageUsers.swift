//
//  MessageUsers.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

final class ChatContact {
    var unreadVideoMessageCount: String
    var unreadTextMessageCount: String
    var unreadImageMessageCount: String
    let admin: CondensedUser?
    let isAdmin: Bool
    let groupId: String
    var members: [CondensedUser] = []
    var groupImage: String
    var groupName: String
    var lastMessage: LastChat?
    
    init(json: JSONDictionary) {
        unreadVideoMessageCount = "0"
        if let dict = json["unread_video_msg_count"] as? JSONDictionary {
            unreadVideoMessageCount = dict["count"] as? String ?? "0"
        }
        
        unreadTextMessageCount = "0"
        if let dict = json["unread_text_msg_count"] as? JSONDictionary {
            unreadTextMessageCount = dict["count"] as? String ?? "0"
        }
        
        unreadImageMessageCount = "0"
        if let dict = json["unread_image_msg_count"] as? JSONDictionary {
            unreadImageMessageCount = dict["count"] as? String ?? "0"
        }
        if let dict = json["admin"] as? JSONDictionary {
            admin = CondensedUser.init(json: dict)
            isAdmin = Helpers.userId == admin?.userId
        } else {
            admin = nil
            isAdmin = false
        }
        groupId = json["group_id"] as? String ?? ""
        if let dictArray = json["members"] as? [JSONDictionary] {
            members = dictArray.compactMap{ CondensedUser.init(json: $0) }
        }
        groupImage = json["group_image"] as? String ?? ""
        if let name = json["group_name"] as? String, let decoded = name.removingPercentEncoding {
            groupName =  decoded
        } else {
            groupName =  ""
        }
        
        lastMessage = nil
        if let messageDict = json["last_message"] as? JSONDictionary {
            lastMessage = LastChat.init(json: messageDict)
            if let lmsg = lastMessage {
                if lmsg.timeStamp == 0 && lmsg.content.isEmpty {
                    if let admin = admin?.username,groupName.count > 0 {
                        lmsg.content = "\(admin) created the group"
                    }
                }
            }
        }
    }
    
}


final class LastChat {
    var content: String
    var isRead: Bool
    var messageId: String
    let messageType: ChatType
    let thumbnail: String
    let timeStamp: Int
    
    init(json: JSONDictionary) {
        content = json["message"] as? String ?? ""
        isRead = false
        if let isReadString = json["is_read"] as? String {
            isRead = isReadString == "false" ? false : true
        }
        messageId = json["message_id"] as? String ?? ""
        thumbnail = json["thumbnail"] as? String ?? ""
        timeStamp = json["time_stamp"] as? Int ?? 0
        
        let type = json["message_type"] as? String ?? ""
        messageType = ChatType.init(rawValue: type) ?? ChatType.unknown
    }
}

enum ChatType: String {
    case text = "text"
    case image = "image"
    case video = "video"
    case audio = "audio"
    case unknown = ""
}
