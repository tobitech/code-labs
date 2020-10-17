//
//  ChatVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 21/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import MessageKit


final class ChatVC: ChatBaseVC,TRBaseVCProtocol {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackgroundImage()        
        setupNavBar()
        getChats()
        navigationItem.largeTitleDisplayMode = .never
        self.listenForNewMessage()
        if var navigationArray = self.navigationController?.viewControllers,navigationArray.count > 2 {
            // to remove add group vc from stack
            navigationArray.remove(at: navigationArray.count - 2)
            self.navigationController?.viewControllers = navigationArray
        }
        
        
    }
    private func listenForNewMessage() {
        SocketIOManager.shared.socket.on("getMessage") { (data, ack) in
            SocketIOManager.shared.msgVC?.viewModel.refresh()
            if let json = data.first as? JSONDictionary {
                self.updateWithNewMsg(json:json)
            }
        }
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //SocketIOManager.shared.chatVC = self
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.view.backgroundColor = .appBG
        listenForTyping()
        self.messagesCollectionView.scrollToBottom(animated: true)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        //SocketIOManager.shared.chatVC = nil
    }
    override func configureMessageCollectionView() {
        super.configureMessageCollectionView()
        messagesCollectionView.backgroundColor = UIColor.clear
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        
    }
    private func setupNavBar() {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(topProfileTapped), for: .touchUpInside)
        
        let containerView = UIView()
        
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        containerView.addSubview(imageView)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        let imageViewConstraints: [NSLayoutConstraint] = [
            imageView.topAnchor.constraint(equalTo: containerView.topAnchor),
            imageView.bottomAnchor.constraint(equalTo: containerView.bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor),
            imageView.heightAnchor.constraint(equalToConstant: 40),
            imageView.widthAnchor.constraint(equalToConstant: 40)
        ]
        imageViewConstraints.forEach{ $0.isActive = true }
        imageView.layer.cornerRadius = 20
        imageView.layer.masksToBounds = true
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 1
        
        let label = UILabel()
        if let newUser = self.otherUser {
            if newUser.userImage.count > 0, let url = URL(string: newUser.userImage) {
                imageView.sd_setImage(with: url, completed: nil)
            }
            label.text = newUser.username
        } else if let contact = self.chatContact {
            self.connectToGroup()
            if contact.groupName.count > 0 {
                if contact.groupImage.count > 0, let url = URL(string: contact.groupImage) {
                    imageView.sd_setImage(with: url, completed: nil)
                }
                label.text = contact.groupName
            } else if let firstMember = contact.members.first {
                if firstMember.userImage.count > 0, let url = URL(string: firstMember.userImage) {
                    imageView.sd_setImage(with: url, completed: nil)
                }
                label.text = firstMember.username
            }
        }
        
        containerView.addSubview(label)
        label.translatesAutoresizingMaskIntoConstraints = false
        
        let labelConstraints: [NSLayoutConstraint] = [
            label.leadingAnchor.constraint(equalTo: imageView.trailingAnchor, constant: 8),
            label.centerYAnchor.constraint(equalTo: imageView.centerYAnchor),
            label.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: 8)
        ]
        
        labelConstraints.forEach{ $0.isActive = true }
        
        self.navigationItem.titleView = containerView
    }
    
    @objc func topProfileTapped() {
        
    }
    
    
}

//Mark: - Socket
extension ChatVC {
    
    func updateWithNewMsg(json:JSONDictionary) {
        if let msg = Message.getMessage(json: json) {
            insertMessage(msg)
            //self.markAllMsgRead(msg: msg)
        }
    }
    private func listenForTyping() {
        SocketIOManager.shared.socket.on("typing") { (data, ack) in
            if let json = data.first as? JSONDictionary {
                print(json)
            }
        }
    }
    
}

extension ChatVC {
    fileprivate func getChats() {
        if let grpId = self.chatContact?.groupId {
            APIController.makeRequest(request: .getChatMessages(groupId: grpId, count: 0, limit: 50)) { (response) in
                switch response {
                case .failure(_):
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else {
                            print("failed")
                            return
                    }
                    let mesgs = data.compactMap{ Message.getMessage(json: $0) }

                    self.messageList = mesgs.sorted(by: { (msg, msg1) -> Bool in
                        if msg.sentDate < msg1.sentDate {
                            return true
                        }
                        return false
                    })
                    self.messagesCollectionView.reloadData()
                    self.messagesCollectionView.scrollToBottom(animated: false)
                    
                }
            }
        }
    }
}


