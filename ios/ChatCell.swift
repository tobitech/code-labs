//
//  ChatCell.swift
//  Hollaport
//
//  Created by Oluwatobi Omotayo on 09/07/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

class ChatCell: BaseTableCell<ChatViewModel> {
    
    override var viewModel: ChatViewModel? {
        didSet {
            usernameLabel.text = viewModel?.title
            lastMessageLabel.text = viewModel?.lastMessage
            dateLabel.text = viewModel?.lastModified
            
            // set last message font weight
            if let messageRead = viewModel?.isLastMessageRead, messageRead {
               lastMessageLabel.font = Font(.installed(.OpenSansRegular), size: .standard(.bodyXSmall)).instance
            } else {
                lastMessageLabel.font = Font(.installed(.OpenSansBold), size: .standard(.bodyXSmall)).instance
            }
            
            if let imageUrl = URL(string: viewModel?.profileImage ?? "") {
                if viewModel?.chatType == ChatType.single.rawValue {
                    profileImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "avatar_default"), options: [], completed: nil)
                } else if viewModel?.chatType == ChatType.group.rawValue {
                    profileImageView.sd_setImage(with: imageUrl, placeholderImage: #imageLiteral(resourceName: "group_avatar_default"), options: [], completed: nil)
                }
            } else {
                profileImageView.image = viewModel?.chatType == ChatType.single.rawValue ? #imageLiteral(resourceName: "avatar_default") : #imageLiteral(resourceName: "group_avatar_default")
            }
            
            if let count = viewModel?.unreadCount {
                if count < 1 {
                    self.unreadCounter.isHidden = true
                } else {
                    self.unreadCounter.isHidden = false
                    self.unreadCounter.text = "\(count)"
                }
            }
            
        }
    }
    
    let profileImageView: UIImageView = {
        let iv = UIImageView()
        iv.layer.cornerRadius = 25
        iv.contentMode = .scaleAspectFill
        iv.layer.masksToBounds = true
        return iv
    }()

    let usernameLabel: UILabel = {
        let label = UILabel()
        label.text = "Sample name"
        label.font = Font(.installed(.OpenSansSemiBold), size: .standard(.h4)).instance
        label.textColor = Color.solid02.value
        return label
    }()

    let lastMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "a last message"
        label.font = Font(.installed(.OpenSansRegular), size: .standard(.bodyXSmall)).instance
        label.textColor = Color.solid02.value
        return label
    }()
    
    var timer: Timer?
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = Color.solid02.value
        label.textAlignment = .right
        label.font = Font(.installed(.OpenSansRegular), size: .standard(.bodyXSmall)).instance
        label.textColor = Color.solid02.value
        return label
    }()
    
    let unreadCounter: UILabel = {
        let label = UILabel()
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .white
        label.backgroundColor = Color.solid07.value
        label.layer.cornerRadius = 10
        label.layer.masksToBounds = true
        label.textAlignment = .center
        label.font = Font(.installed(.OpenSansRegular), size: .standard(.bodyXSmall)).instance
        return label
    }()
    
    override func prepareForReuse() {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func setupViews() {
        super.setupViews()
        
        // observe is typing notification.
        NotificationCenter.default.addObserver(self, selector: #selector(handleIsTyping(_:)), name: NSNotification.Name(rawValue: kIsTypingNotification), object: nil)
        
        // layouts
        addSubview(dateLabel)
        addSubview(profileImageView)
        addSubview(lastMessageLabel)
        addSubview(usernameLabel)
        addSubview(unreadCounter)
        
        profileImageView.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: 50, height: 50))
        profileImageView.centerYAnchor.constraint(equalTo: centerYAnchor).isActive = true
        
        dateLabel.anchor(top: profileImageView.topAnchor, leading: nil, bottom: nil, trailing: trailingAnchor, padding: .init(top: 4, left: 0, bottom: 0, right: 16))
        usernameLabel.anchor(top: profileImageView.topAnchor, leading: profileImageView.trailingAnchor, bottom: nil, trailing: dateLabel.leadingAnchor, padding: .init(top: 0, left: 16, bottom: 0, right: 8))
        lastMessageLabel.anchor(top: usernameLabel.bottomAnchor, leading: usernameLabel.leadingAnchor, bottom: profileImageView.bottomAnchor, trailing: trailingAnchor, padding: .init(top: 2, left: 0, bottom: 0, right: 8))
        
        unreadCounter.anchor(top: profileImageView.topAnchor, leading: profileImageView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0))
        unreadCounter.widthAnchor.constraint(greaterThanOrEqualToConstant: 20).isActive = true
        unreadCounter.heightAnchor.constraint(equalToConstant: 20).isActive = true
        
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        contentView.frame = contentView.frame.inset(by: UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16))
    }
    
    @objc func handleIsTyping(_ notification: NSNotification) {
        guard let recipientId = notification.userInfo?["recipientId"] as? String else { return }
        if recipientId == viewModel?.recipientId {
            lastMessageLabel.text = "typing..."
        } 
        
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 3, repeats: false, block: { (_) in
            self.lastMessageLabel.text = self.viewModel?.lastMessage
            self.lastMessageLabel.textColor = Color.solid02.value
        })
        
    }
    
}






