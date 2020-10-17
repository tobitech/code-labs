//
//  PassengerListTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PassengerListTableViewCell: UITableViewCell {

    @IBOutlet var deleteButton: UIButton!
    @IBOutlet var editButton: UIButton!
    @IBOutlet var nameLabel: UILabel!

    var deleteBlock: (() -> Void)?
    var editBlock: (() -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
        // Initialization code
    }

    @IBAction func deleteTapped(_ sender: Any) {
        deleteBlock?()
    }
    @IBAction func editTapped(_ sender: Any) {
        editBlock?()
    }
}