extension ChatVC: MessagesLayoutDelegate {
    
    func cellTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 22
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 20
    }
    
}


// MARK: - MessagesDisplayDelegate

extension ChatVC: MessagesDisplayDelegate {
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .darkText : .white
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    // MARK: - All Messages
    
    func backgroundColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .appRed
    }
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
        
        var corners: UIRectCorner = []
        corners.formUnion(.topRight)
        corners.formUnion(.bottomRight)
        corners.formUnion(.topLeft)
        corners.formUnion(.bottomLeft)
        
        return .custom { view in
            let radius: CGFloat = 8
            let path = UIBezierPath(roundedRect: view.bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
            let mask = CAShapeLayer()
            mask.path = path.cgPath
            view.layer.borderWidth = 0.1
            view.layer.cornerRadius = radius
            view.layer.borderColor = UIColor.black.withAlphaComponent(1).cgColor
            view.layer.mask = mask
            
        }
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        if indexPath.row < self.messageList.count {
            self.getAvatarFor(avatarView:avatarView,sender: self.messageList[indexPath.row].sender as! Sender)
            //avatarView.set(avatar: avatar)
            avatarView.layer.borderWidth = 0.5
            avatarView.layer.borderColor = UIColor.appRed.cgColor

        }
    }
    
    func configureAccessoryView(_ accessoryView: UIView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        // Cells are reused, so only add a button here once. For real use you would need to
        // ensure any subviews are removed if not needed
        //        guard accessoryView.subviews.isEmpty else { return }
        //        let button = UIButton(type: .infoLight)
        //        button.tintColor = .primaryColor
        //        accessoryView.addSubview(button)
        //        button.frame = accessoryView.bounds
        //        button.isUserInteractionEnabled = false // respond to accessoryView tap through `MessageCellDelegate`
        //        accessoryView.layer.cornerRadius = accessoryView.frame.height / 2
        //        accessoryView.backgroundColor = UIColor.primaryColor.withAlphaComponent(0.3)
    }

    func getAvatarFor(avatarView:AvatarView,sender: Sender) {
        let firstName = sender.displayName.components(separatedBy: " ").first
        let lastName = sender.displayName.components(separatedBy: " ").first
        let initials = "\(firstName?.first ?? "A")\(lastName?.first ?? "A")"
        
        if sender.senderId == self.currentUser.userId {
            if self.currentUser.userImage.count > 0,let url = URL(string: self.currentUser.userImage)  {
                avatarView.sd_setImage(with: url, completed: nil)
            } else {
                avatarView.set(avatar: Avatar(image: nil, initials: initials))
            }
        } else if let chatUsers = self.chatContact?.members {
            let users = chatUsers.filter { (cUser) -> Bool in
                if cUser.userId == sender.senderId {
                    return true
                }
                return false
            }
            if let selUser = users.first {
                if selUser.userImage.count > 0,let url = URL(string: selUser.userImage)  {
                    avatarView.sd_setImage(with: url, completed: nil)
                } else {
                    avatarView.set(avatar: Avatar(image: nil, initials: initials))
                }
            }
        }
        
        /*
        switch sender {
        case nathan:
            return Avatar(image: #imageLiteral(resourceName: "Nathan-Tannar"), initials: initials)
        case steven:
            return Avatar(image: #imageLiteral(resourceName: "Steven-Deutsch"), initials: initials)
        case wu:
            return Avatar(image: #imageLiteral(resourceName: "Wu-Zhong"), initials: initials)
        case system:
            return Avatar(image: nil, initials: "SS")
        default:
            return Avatar(image: nil, initials: initials)
        }
 */
    }
    
    
    func appMovedToBackground() {
        self.disConnectToGroup()
    }
    func applicationDidBecomeActive() {
         self.connectToGroup()
    }
}
