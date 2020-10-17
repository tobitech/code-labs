//
//  ConversationsViewController.swift
//  Hollaport
//
//  Created by Oluwatobi Omotayo on 05/08/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import UIKit
import MapKit
import CoreData
import Contacts
import QuickLook

internal class ConversationsViewController: MessagesViewController, MainTabBarControllerDelegate {
    let refreshControl = UIRefreshControl()
    
    var chat: ChatMO? {
        didSet {
            fetchMessages()
            // also setup chat title view here.
            setupChatTitleView()
        }
    }
    var fetchedMessages = [MessageMO]()
    var groupedMessageList = [[MockMessage]]()
    
    var isTyping = false
    var typingTimer: Timer?
    var lastSeenTimer: Timer?
    
    lazy var formatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()
    
    let quickLookController = QLPreviewController()
    var previewItems: [URL]?
    
    lazy var chatClosedView: ChatClosedView = {
        let view = ChatClosedView()
        view.isHidden = true
        return view
    }()
    
    var chatHeader = HeaderReusableView()
    
    var plusButton = InputBarButtonItem()
    
    // MARK: - View Life Cycle
    
    fileprivate func setupChatTitleView() {
        chatTitleView.usernameLabel.text = self.chat?.title ?? ""
        
        if let imageUrl = self.chat?.picture, let url = URL(string: imageUrl) {
            chatTitleView.avatarImageView.sd_setImage(with: url, placeholderImage: #imageLiteral(resourceName: "avatar_default"), options: [], completed: nil)
        } else {
            chatTitleView.avatarImageView.image = #imageLiteral(resourceName: "avatar_default")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        (self.tabBarController as? MainTabBarController)?.mainTabBarDelegate = self
        
        customizeInputBar()
        messagesCollectionView.backgroundColor = Color.custom(hexString: "#f8f8f8", alpha: 1.0).value
        
        setupMessagesCollectionView()
        
        // observe is typing
        NotificationCenter.default.addObserver(self, selector: #selector(handleIsTyping(_:)), name: NSNotification.Name(rawValue: kIsTypingNotification), object: nil)
    }
    
    private func setupBasedOnChatType() {
        if chat?.type == ChatType.single.rawValue {
            getUserLastSeen()
        } else {
            setupChatClosedView()
            getGroupMembers()
            
            if CoreDataManager.shared.userIsInGroup(id: chat?.groupId) {
                chatClosedView.isHidden = true
            } else {
                chatClosedView.isHidden = false
            }
            
        }
    }
    
    private func setupChatClosedView() {
        if let view = inputAccessoryView {
            view.addSubview(chatClosedView)
            chatClosedView.fillSuperView()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        setupChatTitleView()
        
        setupBasedOnChatType()
        
        // call this to update online status.
        if chat?.type == ChatType.single.rawValue {
            updateUserOnlineStatus()
        }
        
        // restore collectionView bottom inset.
        messageCollectionViewBottomInset = keyboardOffsetFrame.height
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        clearUnreadMessagesForChat()
        
        // invalidate last seen timer
        lastSeenTimer?.invalidate()
        
        // delete chat if no messages.
        removeEmptyChat()
        
    }
    
    private func removeEmptyChat() {
        if let chat = self.chat {
            if !CoreDataManager.shared.chatHasMessages(chatId: chat.chatId) {
                
                if let viewController = self.navigationController?.topViewController {
                    if viewController is ChatsViewController {
                        CoreDataManager.shared.persistentContainer.viewContext.delete(chat)
                        CoreDataManager.shared.saveContext()
                    }
                }
                
            }
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
        groupedMessageList.removeAll()
        fetchedMessages.removeAll()
    }
    
    // MARK: - Load Messages
    
    func setupMockMessageList() {
        var messages: [MockMessage] = []
        self.fetchedMessages.forEach({ (message) in
            if let mockMessage = self.processFetchedMessage(message: message) {
                messages.append(mockMessage)
            }
        })
        
        messages.sort(by: {
            $0.sentDate.compare($1.sentDate) == .orderedAscending
        })
        
        // Test
        let unitFlags = Set<Calendar.Component>([.day])
        
        let d = Dictionary(grouping: messages) { Calendar.current.dateComponents(unitFlags, from: $0.sentDate as Date ) }
        
        let sortArray = Array(d.values).sorted { ($0[0].sentDate) < ($1[0].sentDate) }
        self.groupedMessageList = sortArray
        
        self.messagesCollectionView.reloadData()
        self.messagesCollectionView.scrollToBottom()
    }
    
    func fetchMessages() {
        guard let id = chat?.chatId else { return }
        CoreDataManager.shared.fetchMessages(chatId: id, offset: 0) { (messages) in
            DispatchQueue.main.async {
                
                self.fetchedMessages = messages ?? []
                self.fetchRecentMessages()
                
                self.setupMockMessageList()
                
                // clear any unread message
                self.clearUnreadMessagesForChat()
            }
        }
    }
    
    func setupMessagesCollectionView() {
        fetchMessages()
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messagesCollectionView.messageCellDelegate = self
        messageInputBar.delegate = self
        
        messageInputBar.sendButton.tintColor = UIColor(red: 69/255, green: 193/255, blue: 89/255, alpha: 1)
        scrollsToBottomOnKeybordBeginsEditing = true
        maintainPositionOnKeyboardFrameChanged = true
        
        messagesCollectionView.addSubview(refreshControl)
        refreshControl.addTarget(self, action: #selector(loadMoreMessages), for: .valueChanged)
        
        messagesCollectionView.register(HeaderReusableView.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader)
        
        // PIN SECTION HEADER TO TOP
        let layout = messagesCollectionView.collectionViewLayout as? MessagesCollectionViewFlowLayout
        layout?.sectionHeadersPinToVisibleBounds = true
        
    }
    
    func clearUnreadMessagesForChat() {
        guard let chat = chat else { return }
        CoreDataManager.shared.clearUnreadChatMessages(chat: chat)
        
        // set last message as read
        chat.lastMessage?.status = MessageStatus.read.rawValue
        CoreDataManager.shared.saveContext()
        // service call to update delivery status on server
        // ...
    }
    
    @objc func loadMoreMessages() {
        print("loading more messages")
        refreshControl.endRefreshing()
    }
    
    func processFetchedMessage(message: MessageMO) -> MockMessage? {
        
        guard let type = message.type,
            let senderId = message.senderId,
            let displayName = message.senderName,
            let messageId = message.id,
            let deliveryStatus = message.status,
            let date = message.createdAt
            else { return nil }
        
        let sender = Sender(id: senderId, displayName: displayName)
        let errorMockMessage = MockMessage(text: "This message cannot be viewed", sender: sender, messageId: messageId, date: date, status: deliveryStatus)
        
        switch type {
        case ChatMessageType.text.rawValue:
            if let text = message.content {
//                return MockMessage(text: text, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
                let color: UIColor
                if sender.id == currentSender().id {
                    color = Color.solid06.value
                } else {
                    color = Color.solid01.value
                }
                
                let attributedText = NSAttributedString(string: text, attributes: [NSAttributedString.Key.font: Font(.installed(.OpenSansRegular), size: .standard(.h4)).instance, NSAttributedString.Key.foregroundColor: color])
                
                let mockMessage = MockMessage(attributedText: attributedText, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
                return mockMessage
            } else {
                return errorMockMessage
            }
        case ChatMessageType.image.rawValue:
            if let imageData = message.imageInfo?.imageData, let image = UIImage(data: imageData as Data) {
                return MockMessage(image: image, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
            } else if let imageLink = message.imageInfo?.imageUrl, let imageUrl = URL(string: imageLink) {
                return MockMessage(photoUrl: imageUrl, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
            } else {
                return errorMockMessage
            }
        case ChatMessageType.contact.rawValue:
            guard let content = message.content,
                let contactDict = convertToDictionary(text: content),
                let contactName = contactDict["displayName"] as? String else { return errorMockMessage }
            
            let contact = CNMutableContact()
            contact.givenName = contactName
            
            if let phoneNumbers = contactDict["phoneNumbers"] as? [[String: Any]] {
                phoneNumbers.forEach { (phoneNumber) in
                    if let number = phoneNumber["value"] as? String {
                        contact.phoneNumbers.append(CNLabeledValue(label: CNLabelPhoneNumberMobile, value: CNPhoneNumber(stringValue: number)))
                    }
                }
            }
            
            return MockMessage(contact: contact, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
        case ChatMessageType.document.rawValue:
            if let docUrlString = message.documentInfo?.fileUrl, let docUrl = URL(string: docUrlString) {
                let doc = MockMessage(documentName: docUrl.lastPathComponent, url: docUrl, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
                return doc
            } else if let docUrlString = message.documentInfo?.documentUrl, let docUrl = URL(string: docUrlString) {
                return MockMessage(documentName: docUrl.lastPathComponent, url: docUrl, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
            } else {
                return errorMockMessage
            }
        case ChatMessageType.audio.rawValue:
            if let fileUrl = message.audioInfo?.fileUrl, let url = URL(string: fileUrl)  {
                return MockMessage(audioURL: url, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
            } else if let fileUrl = message.audioInfo?.audioUrl, let url = URL(string: fileUrl) {
                return MockMessage(audioURL: url, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
            } else {
                return errorMockMessage
            }
        case ChatMessageType.video.rawValue:
            if let fileUrl = message.videoInfo?.fileUrl, let url = URL(string: fileUrl) {
                return MockMessage(videoUrl: url, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
            } else if let videoUrl = message.videoInfo?.videoUrl, let url = URL(string: videoUrl) {
                return MockMessage(videoUrl: url, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
            } else {
                return errorMockMessage
            }
        case ChatMessageType.location.rawValue:
            guard let content = message.content, let locationDict = convertToDictionary(text: content), let latitude = locationDict["latitude"] as? Double, let longitude = locationDict["longitude"] as? Double else { return errorMockMessage }
            
            let location = CLLocation(latitude: latitude, longitude: longitude)
            return MockMessage(location: location, sender: sender, messageId: messageId, date: date, status: deliveryStatus)
            
        default:
//            fatalError("Unrecognized mock message type")
            return errorMockMessage
        }
        
    }
    
    // MARK: - Handle titleview tapped
    
    override func handleTitleTapped() {
        if chat?.type == ChatType.single.rawValue {
            let chatInfoController = ChatInfoViewController()
            chatInfoController.chat = self.chat
            navigationController?.pushViewController(chatInfoController, animated: true)
        } else {
            let groupInfoController = GroupInfoViewController(style: .grouped)
            groupInfoController.chat = self.chat
            navigationController?.pushViewController(groupInfoController, animated: true)
        }
    }
    
    
    // MARK: - Additional Menu item
    
    override func collectionView(_ collectionView: UICollectionView, canPerformAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        if (action == NSSelectorFromString("delete:")) {
            return true
        } else {
            return super.collectionView(collectionView, canPerformAction: action, forItemAt: indexPath, withSender: sender)
        }
        
    }
    
    override func collectionView(_ collectionView: UICollectionView, performAction action: Selector, forItemAt indexPath: IndexPath, withSender sender: Any?) {
        
        if (action == NSSelectorFromString("delete:")) {
            let sourceView = collectionView.cellForItem(at: indexPath)
            let options = UIAlertController.actionSheetWith(title: nil, message: nil, sourceView: sourceView, sourceFrame: sourceView?.bounds)
            options.addAction(UIAlertAction(title: "Delete Message", style: .destructive, handler: { (_) in
                
            }))
            options.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            self.present(options, animated: true, completion: nil)
        }
        
        super.collectionView(collectionView, performAction: action, forItemAt: indexPath, withSender: sender)
        
    }
    
    func showMessageHasBeenDeleted(indexPath: IndexPath) {
        
        let selectedMessage = groupedMessageList[indexPath.section][indexPath.row]
        
        let attributedText = NSAttributedString(string: "You deleted this message", attributes: [NSAttributedString.Key.font: Font(.installed(.OpenSansRegular), size: .standard(.h4)).instance, NSAttributedString.Key.foregroundColor: Color.solid06.value])
        let deletedMessage = MockMessage(attributedText: attributedText, sender: currentSender(), messageId: selectedMessage.messageId, date: selectedMessage.sentDate, status: "")
        
        // change data source
        groupedMessageList[indexPath.section][indexPath.row] = deletedMessage
        
        messagesCollectionView.reloadItems(at: [indexPath])
        
        deleteMessage(messageId: selectedMessage.messageId)
    }
    
    
}


// MARK: - MessageCollectionViewCell override for menu.

extension MessageCollectionViewCell {
    
    override open func delete(_ sender: Any?) {
        // Get the collectionView
        if let collectionView = self.superview as? UICollectionView {
            // Get indexPath
            if let indexPath = collectionView.indexPath(for: self) {
                // Trigger action
                collectionView.delegate?.collectionView?(collectionView, performAction: NSSelectorFromString("delete:"), forItemAt: indexPath, withSender: sender)
            }
        }
    }
}



// MARK: - MessagesDataSource

extension ConversationsViewController: MessagesDataSource {
    func currentSender() -> Sender {
        let user = UserDefaults.standard.currentUser()
        let id = user?.id ?? 0
        let name = user?.name ?? ""
        return Sender(id: "\(id)", displayName: name)
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return groupedMessageList.count
    }
    
    func numberOfItems(inSection section: Int, in messagesCollectionView: MessagesCollectionView) -> Int {
        if groupedMessageList.count > 0 {
            return groupedMessageList[section].count
        }
        
        return 0
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return groupedMessageList[indexPath.section][indexPath.row]
    }
    
    // SECTION TOP LABEL
    func cellTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        return nil
    }
    
    // MESSAGE BUBBLE BOTTOM LABEL OUTSIDE BUBBLE ON BOTTOM
    func messageBottomLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        
        if message.sender.id == currentSender().id {
            return NSAttributedString(string: message.status, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption2)])
        } else {
            return nil
        }
        
    }
    
    // MESSAGE BUBBLE TOP LABEL OUTSIDE BUBBLE ON TOP
    func messageTopLabelAttributedText(for message: MessageType, at indexPath: IndexPath) -> NSAttributedString? {
        if chat?.type == ChatType.group.rawValue {
            if message.sender.id != currentSender().id {
                return NSAttributedString(string: message.sender.displayName, attributes: [NSAttributedString.Key.font: UIFont.preferredFont(forTextStyle: .caption1)])
            }
        }
        
        return nil
    }
    
}





// MARK: - MessagesDisplayDelegate

extension ConversationsViewController: MessagesDisplayDelegate {
    
    func messageHeaderView(for indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageReusableView {
        self.chatHeader = messagesCollectionView.dequeueReusableHeaderView(HeaderReusableView.self, for: indexPath)
        print("Grouped Messages: \(groupedMessageList[indexPath.section].count)")
        if groupedMessageList.count > 0 {
            let message: MockMessage
            message = groupedMessageList[indexPath.section][indexPath.row]
            
            self.chatHeader.setup(with: getDayName(timestamp: TimeInterval(stringToTimestamp(dateToString(message.sentDate, "yyyy-MM-dd HH:mm:ss Z"), "yyyy-MM-dd HH:mm:ss Z"))))
            
        }
        
        return self.chatHeader
    }
    
    // MARK: - Text Messages
    
    func textColor(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> UIColor {
        return isFromCurrentSender(message: message) ? .white : .darkText
    }
    
    func detectorAttributes(for detector: DetectorType, and message: MessageType, at indexPath: IndexPath) -> [NSAttributedString.Key: Any] {
        return MessageLabel.defaultAttributes
    }
    
    func enabledDetectors(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> [DetectorType] {
        return [.url, .address, .phoneNumber, .date, .transitInformation]
    }
    
    // MARK: - All Messages
    
    func messageStyle(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageStyle {
//        let corner: MessageStyle.TailCorner = isFromCurrentSender(message: message) ? .bottomRight : .bottomLeft
        return .bubble // .bubbleTail(corner, .curved)
        //        let configurationClosure = { (view: MessageContainerView) in}
        //        return .custom(configurationClosure)
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        
        avatarView.sd_setImage(with: URL(string: chat?.picture ?? ""), placeholderImage: #imageLiteral(resourceName: "avatar_default"), options: [], completed: nil)
    }
    
    // MARK: - Location Messages
    
    func annotationViewForLocation(message: MessageType, at indexPath: IndexPath, in messageCollectionView: MessagesCollectionView) -> MKAnnotationView? {
        let annotationView = MKAnnotationView(annotation: nil, reuseIdentifier: nil)
        let pinImage = #imageLiteral(resourceName: "pin")
        annotationView.image = pinImage
        annotationView.centerOffset = CGPoint(x: 0, y: -pinImage.size.height / 2)
        return annotationView
    }
    
    func animationBlockForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> ((UIImageView) -> Void)? {
        return { view in
            view.layer.transform = CATransform3DMakeScale(0, 0, 0)
            view.alpha = 0.0
            UIView.animate(withDuration: 0.6, delay: 0, usingSpringWithDamping: 0.9, initialSpringVelocity: 0, options: [], animations: {
                view.layer.transform = CATransform3DIdentity
                view.alpha = 1.0
            }, completion: nil)
        }
    }
    
    func snapshotOptionsForLocation(message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> LocationMessageSnapshotOptions {
        
        return LocationMessageSnapshotOptions()
    }
    
}


// MARK: - MessagesLayoutDelegate

extension ConversationsViewController: MessagesLayoutDelegate {
    
    func headerViewSize(for section: Int, in messagesCollectionView: MessagesCollectionView) -> CGSize {
        
        let fullHeight = CGSize(width: messagesCollectionView.bounds.width, height: HeaderReusableView.height)
        
        if section == 0 {
            return fullHeight
        }
        
        // get previous message
        let previousIndexPath = IndexPath(row: 0, section: section - 1)
        let previousMessage = messageForItem(at: previousIndexPath, in: messagesCollectionView)
        let currentMessage = messageForItem(at: IndexPath(row: 0, section: section), in: messagesCollectionView)
        
        if currentMessage.sentDate.isInSameDayOf(date: previousMessage.sentDate) {
            return CGSize.zero
        }
        
        return fullHeight
        
    }
    
    func messageTopLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
    func messageBottomLabelHeight(for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> CGFloat {
        return 16
    }
    
}

// MARK: - MessageLabelDelegate

extension ConversationsViewController: MessageLabelDelegate {
    
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




