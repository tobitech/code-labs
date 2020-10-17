//
//  ChatBaseVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import MessageKit
//import MessageInputBar
//import Message

/// A base class for the example controllers
class ChatBaseVC: MessagesViewController, MessagesDataSource {
    
    
    var currentUser: CondensedUser!
    var otherUser: CondensedUser?
    var chatContact:ChatContact?
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var messageList: [Message] = []
    
    let refreshControl = UIRefreshControl()
    
    let formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .full
        return formatter
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureMessageCollectionView()
        configureMessageInputBar()
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
    }
    
    
    @objc
    func loadMoreMessages() {
        self.refreshControl.endRefreshing()
    }
    
    func configureMessageCollectionView() {
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messageCellDelegate = self
        
        scrollsToBottomOnKeyboardBeginsEditing = true // default false
        maintainPositionOnKeyboardFrameChanged = true // default false
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        //layout?.sectionInset = UIEdgeInsets(top: 1, left: 8, bottom: 1, right: 8)
        
        let avatarPosition = (AvatarPosition.init(vertical: .messageLabelTop))
        layout?.setMessageIncomingAvatarPosition(avatarPosition)
        layout?.setMessageOutgoingAvatarPosition(avatarPosition)
        
        let outgoingAvatarOverlap: CGFloat = 0
        layout?.setMessageIncomingMessagePadding(UIEdgeInsets(top: 0, left: -10, bottom: 0, right: 10))
        layout?.setMessageIncomingMessageTopLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 33, bottom: outgoingAvatarOverlap, right: 0)))
        layout?.setMessageIncomingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .left, textInsets: UIEdgeInsets(top: 0, left: 25, bottom: outgoingAvatarOverlap, right: 0)))

        layout?.setMessageOutgoingMessagePadding(UIEdgeInsets(top: 0, left: 10, bottom: 0, right: -10))
        layout?.setMessageOutgoingMessageTopLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: outgoingAvatarOverlap, right: 33)))
        layout?.setMessageOutgoingMessageBottomLabelAlignment(LabelAlignment(textAlignment: .right, textInsets: UIEdgeInsets(top: 0, left: 0, bottom: outgoingAvatarOverlap, right: 25)))
        
    }
    
    func configureMessageInputBar() {
        messageInputBar.delegate = self
        messageInputBar.inputTextView.tintColor = .appRed
        messageInputBar.sendButton.tintColor = .appRed
        messageInputBar.sendButton.image = UIImage(named:"sendMessageDisabled")
        messageInputBar.sendButton.title = nil
    }
    
    // MARK: - Helpers
    
    func insertMessage(_ message: Message) {
        messageList.append(message)
        // Reload last section to update header/footer labels and insert a new one
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }
    
    func isLastSectionVisible() -> Bool {
        
        guard !messageList.isEmpty else { return false }
        
        let lastIndexPath = IndexPath(item: 0, section: messageList.count - 1)
        
        return messagesCollectionView.indexPathsForVisibleItems.contains(lastIndexPath)
    }
    
    // MARK: - MessagesDataSource
    
    func currentSender() -> SenderType {
        
        return Sender(senderId: currentUser.userId, displayName: currentUser.username)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messageList.count
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        let msg = messageList[indexPath.section]
        self.markAllMsgRead(msg: msg)
        return messageList[indexPath.section]
    }
    
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if indexPath.section % 3 == 0 {
            return NSAttributedString(string: MessageKitDateFormatter.shared.string(from: message.sentDate), attributes: [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: UIColor.darkGray])
        }
        return nil
    }
    
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        let name = message.sender.displayName
        return NSAttributedString(string: name, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
    }
    
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        let dateString = message.sentDate.toString(dateFormat: "HH:mm", dateStyle: .medium)
        return NSAttributedString(string: dateString, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
    }
   

    
    
    func isTimeLabelVisible(at indexPath: IndexPath) -> Bool {
        return indexPath.section % 3 == 0 && !isPreviousMessageSameSender(at: indexPath)
    }
    
    func isPreviousMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section - 1 >= 0 else { return false }
        return messageList[indexPath.section].sender.senderId == messageList[indexPath.section - 1].sender.senderId
    }
    
    func isNextMessageSameSender(at indexPath: IndexPath) -> Bool {
        guard indexPath.section + 1 < messageList.count else { return false }
        return messageList[indexPath.section].sender.senderId == messageList[indexPath.section + 1].sender.senderId
    }
    
    func setTypingIndicatorHidden(_ isHidden: Bool, performUpdates updates: (() -> Void)? = nil) {
        //updateTitleView(title: "MessageKit", subtitle: isHidden ? "2 Online" : "Typing...")
        //        setTypingBubbleHidden(isHidden, animated: true, whilePerforming: updates) { [weak self] (_) in
        //            if self?.isLastSectionVisible() == true {
        //                self?.messagesCollectionView.scrollToBottom(animated: true)
        //            }
        //        }
        //        messagesCollectionView.scrollToBottom(animated: true)
    }
}

