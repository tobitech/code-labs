//
//  NotificationListTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 11/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class NotificationListTableViewCell: UITableViewCell {
    
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var timeAgoLabel: UILabel!
    
    var onProfileTapped: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.rounded()
        userImageView.set(borderWidth: 1, of: UIColor(hexString: "#e5e5e5"))
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnProfile))
        userImageView.addGestureRecognizer(tapGesture)
        userImageView.isUserInteractionEnabled = true
    }
    
    var notification: TrajilisNotification? {
        didSet {
            setData()
        }
    }
    
    private func setData() {
        contentLabel.text = notification?.message
        nameLabel.text = notification?.senderName
        timeAgoLabel.text = Helpers.timeStampToTimeAbbreviatedStringType(timeStamp: notification?.date)
        let placeHolderImage = UIImage(named: "userAvatar")
        userImageView.image = placeHolderImage
        if let url = try? notification?.senderImage.asURL() ?? nil {
            userImageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
        contentLabel.font = notification?.isRead == true ? UIFont(name: "PTSans-Regular", size: 13)! : UIFont(name: "PTSans-Bold", size: 13)!
    }
    
    @objc private func tappedOnProfile() {
        onProfileTapped?()
    }
    
}

//class NotificationListTableViewCell: UITableViewCell {
//
//    @IBOutlet var unreadNotificationIndicatorImageView: UIImageView!
//    @IBOutlet var profileImageView: UIImageView!
//    @IBOutlet var timeAgoLabel: UILabel!
//    @IBOutlet var contentLabel: UILabel!
//    @IBOutlet var nameLabel: UILabel!
//
//    var profileBlock:(() -> ())?
//
//    override func layoutSubviews() {
//        super.layoutSubviews()
//        profileImageView.layer.cornerRadius = profileImageView.bounds.height/2
//        profileImageView.layer.masksToBounds = true
//        profileImageView.layer.borderColor = UIColor.appRed.cgColor
//        profileImageView.layer.borderWidth = 1
//    }
//
//    func configure(with notification: TrajilisNotification) {
//        nameLabel.text = notification.senderName
//        timeAgoLabel.text = Helpers.timeStampToTimeStringType(timeStamp: notification.date)
//        contentLabel.text = notification.message
//        if let url = URL(string: notification.senderImage) {
//            profileImageView.sd_setImage(with: url, completed: nil)
//        }
//        if !notification.isRead {
//            contentLabel.textColor = UIColor.appRed
//            timeAgoLabel.textColor = UIColor.appRed
//            unreadNotificationIndicatorImageView.alpha = 1
//        } else {
//            unreadNotificationIndicatorImageView.alpha = 0
//            contentLabel.textColor = UIColor.appNewPlaceholderColor
//            timeAgoLabel.textColor = UIColor.appNewPlaceholderColor
//        }
//    }
//
//    @IBAction func profileTapped(_ sender: Any) {
//        profileBlock?()
//    }
//
//}
