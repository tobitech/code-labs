//
//  MessagesVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit


class MessagesVC: BaseVC {
    
    var isSearching = false
    var viewModel = MessageViewModel()
    var isFromChatNotification: Bool = false
    var notificationGroupId:String?
    
    var onDismiss: (()->())?
    var onCreateGroup: (() -> ())?
    var onOpenChat: ((ChatContact, CondensedUser) -> ())?
    
    private var didAnimate: Bool = false
    
    @IBOutlet weak var messageUnreadCountLabel: UILabel!
    @IBOutlet weak var searchTextFieldContainer: UIView!
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addGroupInstructionView: UIView!
    @IBOutlet weak var noSearchResultInstruction: UIStackView!
    @IBOutlet weak var addGroupInstruction: UIStackView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.isHidden = true
        addGroupInstructionView.isHidden = true
        
        tableView.delegate = self
        tableView.dataSource = self
        
        searchTextField.delegate = self
        searchTextFieldContainer.set(borderWidth: 0.5, of: UIColor(hexString: "#e5e5e5"))
        messageUnreadCountLabel.rounded()
        messageUnreadCountLabel.superview?.set(cornerRadius: 8)
        
        title = "Messages"
        
        viewModel.reload = { [weak self] in
            guard let self = self else {return}
            if self.isSearching {
                if self.viewModel.followers.isEmpty {
                    self.tableView.isHidden = true
                    self.addGroupInstructionView.isHidden = false
                    self.addGroupInstruction.isHidden = true
                    self.noSearchResultInstruction.isHidden = false
                }else {
                    self.tableView.isHidden = false
                    self.addGroupInstructionView.isHidden = true
                }
            }else {
                if self.viewModel.messageUsers.isEmpty {
                    self.tableView.isHidden = true
                    self.addGroupInstructionView.isHidden = false
                    self.addGroupInstruction.isHidden = false
                    self.noSearchResultInstruction.isHidden = true
                }else {
                    self.addGroupInstructionView.isHidden = true
                    if self.tableView.isHidden {
                       self.tableView.isHidden = false
                    }
                }
                self.checkIfFromNotification()
            }
            if self.didAnimate || self.presentingViewController == nil {
                self.tableView.reloadData()
            } else {
                self.didAnimate = true
                DispatchQueue.main.async {
                    self.animateTable(tableView: self.tableView)
                }
            }
        }
        viewModel.updateUnreadMessageCount = { [weak self] in
            guard let self = self else {return}
            self.messageUnreadCountLabel.isHidden = self.viewModel.unreadCount == nil
            guard let count = self.viewModel.unreadCount else {return}
            self.messageUnreadCountLabel.text = " \(count) "
        }
        SocketIOManager.shared.msgVC = self
        
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: false)
        }
    }
    
    func checkIfFromNotification() {
        if let grpId = self.notificationGroupId, self.isFromChatNotification {
            
            let grp = viewModel.messageUsers.filter { (chat) -> Bool in
                if chat.groupId == grpId {
                    return true
                }
                return false
            }
            
            if let selectedGrp = grp.first {
                guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
                openChat(contact: selectedGrp, user: user.condensedUser, animated: false)
//                let controller = ChatViewController.instantiate(fromAppStoryboard: .message)
//                controller.chatContact = selectedGrp
//                controller.currentUser = user.condensedUser
//                controller.hidesBottomBarWhenPushed = true
                self.notificationGroupId = nil
                self.isFromChatNotification = false
//                navigationController?.pushViewController(controller, animated: true)
            } else {
                self.spinner() // wait untill we get refresh callbacl
            }
        }
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)        
        showNavigationBar()
        self.checkIfFromNotification()
        self.viewModel.refresh()
        if didAnimate {
            self.tableView.reloadData()
        }
//        self.animateTable(tableView: self.tableView)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if presentingViewController == nil {
            didAnimate = false
            tableView.reloadData()
        }
    }
    
    @IBAction private func addMember(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.onCreateGroup?()
        })
    }
    
    @IBAction private func close(_ sender: Any?) {
        dismiss(animated: true, completion: {
            self.onDismiss?()
        })
    }
    
    private func openChat(contact: ChatContact, user: CondensedUser, animated: Bool = true) {
        dismiss(animated: animated, completion: {
            self.onOpenChat?(contact, user)
        })
    }
    
}

