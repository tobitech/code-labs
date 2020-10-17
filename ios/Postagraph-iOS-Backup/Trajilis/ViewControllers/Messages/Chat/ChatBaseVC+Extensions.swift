//
//  ChatBaseVC+Extensions.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/07/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation
import InputBarAccessoryView

// MARK: - MessageInputBarDelegate

extension ChatBaseVC: InputBarAccessoryViewDelegate {

    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        func doSendMessage() {
            for component in inputBar.inputTextView.components {
                if let str = component as? String {
                    sendMessage(text: str)

                }
            }
            inputBar.inputTextView.text = String()
            messagesCollectionView.scrollToBottom(animated: true)
        }

        if self.chatContact != nil {
            doSendMessage()
        }
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


}
