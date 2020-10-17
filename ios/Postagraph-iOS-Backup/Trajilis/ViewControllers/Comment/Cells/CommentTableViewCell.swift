//
//  CommentTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 06/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class CommentTableViewCell: UITableViewCell {

    @IBOutlet var likeStackView: UIStackView!
    @IBOutlet var likeCountLabel: UILabel!
    @IBOutlet var likeImageView: UIImageView!
    @IBOutlet var profileImageView: UIImageView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var leadingConstraint: NSLayoutConstraint!
    @IBOutlet var verticalBar: UIView!
    
    static let name = "CommentTableViewCell"

    var optionBlock:(() -> Void)?
    var likeBlock:(() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        profileImageView.rounded()
        profileImageView.set(borderWidth: 1, of: UIColor(hexString: "#e5e5e5"))
        
        let likeTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.likeTapped))
        likeImageView.addGestureRecognizer(likeTapGesture)
        likeImageView.isUserInteractionEnabled = true
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.longPressed))
        contentView.addGestureRecognizer(longPressGesture)
    }

    func configure(comment: Comment) {
        let isReply = comment.parentComment != nil
        leadingConstraint.constant = isReply ? 69 : 16
        verticalBar.isHidden = !isReply
        profileImageView.isHidden = isReply
        
        nameLabel.text = "@" + comment.username
        let commentAttributedString = NSMutableAttributedString(string: comment.component, attributes: [.font: UIFont(name: "PTSans-Regular", size: 15)!, .foregroundColor: UIColor(hexString: "#505050")])
        let timeAttributedString = NSMutableAttributedString(string: "  " + Helpers.timeStampToTimeAbbreviatedStringType(timeStamp: comment.time), attributes: [.font: UIFont(name: "PTSans-Regular", size: 15)!, .foregroundColor: UIColor(hexString: "#505050", alpha: 0.5)])
        commentAttributedString.append(timeAttributedString)
        if !comment.replyCount.isEmpty && comment.replyCount != "0" {
            let replyString = comment.replyCount == "1" ? " (1 reply) " : " (\(comment.replyCount) replies) "
            let repliesAttributedString = NSMutableAttributedString(string: replyString , attributes: [.font: UIFont(name: "PTSans-Regular", size: 12)!, .foregroundColor: UIColor(hexString: "#505050", alpha: 0.5)])
            commentAttributedString.append(repliesAttributedString)
        }
        
        messageLabel.attributedText = commentAttributedString
        
        let placeHolderImage = UIImage(named: "userAvatar")
        profileImageView.image = placeHolderImage
        if let url = URL(string: comment.userImage) {
            profileImageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
        
        likeImageView.image = comment.likeStatus ? UIImage(named: "heart-filled-red") : UIImage(named: "heart-empty")
        likeCountLabel.text = comment.likeCount == "0" || comment.likeCount.isEmpty ? "" : "\(comment.likeCount)"
        likeStackView.isHidden = isReply
    }

    @objc private func longPressed(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            optionBlock?()
        }
    }
    
    @objc private func likeTapped() {
        likeBlock?()
    }

    
}
