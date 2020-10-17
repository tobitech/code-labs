//
//  ChatViewController+MessageOptions.swift
//  Trajilis
//
//  Created by bharats802 on 25/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

extension ChatViewController : ChatCellDelegate {
    
    @IBAction func btnCloseReplyTapped(sender:UIButton) {
        self.msgReplyingTo = nil
        self.resetSenderView()
    }
    
    func showMessageOptionsTapped(_ cell: ChatBaseCell) {
        guard let indxPath = self.tblView.indexPath(for: cell), !isDeleteMode else {
            return
        }
        if let msg = self.getMsgAtIndexPath(indexPath: indxPath),!msg.messageId.contains(".") {
            
            let controller = MessageOptionsViewController.instantiate(fromAppStoryboard: .message)
            controller.showEdit = cell.isCurrentSender && msg.msgType == ChatType.text.rawValue
            let presentationController = AlwaysPresentAsPopover.configurePresentation(forController: controller)
            
            if msg.msgType == ChatType.video.rawValue || msg.msgType == ChatType.audio.rawValue  {
                controller.preferredContentSize = CGSize(width: 180, height: 47)
            } else {
                controller.preferredContentSize = CGSize(width: 220, height: 47)
            }
            
            presentationController.sourceView = cell.viewBG
            presentationController.sourceRect = cell.viewBG.bounds
            presentationController.permittedArrowDirections = [.up,.down]
            
            self.present(controller, animated: true) {
                controller.view.superview?.layer.cornerRadius = 0
                if msg.msgType == ChatType.video.rawValue || msg.msgType == ChatType.audio.rawValue {
                    controller.btnCopy.isHidden = true
                    controller.viewCopySeparator.isHidden = true
                }
            }
            
            controller.didSelectOption = { [weak self](msgOption) in
                if let strngSelf = self {
                    switch msgOption {
                    case MessageOptions.reply.rawValue :
                        strngSelf.msgReplyingTo = msg
                        strngSelf.resetSenderView()

                    case MessageOptions.forward.rawValue :
                        guard let self = self else {return}
                        let controller: AddMemberToTripViewController = Router.get()
                        let viewModel = AddMemberToTripViewModel()
                        viewModel.mode = .forwardMessage
                        viewModel.excludeUserIds = [self.chatContact!.groupId]
                        controller.viewModel = viewModel
                        controller.title = "Forward Message"
                        let navController = UINavigationController(rootViewController: controller)
                        controller.onDone = {
                            let forwardToUsers = viewModel.selectedUsers.map({$0.userId})
                            self.forwardMessage(msg: msg, forwardToUsers: forwardToUsers)
                        }
                        self.present(navController, animated: true, completion: nil)
                    case MessageOptions.delete.rawValue :
                        self?.setForDeleteMode()
                    case MessageOptions.edit.rawValue:
                        self?.editMessage(message: msg)
                    case MessageOptions.copy.rawValue :
                        switch msg.msgType {
                        case ChatType.text.rawValue:
                            if let chatCell = cell as? ChatCell {
                                UIPasteboard.general.string = chatCell.lblMessage.text
                            }
                        case ChatType.image.rawValue:
                            if let chatCell = cell as? MediaChatCell {
                                UIPasteboard.general.image = chatCell.imgViewMedia.image
                            }
                        default:
                            break
                        }
                    default:
                        break
                    }
                    
                }
                
            }
        }
    }
    
    private func forwardMessage(msg: Message, forwardToUsers: [String]) {
        if !forwardToUsers.isEmpty {
            // create groups for new users
            let timestamp = NSDate().timeIntervalSince1970
            let c:String = String(format:"%.0f", timestamp)
            let selectedUsers = forwardToUsers.joined(separator: ",")
            let parameters = [
                "entity_id":selectedUsers,
                "parent_message_id":msg.messageId,
                "message_time_stamp":c,
                "user_id": Helpers.userId
            ]
            self.spinner(with: "Forwarding...",blockInteraction: true)
            APIController.makeRequest(request: .forwardMessage(param: parameters)) { [weak self](response) in
                if let self = self {
                    DispatchQueue.main.async {
                        self.hideSpinner()
                        switch response {
                        case .failure(_):
                            self.showAlert(message: "Unable to forward message at this time. Please try again later.")
                        case .success(let result):
                            guard let json = try? result.mapJSON() as? JSONDictionary,
                                let meta = json?["meta"] as? JSONDictionary,
                                let status = meta["status"] as? String else { return }
                            if status != "200" {
                                self.showAlert(message: "Unable to forward message at this time. Please try again later")
                            }
                        }
                    }
                }
            }
        }
    }
    
