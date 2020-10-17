//
//  SearchExplorerTableViewCell.swift
//  Trajilis
//
//  Created by user on 01/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

enum kInviteStatus: String {
    case ACCEPTED
    case INVITED
    case REJECTED
}
class SearchExplorerTableViewCell: UITableViewCell {
    
    @IBOutlet var explorerButtonWidthConstraint: NSLayoutConstraint!
    @IBOutlet var addExplorerButton: UIButton!
    @IBOutlet weak var fullNameLbl: UILabel!
    @IBOutlet weak var userNameLbl: UILabel!
    @IBOutlet weak var profileImg: UIImageView!

    var addExplorer: (() -> ())?

    static var identifier: String {
        return String(describing: self)
    }

    static var Nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        

    }
    
    @IBAction func addExplorerBtnPressed( _ sender: UIButton) {
        self.addExplorer?()
    }
    
    
    func configureCell(userData: CondensedUser, isSelected: Bool) {
        explorerButtonWidthConstraint.constant = 25
        explorerButtonWidthConstraint.isActive = true
        profileImg.makeCornerRadius(cornerRadius: profileImg.bounds.height/2, shadowColour: nil, shadowRadius: nil, shadowOpacity: nil, shadowOffset: nil, borderColor: nil, borderWidth: nil)
        fullNameLbl.text = "\(userData.firstName ?? "") \(userData.lastName ?? "")"
        userNameLbl.text = userData.username
        let image = isSelected ? UIImage(named: "invited-for-trip") : UIImage(named: "invite-for-trip")
        addExplorerButton.setImage(image, for: .normal)
        if let url = URL(string: userData.userImage) {
            profileImg.sd_setImage(with: url, completed: nil)
        }
    }

    func configure(member: TripMember) {
        profileImg.makeRounded()
        fullNameLbl.isHidden = member.firstName.isEmpty && member.lastName.isEmpty 
        if member.inviteStatus != kInviteStatus.ACCEPTED.rawValue {
            fullNameLbl.textColor = .lightGray
            addExplorerButton.setTitleColor(.lightGray, for: .normal)
        } else {
            fullNameLbl.textColor = .darkGray
            addExplorerButton.setTitleColor(.appRed, for: .normal)
        }
        fullNameLbl.text = "\(member.firstName) \(member.lastName)"
        
        userNameLbl.text = member.userName
        addExplorerButton.setImage(nil, for: .normal)
        
        var numberOfMemories = 0
        if !member.memberMemoryCount.isEmpty,let count = Int(member.memberMemoryCount) {
            numberOfMemories = count
        }
        var text = ""
        if numberOfMemories == 0 {
            text = "No memory"
        } else {
            let memory = numberOfMemories > 1 ? "memories" : "memory"
            text = "\(numberOfMemories) \(memory)"
        }
        addExplorerButton.setTitle(text, for: .normal)
        
        
        
        explorerButtonWidthConstraint.isActive = false
        if let url = URL(string: member.userImage ) {
            profileImg.sd_setImage(with: url, completed: nil)
        }
    }

    func configure(member: TripMember, isDelete: Bool) {
        explorerButtonWidthConstraint.constant = 25
        explorerButtonWidthConstraint.isActive = true
        profileImg.makeRounded()
        fullNameLbl.isHidden = member.firstName.isEmpty && member.lastName.isEmpty
        fullNameLbl.text = "\(member.firstName) \(member.lastName)"
        userNameLbl.text = member.userName
        if isDelete {
            let image = UIImage(named: "deletePassenger")
            addExplorerButton.setImage(image, for: .normal)
        } else {
            let image = isDelete ? UIImage(named: "invited-for-trip") : UIImage(named: "invite-for-trip")
            addExplorerButton.setImage(image, for: .normal)
        }
        if let url = URL(string: member.userImage) {
            profileImg.sd_setImage(with: url, completed: nil)
        }
    }

    func configure(member: TripMember, isSelected: Bool) {
        explorerButtonWidthConstraint.constant = 25
        explorerButtonWidthConstraint.isActive = true
        profileImg.makeRounded()
        fullNameLbl.isHidden = member.firstName.isEmpty && member.lastName.isEmpty
        fullNameLbl.text = "\(member.firstName) \(member.lastName)"
        userNameLbl.text = member.userName
        let image = isSelected ? UIImage(named: "invited-for-trip") : UIImage(named: "invite-for-trip")
        addExplorerButton.setImage(image, for: .normal)
        if let url = URL(string: member.userImage) {
            profileImg.sd_setImage(with: url, completed: nil)
        }
    }
}
