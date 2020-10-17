//
//  NoteTableViewCell.swift
//  Notes
//
//  Created by Bart Jacobs on 06/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

class NoteTableViewCell: UITableViewCell {

    // MARK: - Static Properties

    static let reuseIdentifier = "NoteTableViewCell"

    // MARK: - Properties

    @IBOutlet var tagsLabel: UILabel!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var contentsLabel: UILabel!
    @IBOutlet var updatedAtLabel: UILabel!
    @IBOutlet var categoryColorView: UIView!

    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }

}
