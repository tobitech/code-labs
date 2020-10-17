//
//  TripDetailUserTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/17/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class TripDetailUserTableViewCell: UITableViewCell {

    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userNameLabel: UILabel!
    @IBOutlet weak var memoryCountLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var messageButton: UIButton!
    
    var user: TripMember? {
        didSet {
            setData()
        }
    }
    
    var canDeleteUser: Bool = false {
        didSet {
            deleteButton.isEnabled = canDeleteUser
            deleteButton.tintColor = canDeleteUser ? UIColor(hexString: "#D63D41") : UIColor(hexString: "#e5e5e5")
        }
    }
    var isCurrentUser: Bool = false {
        didSet {
            messageButton.isHidden = isCurrentUser
            if isCurrentUser {
                canDeleteUser = true
            }
        }
    }
    
    var onDeleteTapped: (()->())?
    var onChatTapped: (()->())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        userImageView.rounded()
        userImageView.set(borderWidth: 1, of: UIColor(hexString: "#e5e5e5"))
    }
    
    private func setData() {
        nameLabel.text = "\(user?.firstName ?? "") \(user?.lastName ?? "")"
        userNameLabel.text = user?.userName
        memoryCountLabel.text = ""
        let memoryCount = Int(user?.memberMemoryCount ?? "0") ?? 0
        if memoryCount == 0 {
            memoryCountLabel.text = "No memory"
        }else if memoryCount == 1 {
            memoryCountLabel.text = "\(memoryCount) memory"
        }else {
            memoryCountLabel.text = "\(memoryCount) memories"
        }
        let placeHolderImage = UIImage(named: "userAvatar")
        userImageView.image = placeHolderImage
        if let urlString = user?.userImage, let url = URL(string: urlString) {
            userImageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
        [userImageView, nameLabel, memoryCountLabel, userNameLabel].forEach({
            $0.alpha = user?.inviteStatus == "INVITED" ? 0.6 : 1
        })
    }
    
    
    @IBAction func messageTapped(_ sender: Any) {
        onChatTapped?()
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        onDeleteTapped?()
    }
    
}
