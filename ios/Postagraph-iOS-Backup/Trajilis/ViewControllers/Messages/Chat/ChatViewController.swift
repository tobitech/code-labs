//
//  ChatViewController.swift
//  Trajilis
//
//  Created by bharats802 on 20/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import MessageKit
import MobileCoreServices
import AVKit
import IQKeyboardManagerSwift
import Hakawai
import SDWebImage

class ChatViewController: BaseVC {
    
    let maxTextViewHeight:CGFloat = 120
    let defaultTextViewHeight:CGFloat = 40
    let defaultLimit = 20
    
    let sendingText = "Sending..."
    @IBOutlet weak var viewSender:UIView!
    @IBOutlet weak var tblView:UITableView!
    @IBOutlet weak var btnAttachements:UIButton!
    @IBOutlet weak var btnSendMsg:UIButton!
    
    @IBOutlet weak var userListView: UIView!
    @IBOutlet weak var userListCollectionView: UICollectionView!
    @IBOutlet weak var addUserButton: UIButton!
    @IBOutlet weak var titleButton: UIButton!
    
    @IBOutlet weak var txtView:HKWTextView!
    @IBOutlet weak var txtViewPlaceHolder: UILabel!
    
    @IBOutlet var textViewHeightConstraint: NSLayoutConstraint!
    private var plugin: HKWMentionsPlugin?

    var audioPlayer: TRAudioPlayer?
    var audioTimer:Timer?
    @IBOutlet weak var lblAudioTime:UILabel!
    
    var currentUser: CondensedUser!    
    var chatContact:ChatContact?
    lazy var refreshControl: UIRefreshControl = {
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action:
            #selector(handleRefresh(_:)),
                                 for: UIControl.Event.valueChanged)
        refreshControl.tintColor = UIColor.red
        
