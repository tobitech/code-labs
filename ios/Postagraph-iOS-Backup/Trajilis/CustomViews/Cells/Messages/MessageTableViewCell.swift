//
//  MessageTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 02/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SDWebImage

class MessageTableViewCell: UITableViewCell {
    
    static let identifier = "MessageTableViewCell"
    
    @IBOutlet var textMessageCountLabel: UILabel!
    @IBOutlet var messageSenderImageView: UIImageView!
    @IBOutlet var videoIconImageView: UIImageView!
    @IBOutlet var videoImageCountLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!    
    @IBOutlet var imgAudioMsg: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.clear
        // Initialization code
        self.setupUI()
    }
    func setupUI() {
        self.textMessageCountLabel.makeCornerRadius(cornerRadius: 12.5, shadowColour: nil, shadowRadius: nil, shadowOpacity: nil, shadowOffset: nil, borderColor: nil, borderWidth: nil)
    }
    func reset() {
        self.imgAudioMsg.isHidden = true
        
        self.textMessageCountLabel.text = nil
        self.videoImageCountLabel.text = nil
        self.messageLabel.text = nil
        self.timeLabel.text = nil
        self.nameLabel.text = nil
        self.profileImageView.image = nil
        self.messageSenderImageView.image = nil
        self.videoIconImageView.image = nil
        
        self.textMessageCountLabel.isHidden = true
        self.messageSenderImageView.isHidden = true
        self.videoIconImageView.isHidden = true
        self.videoImageCountLabel.isHidden = true
        self.imgAudioMsg.isHidden = true
        
        
    }
    
    func configure(with message: ChatContact) {
        
        configureProfile(message: message)
        configureLastMessage(message: message)
    }
    
    func configure(with follower: Followers) {
        nameLabel.text = follower.name
        messageLabel.text = follower.username
        messageLabel.textColor = UIColor.appNewPlaceholderColor
        if let url = URL.init(string: follower.pic) {
             profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            profileImageView.sd_setImage(with: url, completed: nil)
        }
        
        //Hide every other subviews
        timeLabel.isHidden = true
        videoIconImageView.isHidden = true
        videoImageCountLabel.isHidden = true
        textMessageCountLabel.isHidden = true
    }
    
    private func configureLastMessage(message: ChatContact) {
        guard let lastMessage = message.lastMessage else { return }
        if let url = URL.init(string: lastMessage.thumbnail) {
            messageSenderImageView.sd_setImage(with: url, completed: nil)
        }
        if lastMessage.timeStamp > 0 {
            timeLabel.text = Helpers.timeStampToTimeStringType(timeStamp: String(lastMessage.timeStamp))
        }
        
        if message.unreadTextMessageCount.count > 0 &&  message.unreadTextMessageCount != "0"  {
            textMessageCountLabel.text =  message.unreadTextMessageCount
            textMessageCountLabel.isHidden = false
        }
        messageLabel.textColor = lastMessage.isRead ? UIColor.appNewPlaceholderColor : UIColor.appRed
        switch lastMessage.messageType {
        case .image:
            videoIconImageView.isHidden = false
            videoIconImageView.image = UIImage(named: "message_image_icon")
            messageLabel.text = lastMessage.content
            if message.unreadImageMessageCount.count > 0 &&  message.unreadImageMessageCount != "0"  {
                videoImageCountLabel.text = "+ \(message.unreadImageMessageCount)"
                videoImageCountLabel.isHidden = false
            }
        case .text:
            messageLabel.text = lastMessage.content
            
        case .video:
            videoIconImageView.isHidden = false
            messageLabel.text = lastMessage.content

            videoIconImageView.image = UIImage(named: "video-camera")
            if message.unreadVideoMessageCount.count > 0 &&  message.unreadVideoMessageCount != "0"  {
                videoImageCountLabel.text = "+ \(message.unreadVideoMessageCount)"
                videoImageCountLabel.isHidden = false
            }
            
        case .audio:
            self.imgAudioMsg.isHidden = false            
            messageLabel.text = lastMessage.content  + "audio message"
        case .unknown:
            messageLabel.text = lastMessage.content
            messageLabel.textColor = UIColor.appNewPlaceholderColor
        }
    }
    
    
    private func configureProfile(message: ChatContact) {
         profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        if message.groupName.isEmpty {
            if let member = message.members.first {
                nameLabel.text = member.username
                if let url = URL(string: member.userImage) {
                    profileImageView.sd_setImage(with: url, completed: nil)
                }
            }
        } else {
            nameLabel.text = message.groupName
            if let url = URL(string: message.groupImage) {
                profileImageView.sd_setImage(with: url, completed: nil)
            }
        }
    }
    
    func configureForUser(member: CondensedUser) {
        self.reset()
        self.textMessageCountLabel.isHidden = true
        profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        nameLabel.text = member.username
        if let url = URL(string: member.userImage) {
            profileImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
}

class MessageGroupTableViewCell: UITableViewCell {
    
    @IBOutlet var textMessageCountLabel: UILabel!
    @IBOutlet var videoIconImageView: UIImageView!
    @IBOutlet var videoImageCountLabel: UILabel!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var imgAudioMsg: UIImageView!
    @IBOutlet weak var messageSenderNameLabel: UILabel!
    
    var onLongPressed: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        textMessageCountLabel.rounded()
        profileImageView.rounded()
        profileImageView.set(borderWidth: 1, of: UIColor(hexString: "#e5e5e5"))
        let longPressRecognizer = UILongPressGestureRecognizer(target: self, action:#selector(longPressed))
        addGestureRecognizer(longPressRecognizer)
    }
    
    @objc private func longPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            onLongPressed?()
        }
    }
    
    private func reset() {
        self.imgAudioMsg.isHidden = true
        
        self.textMessageCountLabel.text = nil
        self.videoImageCountLabel.text = nil
        self.messageLabel.text = nil
        self.timeLabel.text = nil
        self.nameLabel.text = nil
        self.profileImageView.image = nil
        self.videoIconImageView.image = nil
        
        self.textMessageCountLabel.isHidden = true
        self.videoIconImageView.isHidden = true
        self.videoImageCountLabel.isHidden = true
        self.imgAudioMsg.isHidden = true
    }
    
    func configure(with message: ChatContact) {
        reset()
        configureProfile(message: message)
        configureLastMessage(message: message)
    }
    
    private func configureLastMessage(message: ChatContact) {
        guard let lastMessage = message.lastMessage else { return }
        if lastMessage.timeStamp > 0 {
            timeLabel.text = Helpers.timeStampToTimeAbbreviatedStringType(timeStamp: String(lastMessage.timeStamp))
        }
        let lastMessageBroken = lastMessage.content.components(separatedBy: " : ")
        messageSenderNameLabel.text = lastMessageBroken.count > 1 ? lastMessageBroken.first : "Postagraph"
        messageLabel.text = lastMessageBroken.count > 1 ? lastMessageBroken.dropFirst().joined(separator: " : ") : lastMessage.content
        if message.unreadTextMessageCount.count > 0 &&  message.unreadTextMessageCount != "0"  {
            textMessageCountLabel.text =  message.unreadTextMessageCount
            textMessageCountLabel.isHidden = false
        }
        messageLabel.textColor = lastMessage.isRead ? UIColor.appNewPlaceholderColor : UIColor.appRed
        
        switch lastMessage.messageType {
        case .image:
            videoIconImageView.isHidden = false
            videoIconImageView.image = UIImage(named: "message_image_icon")
            if message.unreadImageMessageCount.count > 0 &&  message.unreadImageMessageCount != "0"  {
                videoImageCountLabel.text = "+ \(message.unreadImageMessageCount)"
                videoImageCountLabel.isHidden = false
            }
        case .text: break
        case .video:
            videoIconImageView.isHidden = false
            videoIconImageView.image = UIImage(named: "video-camera")
            if message.unreadVideoMessageCount.count > 0 &&  message.unreadVideoMessageCount != "0"  {
                videoImageCountLabel.text = "+ \(message.unreadVideoMessageCount)"
                videoImageCountLabel.isHidden = false
            }
        case .audio:
            self.imgAudioMsg.isHidden = false
        case .unknown:
            messageLabel.textColor = UIColor.appNewPlaceholderColor
        }
    }
    
    
    private func configureProfile(message: ChatContact) {
        profileImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        if message.groupName.isEmpty {
            if let member = message.members.first {
                nameLabel.text = member.username
                let placeHolderImage = UIImage(named: "userAvatar")
                profileImageView.image = placeHolderImage
                let url = URL(string: member.userImage)
                profileImageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
            }
        } else {
            nameLabel.text = message.groupName
            let placeHolderImage = UIImage(named: "usersAvatar")
            profileImageView.image = placeHolderImage
            let url = URL(string: message.groupImage)
            profileImageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
    }
    
}
