//
//  TagTableViewCell.swift
//  Notes
//
//  Created by Bart Jacobs on 07/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

class TagTableViewCell: UITableViewCell {

    // MARK: - Properties

    static let reuseIdentifier = "TagTableViewCell"

    // MARK: -

    @IBOutlet var nameLabel: UILabel!

    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
