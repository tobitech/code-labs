//
//  NotificationHeaderTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class NotificationHeaderTableViewCell: UITableViewCell {

    @IBOutlet var countLabel: UILabel!
    @IBOutlet var countContainerLabel: UIView!
    
    
    override func layoutSubviews() {
        super.layoutSubviews()
        countContainerLabel.layer.cornerRadius = countContainerLabel.bounds.height/2
        countContainerLabel.layer.masksToBounds = true
    }

    var count: String = "0" {
        didSet {
            countLabel.text = count
            countContainerLabel.layer.cornerRadius = countContainerLabel.bounds.height/2
            countContainerLabel.layer.masksToBounds = true
        }
    }

    
}