        return refreshControl
    }()
    
    var isDeleteMode:Bool = false
    var isEditMode: Bool = false
    var editingMessage: Message?
    var arrSelectedMsg = [Message]()
    // vocie recording
    
    var recordingSession: AVAudioSession?
    var audioRecorder: AVAudioRecorder?
    
    @IBOutlet var viewVoiceReocrd: UIView!
    @IBOutlet var voiceViewWidthConstraint: NSLayoutConstraint!
    @IBOutlet var btnMIC: UIButton!
    @IBOutlet var imgMic: UIImageView!
    var audioFilename:URL?
    
    @IBOutlet var keyboardHeightLayoutConstraint: NSLayoutConstraint!

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    
    var messageList: [Message] = []
    var sectionData: [String] = [String]()
    var rowData:[String:[Message]] = [String:[Message]]()
    
    
    //MessageOptions
    @IBOutlet var cnstrntReplyHeaderHeight: NSLayoutConstraint!
    @IBOutlet var cnstrntReplyLabelLeading :NSLayoutConstraint!
    @IBOutlet var imgReplyImgView:UIImageView!
    @IBOutlet var lblReplyMessage:UILabel!
    var msgReplyingTo:Message?
    
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        return imagePicker
    }()
    var currentUsersPage:Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Messages"
        
        userListCollectionView.delegate = self
        userListCollectionView.dataSource = self
        
        IQKeyboardManager.shared.enable = false
        
        MessageDownloadManager.shared.delegate = self
        MessageUploadManager.shared.delegate = self
 
        self.setUI()
        
        if let chatContact = self.chatContact {
            self.connectToGroup()
            
            if let msgs = self.getMsgLocally(key: chatContact.groupId),msgs.count > 0 {
                self.messageList = msgs
                self.reloadMessages()
            }
            
            if chatContact.groupName.isEmpty {
                tblView.tableHeaderView = nil
                titleButton.setTitle(chatContact.members.first?.username, for: .normal)
            }else {
                addUserButton.isHidden = !chatContact.isAdmin
                titleButton.setTitle(chatContact.groupName, for: .normal)
            }
            titleButton.isUserInteractionEnabled = true
        }
        
        self.getChats()
        
        if let image1 =  UIImage(named:"mic"), let image2 = UIImage(named:"mic-2") {
            self.imgMic.image = UIImage.animatedImage(with: [image1, image2], duration: 1)
        }
        self.imgMic.stopAnimating()
        self.imgMic.isHidden = true
        
        self.voiceViewWidthConstraint.constant = 50
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(longPressed))
        self.viewVoiceReocrd.addGestureRecognizer(longPressRecognizer)
 
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillHideNotification, object: nil)
        notificationCenter.addObserver(self, selector: #selector(adjustForKeyboard), name: UIResponder.keyboardWillChangeFrameNotification, object: nil)
        self.setupTextView()
    }
    private func setupTextView() {
        self.txtView.simpleDelegate = self
        let mode = HKWMentionsChooserPositionMode.customLockTopNoArrow
        // In this demo, the user may explicitly begin a mention with either the '@' or '+' characters
        let controlCharacters = CharacterSet(charactersIn: "@#")
        // The user may also begin a mention by typing three characters (set searchLength to 0 to disable)
        let mentionsPlugin = HKWMentionsPlugin(chooserMode: mode, controlCharacters: controlCharacters, searchLength: -1)
        
        mentionsPlugin?.chooserViewClass = CustomChooserView.self
        
        mentionsPlugin?.resumeMentionsCreationEnabled = true
        mentionsPlugin?.chooserViewEdgeInsets = UIEdgeInsets(top: 2, left: 0.5, bottom: 0.5, right: 0.5)
        plugin = mentionsPlugin
        plugin?.chooserViewBackgroundColor = .lightGray
        mentionsPlugin?.delegate = MentionsManager.shared
        self.txtView.controlFlowPlugin = mentionsPlugin
        plugin?.setChooserTopLevel(view, attachmentBlock: { (chooserView) in
            chooserView!.bottomAnchor.constraint(equalTo: self.txtView.topAnchor, constant: 0).isActive = true
            chooserView!.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
            chooserView!.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
            chooserView!.heightAnchor.constraint(equalToConstant: 200).isActive = true
        })
    }
    
    @objc func adjustForKeyboard(notification: Notification) {
        if txtView.text.isEmpty {
            self.isEditMode = false
            self.editingMessage = nil
        }
        if let userInfo = notification.userInfo {
            let endFrame = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
            let endFrameY = endFrame?.origin.y ?? 0
            let duration:TimeInterval = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
            let animationCurveRawNSN = userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber
            let animationCurveRaw = animationCurveRawNSN?.uintValue ?? UIView.AnimationOptions.curveEaseInOut.rawValue
            let animationCurve:UIView.AnimationOptions = UIView.AnimationOptions(rawValue: animationCurveRaw)
            if endFrameY >= UIScreen.main.bounds.size.height {
                self.keyboardHeightLayoutConstraint.constant = 0.0
            } else {
                self.keyboardHeightLayoutConstraint.constant = endFrame?.size.height ?? 0.0
            }
            self.scrollToBottom()
            UIView.animate(withDuration: duration,
                           delay: TimeInterval(0),
                           options: animationCurve,
                           animations: { self.view.layoutIfNeeded() },
                           completion: nil)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showNavigationBar()
        SocketIOManager.shared.chatVC = self
        IQKeyboardManager.shared.enable = false
        
        if (chatContact?.groupName ?? "").isEmpty {
            tblView.tableHeaderView = nil
            userListView.isHidden = true
            
            titleButton.setTitle(chatContact?.members.first?.username, for: .normal)
        }else {
            titleButton.setTitle(chatContact?.groupName, for: .normal)
        }
        userListCollectionView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        //listenForTyping()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        SocketIOManager.shared.chatVC = nil
        self.audioPlayer?.stop()
        self.audioPlayer = nil
        if let grpId = self.chatContact?.groupId {
            self.saveLocally(key: grpId)
        }
        IQKeyboardManager.shared.enable = true        
    }
    deinit {
        print("ChatViewController -- deinit")
        NotificationCenter.default.removeObserver(self)
    }
    func setUI() {
        self.tblView.addSubview(self.refreshControl)

        self.resetSenderView()
        self.listenForNewMessage()

        self.txtView.inputAccessoryView = UIView(frame: CGRect.zero)
        self.txtView.reloadInputViews()

//        self.btnMIC.tintColor = .appRed
        if var navigationArray = self.navigationController?.viewControllers {
            let newVCs = navigationArray.filter({
                !$0.isKind(of: CreateGroupViewController.classForCoder()) && !$0.isKind(of: AddMemberToTripViewController.classForCoder())
            })
            
            if newVCs.count != navigationArray.count {
                self.navigationController?.viewControllers = newVCs
            }
        }
        
        setSendButton(visibile: false)

//        self.viewVoiceReocrd.backgroundColor = .appBG
//        self.setupNavBar()
//        self.view.backgroundColor = .appBG
        navigationItem.largeTitleDisplayMode = .never

        // setup textview
//        txtView.layer.cornerRadius = 15
//        txtView.layer.borderWidth = 0.5
//        txtView.layer.borderColor = UIColor.gray.cgColor
//        txtView.translatesAutoresizingMaskIntoConstraints = false
//        txtView.textContainerInset = UIEdgeInsets(top: 10, left: 5, bottom: 10, right: 5)
        self.textViewHeightConstraint.constant = defaultTextViewHeight
        
        // setu tableview
        
        self.tblView.backgroundColor = UIColor.clear
        self.tblView.tableFooterView = UIView()
        self.tblView.separatorStyle = .none
        self.tblView.register(ChatCell.classForCoder(), forCellReuseIdentifier: ChatCell.identifier)
        self.tblView.register(UINib(nibName: ChatCell.nibName, bundle: nil), forCellReuseIdentifier: ChatCell.identifier)
        
        self.tblView.register(MediaChatCell.classForCoder(), forCellReuseIdentifier: MediaChatCell.identifier)
        self.tblView.register(UINib(nibName: MediaChatCell.nibName, bundle: nil), forCellReuseIdentifier: MediaChatCell.identifier)
        
        self.tblView.register(AudioChatCell.classForCoder(), forCellReuseIdentifier: AudioChatCell.identifier)
        self.tblView.register(UINib(nibName: AudioChatCell.nibName, bundle: nil), forCellReuseIdentifier: AudioChatCell.identifier)
        
        
        self.tblView.estimatedRowHeight = 80
        self.tblView.rowHeight = UITableView.automaticDimension
        self.tblView.dataSource = self
        self.tblView.delegate = self
        
    }
    
    @objc func handleRefresh(_ refreshControl: UIRefreshControl) {
        self.getChats()
    }
    
    private func setupNavBar() {
        let button = UIButton.init(type: .custom)
        button.addTarget(self, action: #selector(topProfileTapped), for: .touchUpInside)
        
        let containerView = UIView()
        containerView.addSubview(button)
        button.fill()
        
        
        let imageView = UIImageView()
        imageView.tag = 990
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
        imageView.layer.borderWidth = 2
        
        let label = UILabel()
        label.tag = 991
        label.textColor = UIColor.white
        if let contact = self.chatContact {
            self.connectToGroup()
            if contact.groupName.count > 0 {
                
                imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
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
    func updateGroup(group:ChatContact) {
        self.chatContact = group
        if let titleView = self.navigationItem.titleView {
            if let label = titleView.viewWithTag(991) as? UILabel {
                label.text = group.groupName
            }
            if let imgView = titleView.viewWithTag(990) as? UIImageView {
                if let url = URL(string: group.groupImage) {
                    imgView.sd_setImage(with: url, completed: nil)
                } else {
                    imgView.sd_setImage(with: nil, completed: nil)
                }
            }
        }
    }
    
    @IBAction private func topProfileTapped() {
        if let contact = self.chatContact {
            if contact.groupName.count > 0 {
                let controller = CreateGroupViewController.instantiate(fromAppStoryboard: .message)
                controller.chatVC = self
                controller.chatContact = contact
                navigationController?.pushViewController(controller, animated: true)
            } else {
                if let firstMember = contact.members.first {
                    let controller: ProfileViewController = Router.get()
                    let vModel = ProfileViewModel(userId: firstMember.userId)
                    controller.viewModel = vModel
                    controller.hidesBottomBarWhenPushed = true
                    navigationController?.pushViewController(controller, animated: true)
                }
            }
        }
    }
    func isFromCurrentUser(msg: Message) -> Bool {
        if msg.sender.senderId == self.currentUser.userId {
            return true
        }
        return false
    }
    func insertMessage(_ message: Message) {
        messageList.append(message)
        var date = ""
        if Calendar.current.isDateInToday(message.sentDate) {
            date = "Today"
        } else {
            date = message.sentDate.toString(dateFormat: "EEE, dd MMM", dateStyle: .medium)
        }
        var shouldReload = false
        if !self.sectionData.contains(date) {
            self.sectionData.append(date)
            shouldReload = true
        }
        
        var arrMsg = [Message]()
        if let msgs = self.rowData[date] {
            arrMsg = msgs
        }
        arrMsg.append(message)
        self.rowData[date] = arrMsg
        if shouldReload {
            self.reloadMessages()
            self.scrollToBottom(animated: false)
        } else {
            self.tblView.performBatchUpdates({[weak self] in
                if let section = self?.sectionData.firstIndex(of: date) {
                    let row = arrMsg.count - 1
                    self?.tblView.insertRows(at: [IndexPath(row:row, section: section)], with: .fade)
                    self?.scrollToBottom()
                }
            }) { [weak self](_) in
                self?.scrollToBottom()
            }
        }
    }
    
    
    @IBAction func addUserTapped(_ sender: Any) {
        if chatContact?.groupName.isEmpty ?? true {
            return
        }
        let controller = CreateGroupViewController.instantiate(fromAppStoryboard: .message)
        controller.chatVC = self
        controller.chatContact = chatContact
        navigationController?.pushViewController(controller, animated: true)
    }
    
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func btnAttachmentTapped(sender:UIButton) {
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        alertController.view.tintColor = UIColor.black
        
//        let cameraPhotoAction = UIAlertAction(title: "Open Camera", style: .default) { (action:UIAlertAction) in
//            self.openCamera(isCamera: true)
//        }

        let cameraPhotoAction = UIAlertAction(title: "Take Photo", style: .default) { (action:UIAlertAction) in
            self.showCamera()
        }
        let cameraVideoAction = UIAlertAction(title: "Record Video", style: .default) { (action:UIAlertAction) in
            self.showCamera(isVideo:true)
        }
 
        
        let library = UIAlertAction(title: "Photo & Video Library", style: .default) { (action:UIAlertAction) in
            self.openCamera(isCamera: false)
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        
        alertController.addAction(cameraPhotoAction)
        alertController.addAction(cameraVideoAction)
        alertController.addAction(library)
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
    }
    func showCamera(isVideo:Bool = false) {
        let controller = CameraVC.instantiate(fromAppStoryboard: .video)
        controller.recordType = .simpleCamera
        if !isVideo {
            controller.cameraMode = .Image
        }
        
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        
        controller.didCaptureImage = {[weak self] (image,error) in
            if let img = image {
                self?.uploadImage(image: img)
            } else {
                self?.showAlert(message: "App is not able to take picture right now. Please try again later.")
            }
        }
        controller.didRecordVideo = { [weak self](url,error) in
            if let videoURL = url {
                self?.uploadVideo(videoURL: videoURL)
            } else {
                self?.showAlert(message: "App is not able to record video right now. Please try again later.")
            }
        }
        
        self.present(navController, animated: true, completion: nil)
    }
    fileprivate func openCamera(isCamera:Bool) {
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType =  isCamera ? .camera : .photoLibrary
        imagePicker.mediaTypes = [kUTTypeMovie as String, kUTTypeImage as String]
        present(imagePicker, animated: true, completion: nil)
    }
    @IBAction func btnSendTapped(sender:UIButton) {
        guard  let message = self.txtView.text,!message.isEmpty,self.chatContact != nil else {
            return
        }
        let trimmedString = message.trimmingCharacters(in: .whitespacesAndNewlines)
        if trimmedString.count > 0 {
            if var msg = self.editingMessage, self.isEditMode {
                msg.kind = .text(trimmedString)
                var msgs = messageList
                if let index = msgs.firstIndex(where: { $0.messageId == msg.messageId }) {
                    msgs.remove(at: index)
                }
                msgs.append(msg)
                messageList = msgs.sorted(by: { (msg, msg1) -> Bool in
                    if msg.sentDate < msg1.sentDate {
                        return true
                    }
                    return false
                })
                self.reloadMessages()
                sendEditedMessage(message: msg, newText: message)
            } else {
                sendMessage(data: trimmedString, msgType: .text)
            }
            self.editingMessage = nil
            self.isEditMode = false
            self.txtView.text = ""
            self.textViewDidChange(txtView)
            textViewHeightConstraint.constant = defaultTextViewHeight
        }
    }
    func resetSenderView() {
        textViewHeightConstraint.constant = defaultTextViewHeight
        self.txtView.resignFirstResponder()
        self.imgReplyImgView.image = nil
        if let msgReply = self.msgReplyingTo {
            self.cnstrntReplyHeaderHeight.constant = 60
            self.lblReplyMessage.text = msgReply.getTextMsg()
            self.lblReplyMessage.isHidden = true
            self.imgReplyImgView.contentMode = .scaleAspectFill
            if msgReply.msgType == ChatType.text.rawValue {
                self.imgReplyImgView.isHidden = true
                self.lblReplyMessage.isHidden = false
            } else {
                self.imgReplyImgView.isHidden = false
                if msgReply.msgType == ChatType.video.rawValue {
                    if self.isFromCurrentUser(msg: msgReply),let thumbPath = msgReply.localThumbnailURL() {
                        imgReplyImgView.sd_setImage(with: thumbPath, completed: nil)
                    } else if let strUrl = msgReply.thumbnailURL,let url = URL(string: strUrl)  {
                        imgReplyImgView.sd_setImage(with: url, completed: nil)
                    }
                    
                } else if msgReply.msgType == ChatType.image.rawValue {
                    if msgReply.isDownloaded(),let localURL = msgReply.localFilePath() {
                        imgReplyImgView.sd_setImage(with: localURL, completed: nil)
                    } else {
                        if let strUrl = msgReply.mediaURL,let url = URL(string: strUrl)   {
                            imgReplyImgView.sd_setImage(with: url, completed: nil)
                        }
                    }
                } else if msgReply.msgType == ChatType.audio.rawValue {
                    self.imgReplyImgView.image = UIImage(named:"mic_smallRed")
                    self.imgReplyImgView.contentMode = .center
                }
            }
        } else {
            self.cnstrntReplyHeaderHeight.constant = 0
            
        }
        
    }
    func reloadMessages() {
        DispatchQueue.main.async {
            self.createHeaderDates()
            self.tblView.reloadData()
            if !self.refreshControl.isRefreshing {
                self.scrollToBottom(animated: false)
            }
        }
    }
    func scrollToBottom(animated:Bool = true){
        DispatchQueue.main.async {
            let totalSections = self.tblView.numberOfSections
            if totalSections > 0 {
                let section = totalSections - 1
                let totalRows = self.tblView.numberOfRows(inSection: section)
                if totalRows > 0 {
                    let rows = totalRows - 1
                    let indexPath = IndexPath(row: rows, section: section)
                    self.tblView.scrollToRow(at: indexPath, at: .bottom, animated: animated)
                }
            }
        }
    }
    
    class func createGroup(withUser:CondensedUser,onCompletion:((ChatContact?)->Void)?) {
        
        var members = [JSONDictionary]()
        members.append([
            "user_id": withUser.userId,
            "user_image": withUser.userImage,
            "user_name": withUser.username
            ])
        if let user = (UIApplication.shared.delegate as? AppDelegate)?.user {
            members.append([
                "user_id": user.id,
                "user_image": user.profileImage,
                "user_name": user.username
                ])
        }
        
        let param = [
            "group_image": "",
            "group_members": members,
            "group_name":"",
            "user_id": UserDefaults.standard.value(forKey: USERID) as! NSString
            ] as JSONDictionary
        
        
        APIController.makeRequest(request: .createGroup(param: param)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    onCompletion?(nil)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary else {
                        print("failed")
                        onCompletion?(nil)
                        return
                    }
                    if let data = json?["data"] as? JSONDictionary  {
                        let group = ChatContact.init(json: data)
                        onCompletion?(group)
                    }
                    break
                }
            }
        }
    }
    
    @IBAction func openChatOptions() {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user, let group = chatContact else { return }
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        alertController.view.tintColor = UIColor.black
        
        
        let action1 = UIAlertAction(title: "Leave Group", style: .destructive) { (action:UIAlertAction) in
            self.showAlert(title: "Leave Group", message: "This can't be undone. Are you sure you want to leave the group?", actionTitle: "Leave", fire: {
                self.leaveGroup(groupId:group.groupId)
            })
        }
        let action2 = UIAlertAction(title: "Clear Chat", style: .destructive) { (action:UIAlertAction) in
            self.showAlert(title: "Clear Chat", message: "This can't be undone. Are you sure you want to clear the chat?", actionTitle: "Clear", fire: {
                self.clearChatGroupMsgs(groupId: group.groupId)
            })
        }
        let action3 = UIAlertAction(title: "Delete Group", style: .destructive) { (action:UIAlertAction) in
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
                    self.navigationController?.popViewController(animated: true)
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
                    self.deleteLocally(key: groupId)
                    self.messageList = []
                    self.reloadMessages()
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
                    self.navigationController?.popViewController(animated: true)
                } else {
                    self.showAlert(message: "Unable to leave group at this time. Please try again later")
                }
            }
            
        }
    }
}
extension ChatViewController:UITableViewDelegate,UITableViewDataSource {
    func getMsgAtIndexPath(indexPath: IndexPath) -> Message? {
        if self.sectionData.count > indexPath.section {
            let section = self.sectionData[indexPath.section]
            if let arrMsgs = self.rowData[section] {
                if arrMsgs.count > indexPath.row {
                    let message = arrMsgs[indexPath.row]
                    return message
                }
            }
        }
        return nil
    }
    func getIndexPathForMsg(msg:Message) -> IndexPath? {
        
        var date = ""
        if Calendar.current.isDateInToday(msg.sentDate) {
            date = "Today"
        } else {
            date = msg.sentDate.toString(dateFormat: "EEE, dd MMM", dateStyle: .medium)
        }
        if let section = sectionData.firstIndex(of: date) {
            let arrMsg = self.rowData[date]
            let rowIndex = arrMsg?.firstIndex { (msgO) -> Bool in
                if msgO.messageId == msg.messageId {
                    return true
                }
                return false
            }
            if let row = rowIndex {
                return IndexPath(row: row, section: section)
            }
        }
        return nil
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return max(sectionData.count, 1)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if self.sectionData.count > section {
            let section = self.sectionData[section]
            if let arrMsgs = self.rowData[section],arrMsgs.count > 0 {
                return arrMsgs.count
            }
        }
        return 0
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return sectionData.isEmpty ? 0 : 28
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if self.sectionData.count > section {
            let hdrView = UIView(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 25))
            hdrView.backgroundColor = .clear
            let lblTitle = UILabel(frame: CGRect(x: UIScreen.main.bounds.width/4, y: 5, width: UIScreen.main.bounds.width/2, height: 25))
            lblTitle.backgroundColor = UIColor.white
            lblTitle.font = UIFont(name: "PTSans-Regular", size: 11)!
            lblTitle.textColor = UIColor(hexString: "#8E8E93")
            lblTitle.textAlignment = .center
            lblTitle.layer.cornerRadius = 12.5
            lblTitle.layer.masksToBounds = true
            lblTitle.text = self.sectionData[section]
            hdrView.addSubview(lblTitle)
            return hdrView
        }
        return nil
        
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell:UITableViewCell!
        if let message = self.getMsgAtIndexPath(indexPath: indexPath) {
            switch message.msgType {
            case ChatType.audio.rawValue:
                cell = self.getAudioCell(message: message,indexPath:indexPath)
            case ChatType.image.rawValue,ChatType.video.rawValue:
                cell = self.getMediaCell(message: message,indexPath:indexPath)
            case ChatType.text.rawValue:
                cell = self.getTextCell(message: message,indexPath:indexPath)
            default:
                cell = self.tblView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath) as! ChatCell
            }
            
            if let chatCell = cell as? ChatBaseCell {
                if self.isDeleteMode && message.sender.senderId == Helpers.userId {
                    chatCell.imgViewSelect.isHidden = false
                    if self.arrSelectedMsg.contains(where: {$0.messageId == message.messageId}) {
                        chatCell.imgViewSelect.image = UIImage(named:"selected-dot")
                    } else {
                        chatCell.imgViewSelect.image = UIImage(named:"unselected-dot")
                    }
                } else {
                    chatCell.imgViewSelect.isHidden = true
                }
                chatCell.delegate = self
                chatCell.imgViewReply.contentMode = .scaleAspectFill
                if message.isForwaredMsg {
                    chatCell.setForForwared()
                    
                } else if message.isRepliedMsg {
                    chatCell.setForReplied()
                    chatCell.imgViewReply.image  = nil
                    if let parentType = message.parent_message_type {
                        
                        var timeStr = ""
                        if let dateString = message.parent_message_sentdate?.toString(dateFormat: "HH:mm", dateStyle: .medium) {
                            timeStr = ": " + dateString
                        }
                        if let parentSender = message.parent_message_sender_name,parentSender.count > 0 {
                            if parentSender == self.currentUser.username {
                                chatCell.lblReplyBtm.text = "you" + timeStr
                            } else {
                                chatCell.lblReplyBtm.text = parentSender + timeStr
                            }
                        }
                        switch parentType {
                        case ChatType.text.rawValue:
                            chatCell.cnstrntReplyLabelBtm.constant = 25
                            chatCell.lblReplyText.text = message.parent_message ?? ""
                            
                        case ChatType.image.rawValue,ChatType.video.rawValue:
                            chatCell.cnstrntReplyLabelBtm.constant = 70
                            chatCell.lblReplyText.text = ""
                            if let thumbNailURL = message.parent_message_thumbnail,let url = URL(string: thumbNailURL) {
                                chatCell.imgViewReply.sd_setImage(with: url, completed: nil)
                            }
                        case ChatType.audio.rawValue,ChatType.video.rawValue:
                            chatCell.cnstrntReplyLabelBtm.constant = 60
                            chatCell.lblReplyText.text = ""
                            chatCell.imgViewReply.contentMode = .center
                            chatCell.imgViewReply.image = UIImage(named:"mic_smallRed")
                        default:
                            break
                        }
                    }
                    
                chatCell.viewReplyForwardBack.indexPath = indexPath
                    
                }
            
                let tapRecognizer = UITapGestureRecognizer.init(target: self, action: #selector(viewReplyForwardTapped(sender:)))
                chatCell.viewReplyForwardBack.addGestureRecognizer(tapRecognizer)
                
                
            }

            
        }
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? ChatBaseCell {
            cell.setSelected(false, animated: false)
            if let msg = self.getMsgAtIndexPath(indexPath: indexPath), msg.sender.senderId == Helpers.userId {
                if let index = self.arrSelectedMsg.firstIndex(where: {$0.messageId == msg.messageId}){
                    self.arrSelectedMsg.remove(at: index)
                    cell.imgViewSelect.image = UIImage(named:"unselected-dot")
                } else {
                    self.arrSelectedMsg.append(msg)
                    cell.imgViewSelect.image = UIImage(named:"selected-dot")
                }
            }
        }
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell == self.audioPlayer?.cell {
            self.audioPlayer?.stop()
            self.audioPlayer?.displayLink?.invalidate()
            self.audioPlayer?.cell = nil
            self.audioPlayer = nil
        }
    }
    func getTextCell(message:Message,indexPath:IndexPath) -> UITableViewCell {
        let cell = self.tblView.dequeueReusableCell(withIdentifier: ChatCell.identifier, for: indexPath) as! ChatCell
        cell.set(isCurrentSender: self.isFromCurrentUser(msg: message))
        cell.setBottomLabels(msg: message, isCurrentSender: self.isFromCurrentUser(msg: message))
        self.setAvatarFor(imgView: cell.imgView, sender: message.sender as! Sender)
        
        switch message.kind {
            case .text(let text), .emoji(let text):
                cell.lblMessage.text = text
        default:
            break
        }
        return cell
    }
    
    func getAudioCell(message:Message,indexPath:IndexPath) -> UITableViewCell {
        let cell = self.tblView.dequeueReusableCell(withIdentifier: AudioChatCell.identifier, for: indexPath) as! AudioChatCell
        cell.set(isCurrentSender: self.isFromCurrentUser(msg: message))
        cell.setBottomLabels(msg: message, isCurrentSender: self.isFromCurrentUser(msg: message))
        self.setAvatarFor(imgView: cell.imgView, sender: message.sender as! Sender)
        cell.slider.value = 0
        cell.btnPlay.setImage(UIImage(named:"enabledButton"), for: .normal)
        cell.btnPlay.indexPath = indexPath
        cell.btnPlay.addTarget(self, action: #selector(mediaButtonTapped(sender:)), for: .touchUpInside)
        if let strMedia = message.mediaURL,let url = URL(string: strMedia) {
            cell.setupDownloadStatus(download: MessageDownloadManager.shared.downloadService.activeDownloads[url])
        }
        return cell
    }
    func getMediaCell(message:Message,indexPath:IndexPath) -> UITableViewCell {
        let cell = self.tblView.dequeueReusableCell(withIdentifier: MediaChatCell.identifier, for: indexPath) as! MediaChatCell
        cell.set(isCurrentSender: self.isFromCurrentUser(msg: message))
        cell.setBottomLabels(msg: message, isCurrentSender: self.isFromCurrentUser(msg: message))
        self.setAvatarFor(imgView: cell.imgView, sender: message.sender as! Sender)        
        if message.msgType == ChatType.image.rawValue {
            if message.isDownloaded(),let localURL = message.localFilePath() {
                cell.imgViewMedia.sd_setImage(with: localURL, completed: nil)
            } else {
                if let strUrl = message.mediaURL,let url = URL(string: strUrl)   {
                    cell.imgViewMedia.sd_setImage(with: url, completed: nil)
                }
            }
            cell.btnPlay.setImage(nil, for: .normal)
        } else if message.msgType == ChatType.video.rawValue {
            if self.isFromCurrentUser(msg: message),let thumbPath = message.localThumbnailURL() {
                cell.imgViewMedia.sd_setImage(with: thumbPath, completed: nil)
            } else if let strUrl = message.thumbnailURL,let url = URL(string: strUrl)  {
                cell.imgViewMedia.sd_setImage(with: url, completed: nil)
            }
            cell.btnPlay.setImage(UIImage(named:"enabledButton"), for: .normal)
        }
        cell.btnPlay.indexPath = indexPath
        cell.btnPlay.addTarget(self, action: #selector(mediaButtonTapped(sender:)), for: .touchUpInside)
        if let strMedia = message.mediaURL,let url = URL(string: strMedia) {
            cell.setupDownloadStatus(download: MessageDownloadManager.shared.downloadService.activeDownloads[url])
        }
        if self.isFromCurrentUser(msg: message) {
            cell.setupUploadStatus(upload: MessageUploadManager.shared.activeUploads[message.messageId])
        }
        return cell
    }
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if var message = self.getMsgAtIndexPath(indexPath: indexPath) {
            self.markAllMsgRead(msg: message)
            message.isRead = true
        }
    }
    
    // UITableViewAutomaticDimension calculates height of label contents/text
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        // Swift 4.2 onwards
        return UITableView.automaticDimension
        
    }
    
    func setAvatarFor(imgView:UIImageView,sender: Sender) {
        if sender.senderId == self.currentUser.userId {
            if self.currentUser.userImage.count > 0,let url = URL(string: self.currentUser.userImage)  {
                imgView.sd_setImage(with: url, completed: nil)
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
                    imgView.sd_setImage(with: url, completed: nil)
                }
            }
        }
    }
    
    
    // MARK cell actions
    @objc func viewReplyForwardTapped(sender:UITapGestureRecognizer) {
        guard let senderView = sender.view as? MessageReplyForwardView,let indexPath = senderView.indexPath else {
            return
        }        
        if let msg = self.getMsgAtIndexPath(indexPath: indexPath),let parentId = msg.parent_message_id {
            let msgs = self.messageList.filter { (msg1) -> Bool in
                if msg1.messageId == parentId {
                    return true
                }
                return false
            }
            if let parentMsg = msgs.first,let parentIndexPath = self.getIndexPathForMsg(msg: parentMsg) {
                self.tblView.scrollToRow(at: parentIndexPath, at: .top, animated: true)
            }
        }
    }
    @IBAction func mediaButtonTapped(sender:TRCellButton) {
        if let indexPath = sender.indexPath,let message = self.getMsgAtIndexPath(indexPath: indexPath) {
            
            if message.isDownloaded(),let localURL = message.localFilePath() {
                switch message.msgType {
                case ChatType.image.rawValue :
                    let imgVC = TRImageViewController.getVC(imgURL: localURL)
                    self.present(imgVC, animated: true, completion: nil)
                case ChatType.audio.rawValue :
                    if let cell = self.tblView.cellForRow(at: indexPath) as? AudioChatCell {
                        if let audPlayer = self.audioPlayer {
                            if audPlayer.msgId == message.messageId {
                                if audPlayer.isPlaying {
                                    audPlayer.stop()
                                    sender.setImage(UIImage(named:"enabledButton"), for: .normal)
                                } else {
                                    audPlayer.play()
                                    sender.setImage(UIImage(named:"an_pause"), for: .normal)
                                }
                            } else {
                                audPlayer.stop()
                                audPlayer.cell?.btnPlay.setImage(UIImage(named:"enabledButton"), for: .normal)
                                audPlayer.displayLink?.invalidate()
                                self.audioPlayer = nil
                                self.audioPlayer = TRAudioPlayer.getPlayerFor(fileURL: localURL, msg: message, cell: cell)
                            }
                        } else {
                            self.audioPlayer = nil
                            self.audioPlayer = TRAudioPlayer.getPlayerFor(fileURL: localURL, msg: message, cell: cell)
                        }
                    }
                case ChatType.video.rawValue :
                    let vc = TRVideoPlayerViewController.getVC(url: localURL)
                    let navvc = UINavigationController(rootViewController: vc)
                    present(navvc, animated: true) {
                        vc.player?.play()
                    }
                    
                default:
                    break
                }
                
            } else {
                self.downloadTapped(indexPath: indexPath)
            }
        }
    }
}


