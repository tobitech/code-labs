//
//  ChatViewController+Socket.swift
//  Trajilis
//
//  Created by bharats802 on 21/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

extension ChatViewController {

    func getLastChats() {
        if let grpId = self.chatContact?.groupId {
            APIController.makeRequest(request: .getChatMessages(groupId: grpId, count: 0, limit: 1)) { [weak self](response) in
                switch response {
                case .failure(_):
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else {
                            print("failed")
                            return
                    }
                    if let first = data.first {
                        self?.updateWithNewMsg(json: first)
                    }
                }
            }
        }
    }

    func getChats() {
        if let grpId = self.chatContact?.groupId {
            if self.messageList.count == 0 {
                spinner()
            }
            
            let count = self.defaultLimit * self.currentUsersPage
            APIController.makeRequest(request: .getChatMessages(groupId: grpId, count: count, limit: defaultLimit)) { [weak self](response) in
                
                guard let strngSelf = self else {
                    return
                }
                
                strngSelf.hideSpinner()
                switch response {
                case .failure(_):
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else {
                            print("failed")
                            return
                    }                    
                    var mesgs = data.compactMap{ Message.getMessage(json: $0) }
                    if mesgs.count > 0 {
                        strngSelf.currentUsersPage = strngSelf.currentUsersPage + 1
                        let inUploads = MessageUploadManager.shared.activeUploads.keys
                        if inUploads.count > 0 {
                            for msgId in inUploads {
                                if let msg = MessageUploadManager.shared.activeUploads[msgId]?.message {
                                    if let msggrpId = msg.jsonData?["group_id"] as? String,msggrpId == grpId {
                                        mesgs.append(msg)
                                    }
                                }
                            }
                        }
                        if strngSelf.messageList.count > 0 {
                            let msgIds = mesgs.map{$0.messageId}
                            let filterdMsgToAdd = strngSelf.messageList.filter({ (msg) -> Bool in
                                if msgIds.contains(msg.messageId) {
                                    return false
                                }
                                return true
                            })
                            mesgs.append(contentsOf: filterdMsgToAdd)
                        }
                        strngSelf.messageList = mesgs.sorted(by: { (msg, msg1) -> Bool in
                            if msg.sentDate < msg1.sentDate {
                                return true
                            }
                            return false
                        })
                        strngSelf.reloadMessages()
                    }
                }
                DispatchQueue.main.async {
                    strngSelf.refreshControl.endRefreshing()
                }
            }
        }
    }
    func saveLocally(key:String) {
        if messageList.count > 0 {
            var msgs = [JSONDictionary]()
            var count = 1
            for msg in messageList.reversed() {
                if let json = msg.jsonData,!msg.messageId.contains(".") {
                    msgs.append(json)
                    count = count + 1
                    if count >= self.defaultLimit {
                        break
                    }
                }
            }
            if msgs.count > 0 {
                do {
                    let jsond = try JSONSerialization.data(withJSONObject:msgs, options: [])
                    try DataStorage.shared.dataStorage.setObject(jsond, forKey:"GRPC-\(key)")
                } catch {
                    print(error)
                }
            }
        }
    }
    func getMsgLocally(key:String) -> [Message]? {        
        return nil
        do {
            let data = try DataStorage.shared.dataStorage.object(forKey: "GRPC-\(key)")
            if let jsonArray = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? [AnyObject]
            {
                let mesgs = jsonArray.compactMap{ Message.getMessage(json: $0 as! JSONDictionary) }
                let messageList = mesgs.sorted(by: { (msg, msg1) -> Bool in
                    if msg.sentDate < msg1.sentDate {
                        return true
                    }
                    return false
                })
                
                return messageList
            } else {
                print("bad json")
            }
        } catch {
            print(error)
        }
        
        return nil
    }
    func createHeaderDates() {
        
        var previousDate:String?
        self.sectionData.removeAll()
        self.rowData.removeAll()
        
        var mesgArr : [Message]?
        for msg in self.messageList {
            
            var date = ""
            if Calendar.current.isDateInToday(msg.sentDate) {
                date = "Today"
            } else {
                date = msg.sentDate.toString(dateFormat: "EEE, dd MMM", dateStyle: .medium)
            }
            
            if let prevDate = previousDate,prevDate == date {
                mesgArr?.append(msg)
                self.rowData[prevDate] = mesgArr
            } else {
                if !self.sectionData.contains(date) {
                    self.sectionData.append(date)
                }
                mesgArr = [Message]()
                mesgArr?.append(msg)
                self.rowData[date] = mesgArr
                previousDate = date
            }
        }
    }
    func appMovedToBackground() {
        self.disConnectToGroup()
    }
    func applicationDidBecomeActive() {
        self.connectToGroup()
    }
    
    func connectToGroup() {
        if SocketIOManager.shared.isConnected {
            if let contact = self.chatContact {
                let myDict = [
                    "user_id" : self.currentUser.userId,
                    "group_id" : contact.groupId
                ]
                SocketIOManager.shared.socket.emit("setUserId", myDict)
            }
        } 
    }
    func disConnectToGroup() {
        if SocketIOManager.shared.isConnected {
            if let user = (UIApplication.shared.delegate as? AppDelegate)?.user {
                let myDict:NSDictionary = [
                    "user_id" : user.id
                ]
                SocketIOManager.shared.socket.emit("userDisconnect", myDict)
            }
        }
    }
    func listenForNewMessage() {
        SocketIOManager.shared.socket.on("getMessage") {[weak self] (data, ack) in
            SocketIOManager.shared.msgVC?.viewModel.refresh()
            if let json = data.first as? JSONDictionary {
                self?.updateWithNewMsg(json:json)
            }
        }
    }
    
