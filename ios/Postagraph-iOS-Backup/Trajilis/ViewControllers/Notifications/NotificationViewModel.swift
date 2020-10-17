//
//  NotificationViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 12/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

let NOTIFICATIONKEY = "NOTIFICATIONKEY"

final class NotificationViewModel {
    
    var updateNotificationCount:(() -> ())?
    var unreadCount: Int? = nil {
        didSet {
            updateNotificationCount?()
        }
    }
    var currentPage = 0
    var limit = 100
    var isLastContent = false
    var notifications = [TrajilisNotification]()
    var reload:(() -> ())?
    
    init() {
        fetchNotification()
        fetchNotificationCount()
    }
    
    func loadMore() {
        if Network.reachability?.status == .unreachable { return }
        currentPage += limit
        fetchNotification()
    }
    
    func fetchNotification() {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
//        if Network.reachability?.status == .unreachable {
//            DataStorage.shared.dataStorage.async.object(forKey: NOTIFICATIONKEY) { (result) in
//                DispatchQueue.main.async {
//                    switch result {
//                    case .error(_):
//                        break
//                    case .value(let val):
//                        guard let json = try? JSONSerialization.jsonObject(with: val, options: []) as? JSONDictionary,
//                            let data = json?["data"] as? [JSONDictionary] else { return }
//                        let notifications = data.map{ TrajilisNotification.init(json: $0) }
//                        self.notifications = notifications
//                        self.reload?()
//                    }
//                }
//            }
//
//        } else {
            APIController.makeRequest(request: .notifications(userId: id, count: currentPage, limit: limit)) { (response) in
                switch response {
                case .failure(_):
                    break
                case .success(let val):
                    guard let json = try? val.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else {
                            return
                    }
                    let notifications = data.map{ TrajilisNotification.init(json: $0) }
                    if notifications.count > 0 {
                        try? DataStorage.shared.dataStorage.setObject(val.data, forKey: NOTIFICATIONKEY)
                    }
                    self.isLastContent = notifications.isEmpty
                    if self.currentPage > 0 {
                        self.notifications.append(contentsOf: notifications)
                    } else {
                        self.notifications = notifications
                    }
                    self.reload?()
                }
            }
//        }
    }
    
    func clearBadgeCount() {
        APIController.makeRequest(request: .clearBadge) { (_) in }
    }
    
    func fetchNotificationCount() {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        APIController.makeRequest(request: .notificationCount(userId: id)) { (response) in
            switch response {
            case .failure(_):
                self.unreadCount = nil
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary,
                    let status = meta["status"] as? String else { return }
                if status == "200" {
                    if let message = meta["message"] as? String, message == "Unread Notification Count" {
                        if let data = json?["data"] as? JSONDictionary {
                            if let countVal = data["count"] as? String {
                                if countVal != "0" {
                                    self.unreadCount = Int(countVal)
                                    return
                                }
                            }
                        }
                    }
                }
                self.unreadCount = nil
            }
        }
    }
    
    func updateNumberOfUnreadMessage() {
        guard var count = unreadCount else { return }
        count -= 1
        if count < 1 {
            unreadCount = nil
        } else {
            unreadCount = count
        }
    }
    
    func deleteNotification(not_f: TrajilisNotification) {
        if let index = notifications.firstIndex(where: { $0.id == not_f.id }) {
            notifications.remove(at: index)
            if !not_f.isRead {
                updateNumberOfUnreadMessage()
            }
            reload?()            
        }
        APIController.makeRequest(request: .deleteNotification(id: not_f.id)) { (response) in
            
        }
    }
    
    func deleteAllNotification() {
        APIController.makeRequest(request: .deleteAllNotification) { [weak self] (_) in
            DispatchQueue.main.async {
                self?.notifications.removeAll()
                self?.reload?()
                self?.unreadCount = nil
            }
        }
    }
    
    func markAllRead() {
        for not_f in notifications {
            not_f.isRead = true
        }
        reload?()
        APIController.makeRequest(request: .markAllNotificationRead) { [weak self] (_) in
            self?.fetchNotificationCount()
        }
    }

    func markRead(notificationId: String) {
        APIController.makeRequest(request: .markNotificationAsRead(notificationId: notificationId)) { (_) in }
    }
    
    enum NotificationNavigationType {
        case profile
        case reply
        case post
        case message
        case trip
        case comment
        
        static func navType(type: NotificationType) ->  NotificationNavigationType {
            switch type {
            case .follow, .newRegistration, .likeProfile, .profileImage:
                return .profile
            case .post, .like, .tagPost:
                return .post
            case .commentReply, .tagReply:
                return .reply
            case .addInNewGroup, .createNewGroup:
                return .message
            case .trip:
                return .trip
            case .comment, .tagComment, .likeComment, .tagUserLikeComment:
                return .comment
            }
        }
    }
}