extension ChatViewController : HKWTextViewDelegate {
    
//   func textView(_ textView: HKWTextView, willBeginEditing editing: Bool) {
//        if textView == textView {
//            self.setSendButton(visibile: true)
//        }
//    }
//    func textView(_ textView: HKWTextView, willEndEditing editing: Bool) {
//        if textView == textView {
//            self.setSendButton(visibile: false)
//        }
//    }
    
    func setSendButton(visibile:Bool) {
        if visibile {
            btnSendMsg.tintColor = UIColor(hexString: "#D63D41")
            self.btnSendMsg.isEnabled = true
            self.btnSendMsg.alpha = 1
            txtViewPlaceHolder.isHidden = true
//            self.viewVoiceReocrd.isHidden = true
        } else {
            btnSendMsg.tintColor = UIColor(hexString: "#3f3f3f", alpha: 0.5)
            txtViewPlaceHolder.isHidden = false
            self.btnSendMsg.isEnabled = false
            self.btnSendMsg.alpha = 0.6
//            self.viewVoiceReocrd.isHidden = false
        }
    }
 
    func textViewDidChange(_ textView: UITextView) {
        if textView.text.count > 0 {
            self.setSendButton(visibile: true)
        } else {
            self.setSendButton(visibile: false)
        }
        self.adjustUITextViewHeight(arg: textView)
    }
    