    @objc private func remoevDeleteMode() {
        self.isDeleteMode = false
        self.arrSelectedMsg.removeAll()
        self.viewSender.isUserInteractionEnabled = true
        self.tblView.reloadData()
        
        let moreOption = UIBarButtonItem(image: UIImage(named:"more-horizontal"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(openChatOptions))
        navigationItem.rightBarButtonItem = moreOption
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .done, target: self, action: #selector(self.close))
        barButtonItem.imageInsets = UIEdgeInsets(top: -1.5, left: -8, bottom: 1.5, right: 8)
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    @objc func deleteSelectedMsges() {
        if self.arrSelectedMsg.count > 0 {
            let alertController = UIAlertController(title: nil, message: "Are you sure, you want to delete selected messages?", preferredStyle: Helpers.actionSheetStyle())
            alertController.view.tintColor = UIColor.black
            let deleteForYou = UIAlertAction(title: "Delete For You", style: .default) { (action:UIAlertAction) in
                self.callDeleteMsg()
            }
            let deleteForAll = UIAlertAction(title: "Delete For All", style: .default) { (action:UIAlertAction) in
                self.callDeleteMsgForAll()
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) { (action:UIAlertAction) in
                self.remoevDeleteMode()
            }
            
            alertController.addAction(deleteForYou)
            if arrSelectedMsg.firstIndex(where: {$0.sender.senderId != Helpers.userId}) == nil {
                alertController.addAction(deleteForAll)
            }
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.remoevDeleteMode()
        }
    }
    func callDeleteMsgForAll() {
        guard let grpId = self.chatContact?.groupId,self.arrSelectedMsg.count > 0 else {
            return
        }
        let ids = self.arrSelectedMsg.map({$0.messageId}).joined(separator: ",")
        self.spinner(with: "Deleting...",blockInteraction:true)
        let param = ["user_id": self.currentUser.userId,"group_id": grpId, "message_ids": ids]
        APIController.makeRequest(request: .deleteSelectedMessageForAll(param: param)) { [weak self](response) in
            if let strngSelf = self {
                strngSelf.hideSpinner()
                strngSelf.viewSender.isUserInteractionEnabled = true
                switch response {
                case .failure(_):
                    strngSelf.showAlert(message: "Unable to delete message at this time. Please try again later")
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary,
                        let status = meta["status"] as? String else { return }
                    if status == "200" {
                        let message = strngSelf.messageList.filter({ (msg) -> Bool in
                            if strngSelf.arrSelectedMsg.contains(where: {$0.messageId == msg.messageId}) {
                                return false
                            }
                            return true
                        })
                        strngSelf.messageList = message
                    } else {
                        strngSelf.showAlert(message: "Unable to delete message at this time. Please try again later")
                    }
                }
                strngSelf.remoevDeleteMode()
                strngSelf.reloadMessages()
            }
        }
    }
    func callDeleteMsg() {
        guard let grpId = self.chatContact?.groupId,self.arrSelectedMsg.count > 0 else {
            return
        }
        let ids = self.arrSelectedMsg.map({$0.messageId}).joined(separator: ",")
        self.spinner(with: "Deleting...",blockInteraction:true)
        let param = ["user_id": self.currentUser.userId,"group_id": grpId, "message_ids": ids]
        APIController.makeRequest(request: .deleteSelectedMessage(param: param)) { [weak self](response) in
            if let strngSelf = self {
                strngSelf.hideSpinner()
                strngSelf.viewSender.isUserInteractionEnabled = true
                switch response {
                case .failure(_):
                    strngSelf.showAlert(message: "Unable to delete message at this time. Please try again later")
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary,
                        let status = meta["status"] as? String else { return }
                    if status == "200" {
                        let message = strngSelf.messageList.filter({ (msg) -> Bool in
                            if strngSelf.arrSelectedMsg.contains(where: {$0.messageId == msg.messageId}) {
                                return false
                            }
                            return true
                        })
                        strngSelf.messageList = message
                    } else {
                        strngSelf.showAlert(message: "Unable to delete message at this time. Please try again later")
                    }
                }
                strngSelf.remoevDeleteMode()
                strngSelf.reloadMessages()
            }
        }
    }
    func setForDeleteMode() {
        self.isDeleteMode = true
        self.arrSelectedMsg.removeAll()
        
        self.viewSender.isUserInteractionEnabled = false
        self.tblView.reloadData()
        
        let barButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(self.remoevDeleteMode))
        barButtonItem.imageInsets = UIEdgeInsets(top: -1.5, left: -8, bottom: 1.5, right: 8)
        navigationItem.leftBarButtonItem = barButtonItem
        
        let deleteBtn = UIBarButtonItem(image: UIImage(named: "trash"), landscapeImagePhone: nil, style: .plain, target: self, action: #selector(deleteSelectedMsges))
        deleteBtn.tintColor = UIColor(hexString: "#D63D41")
        navigationItem.rightBarButtonItem = deleteBtn
    
    }
    
    @objc private func close() {
        navigationController?.popViewController(animated: true)
    }

    func editMessage(message: Message) {
        self.isEditMode = true
        self.editingMessage = message
        self.txtView.insertText(message.getTextMsg())
        self.txtView.becomeFirstResponder()
    }
    
    func downloadTapped(indexPath:IndexPath) {
        if let msg = self.getMsgAtIndexPath(indexPath: indexPath) {
            MessageDownloadManager.shared.downloadService.startDownload(msg)
        }
        reload(indexPath)
    }
    
    func reload(_ indexPath: IndexPath) {
        self.tblView.reloadRows(at: [indexPath], with: .none)
    }
}
