//
//  Message.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import MessageKit

struct TrajilisMessage {
    var id: String
    var text: String
    var sender: CondensedUser
    var receiver: CondensedUser
}


private struct ImageMediaItem: MediaItem {
    
    var url: URL?
    var image: UIImage?
    var placeholderImage: UIImage
    var size: CGSize
    
    init(image: UIImage) {
        self.image = image
        self.size = CGSize(width: 240, height: 240)
        self.placeholderImage = UIImage()
    }
    
}

internal struct Sender: SenderType, Equatable {
    var senderId: String

    var displayName: String
}

internal struct Message: MessageType {
    var sender: SenderType {
        return user
    }
    var messageId: String
    var sentDate: Date
    var kind: MessageKind
    var isRead: Bool
    var mediaURL: String?
    var thumbnailURL: String?
    var dateHeader: String?
    var msgType: String = ChatType.text.rawValue
    var needsUpload:Bool = false
    var jsonData:JSONDictionary?
    var user: Sender
    
    // for replied message
    var isRepliedMsg:Bool = false
    var isForwaredMsg:Bool = false
    
    var parent_message_id : String?
    var parent_message : String?
    var parent_message_sentdate : Date?
    var parent_message_type : String?
    var parent_message_thumbnail : String?
    var parent_message_sender_name : String?

    
    
    func isDownloaded() -> Bool {        
        if let localPath = self.localFilePath() {
            let fileManager = FileManager.default
            return fileManager.fileExists(atPath: localPath.path)
        }
        return false
    }
    func localThumbnailURL() -> URL? {
        if let localPath = self.localFilePath() {
            var thumnURL = localPath.deletingPathExtension().path
            thumnURL.append("_thumb.png")
            let thumbPath = URL(fileURLWithPath: thumnURL)
            let fileManager = FileManager.default
            if fileManager.fileExists(atPath: thumbPath.path) {
                return thumbPath
            }
        }
        return nil
    }
    func getTextMsg() -> String {
        if self.msgType == ChatType.text.rawValue {
            switch self.kind {
            case .text(let text), .emoji(let text):
                return text
            default:
                break
            }
        }
        return self.msgType.localized
    }
    func localFilePath() -> URL? {
        if let strURL = self.mediaURL,let url = URL(string: strURL) {
            return Helpers.getDocumentsDirectory().appendingPathComponent(url.lastPathComponent)
        }
        return nil
    }
    static func getMessage(json: JSONDictionary) -> Message? {
        guard  let msgId = json["_id"] as? String, let strTimeStamp = json["time_stamp"] as? String,let timestamp = Double(strTimeStamp) else {
            return nil
        }
        let date = Date(timeIntervalSince1970 : timestamp)
        guard let crntuserId = UserDefaults.standard.string(forKey: USERID) else { return nil}
        
        if let senderData = json["sender"] as AnyObject?,let senderName = senderData["user_name"] as? String,let senderId = senderData["user_id"] as? String  {
            let msgSender = Sender(senderId: senderId, displayName: senderName)
            if let type = json["type"] as? String,!type.isEmpty {
                let txt = json["message"] as? String ?? ""
                var msg = Message(text: txt, sender: msgSender, messageId: msgId, date: date)
                if let receiverData = json["receiver"] as? [AnyObject] {
                    for reciver in receiverData {
                        if let uid = reciver["user_id"] as? String,uid == crntuserId {
                            if let read = reciver["is_read"] as? String {
                                msg.isRead = (read == "true") ? true : false
                            }
                        }
                    }
                }
                msg.msgType = type
                if let url = json["url"] as? String {
                    msg.mediaURL = url
                }
                if let value = json["thumbnail"] as? String {
                    msg.thumbnailURL = value
                }
                msg.jsonData = json
                
                if let is_replied = json["is_replied"] as? String,is_replied == "true" {
                    
                    msg.isRepliedMsg = true
                    
                    if let value = json["parent_message_id"] as? String {
                        msg.parent_message_id = value
                    }
                    if let value = json["parent_message_sender_name"] as? String {
                        msg.parent_message_sender_name = value
                    }
                    if let value = json["parent_message"] as? String {
                        msg.parent_message = value
                    }
                    if let value = json["parent_message_type"] as? String {
                        msg.parent_message_type = value
                    }
                    if let value = json["parent_message_thumbnail"] as? String {
                        msg.parent_message_thumbnail = value
                    }
                    if let value = json["parent_message_time"] as? String,let parenttimestamp = Double(value) {
                        let date = Date(timeIntervalSince1970 : parenttimestamp)
                        msg.parent_message_sentdate = date
                    }
                }
                if let is_forwarded = json["is_forwarded"] as? String,is_forwarded == "true" {
                    msg.isForwaredMsg = true
                }
                
                return msg
            }
        }
        return nil
    }
    
    private init(kind: MessageKind, sender: Sender, messageId: String, date: Date) {
        self.kind = kind
        self.user = sender
        self.messageId = messageId
        self.sentDate = date
        self.isRead = false
    }
    
    init(custom: Any?, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .custom(custom), sender: sender, messageId: messageId, date: date)
    }
    
    init(text: String, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .text(text), sender: sender, messageId: messageId, date: date)
    }
    
    init(attributedText: NSAttributedString, sender: Sender, messageId: String, date: Date) {
        self.init(kind: .attributedText(attributedText), sender: sender, messageId: messageId, date: date)
    }
    
    init(image: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: image)
        self.init(kind: .photo(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    
    init(thumbnail: UIImage, sender: Sender, messageId: String, date: Date) {
        let mediaItem = ImageMediaItem(image: thumbnail)
        self.init(kind: .video(mediaItem), sender: sender, messageId: messageId, date: date)
    }
    
    
    
}