    func adjustUITextViewHeight(arg : UITextView) {
        if arg.contentSize.height < maxTextViewHeight {
            textViewHeightConstraint.constant = arg.contentSize.height
        }
    }
    
}

extension ChatViewController:UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject

        if mediaType as! String == kUTTypeMovie as String {
            if let videoURL = info[UIImagePickerController.InfoKey.mediaURL] as? URL {
                self.uploadVideo(videoURL: videoURL)
            }
        } else if mediaType as! String == kUTTypeImage as String {
            if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
                self.uploadImage(image: image)
            }
        }
        dismiss(animated: true, completion: nil)
    }
    func uploadImage(image:UIImage) {
        let documentsDirectory = Helpers.getDocumentsDirectory()
        // choose a name for your image
        let fileName = self.getNewMsgFileName() + ".png"
        // create the destination file url to save your image
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        // get your UIImage jpeg data representation and check if the destination file url already exists
        if let data = image.jpeg(.high),!FileManager.default.fileExists(atPath: fileURL.path) {
            do {
                // writes the image data to disk
                try data.write(to: fileURL)
                print("file saved")
            } catch {
                print("error saving file:", error)
            }
        }
        let data = Helpers.getFileURL(fileName: fileName)
        self.sendMessage(data: data, msgType: .image)
    }
    func getNewMsgFileName() -> String {
        let date = Date()
        return String(format: "%@-%f",self.currentUser.userId ,date.timeIntervalSinceReferenceDate)
    }
    func uploadVideo(videoURL:URL) {        
        let asset = AVURLAsset(url: videoURL , options: nil)
        let imgGenerator = AVAssetImageGenerator(asset: asset)
        imgGenerator.appliesPreferredTrackTransform = true
        do {
            let cgImage = try imgGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
            let image : UIImage! = UIImage(cgImage: cgImage)
            
            let documentsDirectory = Helpers.getDocumentsDirectory()
            // choose a name for your image
            let fileName = self.getNewMsgFileName()
            let thumnailFileName = fileName + "_thumb.png"
            let videoFileName = fileName + ".mp4"
            // create the destination file url to save your image
            let fileURL = documentsDirectory.appendingPathComponent(thumnailFileName)
            let vieoFileURL = documentsDirectory.appendingPathComponent(videoFileName)
            // get your UIImage jpeg data representation and check if the destination file url already exists
            
            let fileManager = FileManager.default
            if let data = image.jpeg(.medium),!FileManager.default.fileExists(atPath: fileURL.path) {
                do {
                    // writes the image data to disk
                    try data.write(to: fileURL)
                    try fileManager.copyItem(at: videoURL, to: vieoFileURL)
                    
                    let data = Helpers.getFileURL(fileName: videoFileName)
                    let thumbdata = Helpers.getFileURL(fileName: thumnailFileName)
                    self.sendMessage(data: data, msgType: .video,thumbnailURL:thumbdata)
                    
                } catch {
                    print("error saving file:", error)
                }
            }
        } catch {
          print(error)
        }
 
    }
}

extension ChatViewController: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let member = chatContact?.members.item(at: indexPath.item) {
            let controller: ProfileViewController = Router.get()
            let vModel = ProfileViewModel(userId: member.userId)
            controller.viewModel = vModel
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.height, height: collectionView.frame.height)
    }
    
}

extension ChatViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return chatContact?.members.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AddMemberToTripCollectionViewCell.self, for: indexPath)
        let placeHolderImage = UIImage(named: "userAvatar")
        cell.imageView.image = placeHolderImage
        cell.imageView.set(cornerRadius: 18)
        if let urlString = chatContact?.members.item(at: indexPath.item)?.userImage,
            let url = URL(string: urlString) {
            cell.imageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
        return cell
    }
    
}
