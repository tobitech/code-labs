//
//  ByPhoneCell.swift
//  Trajilis
//
//  Created by Moses on 25/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class ByPhoneCell: UITableViewCell {
    static let name = "ByPhoneCell"
    
    @IBOutlet fileprivate weak var name:UILabel!
    @IBOutlet fileprivate weak var number:UILabel!
    @IBOutlet weak var selectedSwitch: UISwitch!
    
    var phone: ByPhone! {
        didSet {
            name.text = phone.name
            number.text  = phone.number
        }
    }
    
    var addPhone : ((ByPhone) -> Void)?
    var removePhone : ((ByPhone) -> Void)?
    var isPhoneSelected: Bool = false {
        didSet {
            selectedSwitch.setOn(isPhoneSelected, animated: false)
        }
    }
    
    @IBAction fileprivate func switchEvent(_ sender: UISwitch) {
        if sender.isOn {
            addPhone?(phone)
        } else {
            removePhone?(phone)
        }
    }
    
}