extension MessagesVC: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        let controller = ChatViewController.instantiate(fromAppStoryboard: .message)
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
        if isSearching {
            let follower = viewModel.followers[indexPath.row]
            spinner(with: "", blockInteraction: true)
            ChatViewController.createGroup(withUser: follower.condensedUser) { (chatContact) in
                self.hideSpinner()
                if let grp = chatContact {
//                    controller.chatContact = grp
//                    controller.currentUser = user.condensedUser
//                    controller.hidesBottomBarWhenPushed = true
                    self.searchTextField.text = ""
                    self.view.endEditing(true)
                    self.isSearching = false
//                    self.navigationController?.pushViewController(controller, animated: true)
                    self.openChat(contact: grp, user: user.condensedUser)
                } else {
                    self.showAlert(message: "App is unable to process request.")
                }
            }
        } else {
            let chatContact = viewModel.messageUsers[indexPath.row]
//            controller.chatContact = chatContact
//            controller.currentUser = user.condensedUser
//            controller.hidesBottomBarWhenPushed = true
//            navigationController?.pushViewController(controller, animated: true)
            self.openChat(contact: chatContact, user: user.condensedUser)
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    private func openChatForUserAt(index: Int) {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
        
        let group = self.viewModel.messageUsers[index]
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        alertController.view.tintColor = UIColor.black
        
        
        let action1 = UIAlertAction(title: "Leave Group", style: .default) { (action:UIAlertAction) in
            self.showAlert(title: "Leave Group", message: "This can't be undone. Are you sure you want to leave the group?", actionTitle: "Leave", fire: {
                self.leaveGroup(groupId:group.groupId)
            })
        }
        let action2 = UIAlertAction(title: "Clear Chat", style: .default) { (action:UIAlertAction) in
            self.showAlert(title: "Clear Chat", message: "This can't be undone. Are you sure you want to clear the chat?", actionTitle: "Clear", fire: {
                self.clearChatGroupMsgs(groupId: group.groupId)
            })
        }
        let action3 = UIAlertAction(title: "Delete Group", style: .default) { (action:UIAlertAction) in
            self.showAlert(title: "Delete Group", message: "This can't be undone. Are you sure you want to delete the group?", actionTitle: "Delete", fire: {
                self.deleteGroup(groupId: group.groupId)
            })
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        
        if group.groupName.count > 0 {
            alertController.addAction(action1)
            if group.admin?.userId == user.condensedUser.userId {
                alertController.addAction(action3)
            }
        }
        alertController.addAction(action2)
        alertController.addAction(cancel)
        self.present(alertController, animated: true, completion: nil)
    }
    
    private func deleteGroup(groupId:String) {
        
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        self.spinner(with: "Deleting...", blockInteraction: true)
        APIController.makeRequest(request: .deleteGroup(groupId:groupId,userId:id)) { [weak self](response) in
            
            guard let self = self else {
                return
            }
            self.hideSpinner()
            switch response {
            case .failure(_):
                self.showAlert(message: "Unable to delete group at this time. Please try again later")
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary,
                    let status = meta["status"] as? String else { return }
                if status == "200" {
                    self.viewModel.refresh()
                    self.deleteLocally(key: groupId)
                } else {
                    self.showAlert(message: "Unable to delete group at this time. Please try again later")
                }
            }
            
        }
    }
    
    private func clearChatGroupMsgs(groupId:String) {
        
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        self.spinner(with: "Deleting...", blockInteraction: true)
        APIController.makeRequest(request: .deleteAllMessage(groupId:groupId,userId:id)) { [weak self](response) in
            
            guard let self = self else {
                return
            }
            self.hideSpinner()
            switch response {
            case .failure(_):
                self.showAlert(message: "Unable to delete messages at this time. Please try again later")
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary,
                    let status = meta["status"] as? String else { return }
                if status == "200" {
                    self.viewModel.refresh()
                    self.deleteLocally(key: groupId)
                } else {
                    self.showAlert(message: "Unable to delete messages at this time. Please try again later")
                }
            }
            
        }
    }
    
    private func deleteLocally(key:String) {
        do {
            try DataStorage.shared.dataStorage.removeObject(forKey: "GRPC-\(key)")
        } catch {
            print(error)
        }
    }
    
    private func leaveGroup(groupId:String) {
        
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        self.spinner(with: "Leaving...", blockInteraction: true)
        APIController.makeRequest(request: .leaveGroup(groupId:groupId,userId:id)) { [weak self](response) in
            guard let self = self else {
                return
            }
            self.hideSpinner()
            switch response {
            case .failure(_):
                self.showAlert(message: "Unable to leave group at this time. Please try again later")
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary,
                    let status = meta["status"] as? String else { return }
                if status == "200" {
                    self.viewModel.refresh()
                } else {
                    self.showAlert(message: "Unable to leave group at this time. Please try again later")
                }
            }
            
        }
    }
    
}

extension MessagesVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !didAnimate { return 0 }
        return isSearching ? viewModel.followers.count : viewModel.messageUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if isSearching {
            let cell = tableView.dequeue(AddMemberToTripTableViewCell.self, for: indexPath)
            let follower = viewModel.followers[indexPath.row]
            cell.user = CondensedUser(userImage: follower.pic, userId: follower.userId, profileImageType: "", username: follower.username, firstName: follower.country, lastName: follower.state)
            return cell
        } else {
            let cell = tableView.dequeue(MessageGroupTableViewCell.self, for: indexPath)
            let message = viewModel.messageUsers[indexPath.row]
            cell.configure(with: message)
            cell.onLongPressed = { [weak self] in
                self?.openChatForUserAt(index: indexPath.row)
            }
            return cell
        }
    }
    
}

extension MessagesVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        search(text: newText)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        search(text: textField.text!)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        search(text: "")
        return true
    }
    
    private func search(text: String) {
        searchIconImageView.tintColor = text.isEmpty ? UIColor(hexString: "#e5e5e5") : UIColor(hexString: "#aeaeae")
        isSearching = false
        if text.isEmpty {
            if viewModel.messageUsers.isEmpty {
                tableView.isHidden = true
                addGroupInstructionView.isHidden = false
                addGroupInstruction.isHidden = false
                noSearchResultInstruction.isHidden = true
            }else {
                addGroupInstructionView.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
            }
        }else {
            addGroupInstructionView.isHidden = true
            tableView.isHidden = false
            isSearching = true
            viewModel.search(text: text)
        }
    }
    
}

//extension MessagesVC: UISearchBarDelegate {
//    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
//
//    }
//
//    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
//        isSearching = !searchText.isEmpty
//        search(text: searchText)
//    }
//
//    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//        searchBar.text = ""
//        searchBar.resignFirstResponder()
//        isSearching = false
//    }
//    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
//        if let txt = searchBar.text,!txt.isEmpty {
//            isSearching = true
//            search(text: txt)
//        } else {
//            isSearching = false
//            searchBar.resignFirstResponder()
//        }
//    }
//}
