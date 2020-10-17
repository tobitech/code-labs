//
//  SearchFriendTableViewCell.swift
//  Trajilis
//
//  Created by user on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class SearchFriendTableViewCell: UITableViewCell {
    
    @IBOutlet weak var profileImg: UIImageView!
    @IBOutlet weak var fullName: UILabel!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var locationLbl: UILabel!
    @IBOutlet weak var addFriendImg: UIImageView!
    
    var user: User? {
        didSet {
            configureCell()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        setupProfileImgView()
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    private func setupProfileImgView() {
        profileImg.makeCornerRadius(cornerRadius: profileImg.bounds.height/2, shadowColour: nil, shadowRadius: nil, shadowOpacity: nil, shadowOffset: nil, borderColor: UIColor.appRed, borderWidth: 1)
    }
    
    private func configureCell() {
        guard let user = user else { return }
        fullName.text = "\(user.firstname) \(user.lastname)"
        userName.text = user.username
        locationLbl.text = user.city
        guard let imgUrl = URL(string: "\(user.profileImage)") else { return }
        
        self.profileImg.sd_setImage(with: imgUrl, completed: nil)
    }
}
