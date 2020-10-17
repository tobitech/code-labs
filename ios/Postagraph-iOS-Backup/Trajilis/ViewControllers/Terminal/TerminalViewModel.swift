//
//  TerminalViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import AWSS3
import Hakawai
import CoreLocation

final class TerminalViewModel {
   
    let appDelegate = (UIApplication.shared.delegate as? AppDelegate)
    var updateNotification:((String?) -> ())?
    var updateMessageCount:((String?) -> ())?
    
    init() {
        fetchNotification()
        getUnreadMessageCount()
    }
    func refreshData() {
        fetchNotification()
        getUnreadMessageCount()
    }
    
    func fetchNotification() {
        var count: String? = nil
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        APIController.makeRequest(request: .notificationCount(userId: id)) { (response) in
            switch response {
            case .failure(_):
                self.updateNotification?(count)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary,
                    let status = meta["status"] as? String else { return }
                if status == "200" {
                    if let message = meta["message"] as? String, message == "Unread Notification Count" {
                        if let data = json?["data"] as? JSONDictionary {
                            if let countVal = data["count"] as? String {
                                if countVal != "0" {
                                    count = countVal
                                }
                            }
                        }
                    }
                }
                self.updateNotification?(count)
            }
        }
    }
    
    func getUnreadMessageCount() {
        guard Helpers.isLoggedIn() else { return }
        APIController.makeRequest(request: .messageCount) { (response) in
            switch response {
            case .failure(_):
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? JSONDictionary else { return }
                var count = data["count"] as? String
                if let val = count {
                    if val == "0" {
                        count = nil
                    }
                }
                self.updateMessageCount?(count)
            }
        }
    }
}