// MARK: - MessageCellDelegate

extension ChatBaseVC: MessageCellDelegate {
    
    func didTapAvatar(in cell: MessageCollectionViewCell) {
        print("Avatar tapped")
    }
    
    func didTapMessage(in cell: MessageCollectionViewCell) {
        print("Message tapped")
    }
    
    func didTapCellTopLabel(in cell: MessageCollectionViewCell) {
        print("Top cell label tapped")
    }
    
    func didTapMessageTopLabel(in cell: MessageCollectionViewCell) {
        print("Top message label tapped")
    }
    
    func didTapMessageBottomLabel(in cell: MessageCollectionViewCell) {
        print("Bottom label tapped")
    }
    
    func didTapAccessoryView(in cell: MessageCollectionViewCell) {
        print("Accessory view tapped")
    }
    
}

// MARK: - MessageLabelDelegate

extension ChatBaseVC: MessageLabelDelegate {
    
    func didSelectAddress(_ addressComponents: [String: String]) {
        print("Address Selected: \(addressComponents)")
    }
    
    func didSelectDate(_ date: Date) {
        print("Date Selected: \(date)")
    }
    
    func didSelectPhoneNumber(_ phoneNumber: String) {
        print("Phone Number Selected: \(phoneNumber)")
    }
    
    func didSelectURL(_ url: URL) {
        print("URL Selected: \(url)")
    }
    
    func didSelectTransitInformation(_ transitInformation: [String: String]) {
        print("TransitInformation Selected: \(transitInformation)")
    }
    
}

extension ChatBaseVC {

    private func insert(message: Message) {
        messagesCollectionView.performBatchUpdates({
            messagesCollectionView.insertSections([messageList.count - 1])
            if messageList.count >= 2 {
                messagesCollectionView.reloadSections([messageList.count - 2])
            }
        }, completion: { [weak self] _ in
            if self?.isLastSectionVisible() == true {
                self?.messagesCollectionView.scrollToBottom(animated: true)
            }
        })
    }

    func sendMessage(text: String) {
        guard let chatUser = self.chatContact,chatUser.groupId.count > 0 else {
            return
        }
        let groupId = chatUser.groupId
        let trimmedString = text.trimmingCharacters(in: .whitespaces)
        
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
        
        let timestamp = Date().timeIntervalSince1970
        let c: String = String(format:"%.0f", timestamp)
        let parent_message_id  = "000000000000000000000000"
        let parent_message = ""
        let parent_message_time = "0"
        let is_forwarded = "false"
        let is_replied = "false"
        let parent_message_type  = ""
        let parent_message_thumbnail  = ""
        let parent_message_sender_name = ""
        
        let myDict: JSONDictionary = [
            "group_id" : groupId,
            "hashtags" : "",
            "message": trimmedString,
            "receiver": [members],
            "sender": user,
            "time_stamp": c,
            "type": "text",
            "url": "",
            "thumbnail": "",
            "parent_message_id": parent_message_id,
            "parent_message": parent_message,
            "parent_message_time": parent_message_time,
            "is_forwarded": is_forwarded,
            "is_replied": is_replied,
            "parent_message_sender_name": parent_message_sender_name,
            "parent_message_thumbnail": parent_message_thumbnail,
            "parent_message_type": parent_message_type
        ]
        print(myDict)
        let jsonData = try? JSONSerialization.data(withJSONObject: myDict, options: [])
        let jsonString = String(data: jsonData!, encoding: .utf8)
        print(jsonString)
        SocketIOManager.shared.socket.emit("sendMessage", myDict)
    }
    func markAllMsgRead(msg:Message) {
        if let user = (UIApplication.shared.delegate as? AppDelegate)?.user,msg.sender.senderId != user.id,msg.isRead == false  {
            print("marking read: \(msg.messageId)")
            APIController.makeRequest(request: .markAsRead(messageId: msg.messageId, userId: user.id)) { (response) in
                // do nothing for now
            }
        }
    }
}