    func updateWithNewMsg(json:JSONDictionary) {
        if let msg = Message.getMessage(json: json) {
            // check if msg already exists
            if (msg.sender.senderId == self.currentUser.userId) {
                let index = self.messageList.firstIndex { (msgO) -> Bool in
                    if msgO.sentDate == msg.sentDate  || (msgO.msgType != ChatType.text.rawValue && msgO.mediaURL == msg.mediaURL){
                        return true
                    }
                    return false
                }
                if let indx = index {
                    let existingMsg = self.messageList[indx]
                    if let indexPath = self.getIndexPathForMsg(msg: existingMsg) {
                        self.messageList.remove(at: indx)
                        self.messageList.insert(msg, at: indx)
                        self.createHeaderDates()
                        DispatchQueue.main.async {
                            self.tblView.reloadRows(at: [indexPath], with: .none)
                        }
                    }
                } else {
                    self.insertMessage(msg)
                }
            } else {
                self.insertMessage(msg)
            }
        }
    }
    func listenForTyping() {
        SocketIOManager.shared.socket.on("typing") {(data, ack) in
            if let json = data.first as? JSONDictionary {
                print(json)
            }
        }
    }

    func sendEditedMessage(message: Message, newText: String) {
        guard var json = message.jsonData else { return }
        json["message"] = newText
        SocketIOManager.shared.socket.emit("editMessage", json)
    }
    
    func sendMessage(data: String?,msgType:ChatType,thumbnailURL:String = "") {
        guard let chatUser = self.chatContact,chatUser.groupId.count > 0 else {
            return
        }
        let groupId = chatUser.groupId
        var trimmedString = ""
        var mediaURL = ""
        
        var needsUpload = false
        switch msgType {
        case .text:
            if let msg = data,!msg.isEmpty {
                trimmedString = msg.trimmingCharacters(in: .whitespaces)
            }
        case .image,.video,.audio:
            if let url = data,!url.isEmpty {
                mediaURL = url
            }
            needsUpload = true
        default:
            break
        }
        var members = [AnyObject]()
        
        for member in chatUser.members {
            if member.userId != currentUser.userId {
                let receiver = [
                    "user_id": member.userId,
                    "user_image": member.userImage,
                    "user_name": member.username
                ]
                members.append(receiver as AnyObject)
            }
        }
        let user = [
            "user_id": currentUser.userId,
            "user_image": currentUser.userImage,
            "user_name": currentUser.username
        ]
        
        var parent_message_id  = "000000000000000000000000"
        var parent_message = ""
        var parent_message_time = "0"
        var is_replied = "false"
        var parent_message_type  = ""
        var parent_message_thumbnail  = ""
        var parent_message_sender_name = ""
        
        let is_forwarded = "false"
        
        if let replying = self.msgReplyingTo {
            parent_message_id  = replying.messageId
            parent_message = replying.getTextMsg()
            parent_message_time = replying.jsonData?["time_stamp"] as? String ?? ""
            is_replied = "true"
            parent_message_type  = replying.msgType
            
            if replying.msgType == ChatType.video.rawValue {
                parent_message_thumbnail  = replying.thumbnailURL ?? ""
            } else {
                parent_message_thumbnail  = replying.mediaURL ?? ""
            }
            
            
            parent_message_sender_name = replying.sender.displayName
        }
        
        let timestamp = Date().timeIntervalSince1970
        let c: String = String(format:"%.0f", timestamp)
        
        var myDict: JSONDictionary = [
            "group_id" : groupId,
            "hashtags" : "",
            "message": trimmedString,
            "receiver": members,
            "sender": user,
            "time_stamp": c,
            "type": msgType.rawValue,
            "url": mediaURL,
            "thumbnail": thumbnailURL,
            "parent_message_id": parent_message_id,
            "parent_message": parent_message,
            "parent_message_time": parent_message_time,
            "is_forwarded": is_forwarded,
            "is_replied": is_replied,
            "parent_message_sender_name": parent_message_sender_name,
            "parent_message_thumbnail": parent_message_thumbnail,
            "parent_message_type": parent_message_type
        ]
        myDict["_id"] = "\(timestamp)"
        if self.msgReplyingTo != nil {
            msgReplyingTo = nil
            resetSenderView()
        }
        
        if var msg = Message.getMessage(json: myDict) {
            msg.needsUpload = needsUpload
            self.insertMessage(msg)
            if !needsUpload {
                myDict["_id"] = nil
                SocketIOManager.shared.socket.emit("sendMessage", myDict)
                DispatchQueue.main.asyncAfter(deadline: .now()+3) {
                    self.getLastChats()
                }
            } else {
                MessageUploadManager.shared.uploadMedia(message: msg)
            }
        }
        
        if msgType != .text {
            self.resetSenderView()
        }
    }
    func markAllMsgRead(msg: Message) {
        if let user = (UIApplication.shared.delegate as?
            AppDelegate)?.user,msg.sender.senderId != user.id,msg.isRead == false  {
            DispatchQueue.global(qos: .background).async {
                APIController.makeRequest(request: .markAsRead(messageId: msg.messageId, userId: user.id)) { (response) in                    
                    print("marked read -- msgid \(msg.messageId)")
                }
            }
        }
    }
}
