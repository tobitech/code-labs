//
//  MessageViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

final class MessageViewModel {
    
    var updateUnreadMessageCount:(() -> ())?
    var unReadAttributedText: NSAttributedString?
    var reload:(() -> ())?
    var messageUsers = [ChatContact]()
    var followers = [Followers]()
    
    init() {
        getUnreadMessageCount()
        fetchMessages()
    }
    
    var unreadCount: Int? = nil {
        didSet {
            guard let val = unreadCount else {
                unReadAttributedText = nil
                self.updateUnreadMessageCount?()
                return
            }
            
            let img = Helpers.circleAroundDigit(val, circleColor: UIColor.appRed, digitColor: UIColor.white, diameter: 16, font: UIFont.latoRegular(with: 12))
            let text = Helpers.addImage(initialText: "You've got", afterText: "new messages", image: img)
            unReadAttributedText = text
            updateUnreadMessageCount?()
        }
    }
    func refresh() {
        getUnreadMessageCount()
        fetchMessages()
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
                self.unreadCount = count.map({Int($0)}) ?? nil
            }
        }
    }
    
    func fetchMessages() {
        guard Helpers.isLoggedIn() else { return }
        APIController.makeRequest(request: .getChatUsers) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):                
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                self.messageUsers = data.compactMap{ ChatContact.init(json: $0) }
                self.reload?()
            }
        }
    }
    
    func search(text: String) {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        let param = ["other_user_id": id,"search_string": text, "user_id": id]
        APIController.makeRequest(request: .searchFollower(param: param)) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                self.followers = data.compactMap{ Followers.init(json: $0) }
                self.reload?()
            }
        }
    }
}
