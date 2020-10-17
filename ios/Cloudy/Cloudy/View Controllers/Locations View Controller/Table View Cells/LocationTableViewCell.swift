//
//  LocationTableViewCell.swift
//  Cloudy
//
//  Created by Bart Jacobs on 10/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

class LocationTableViewCell: UITableViewCell {

    // MARK: - Type Properties

    static let reuseIdentifier = "LocationCell"

    // MARK: - Properties

    @IBOutlet var mainLabel: UILabel!

    // MARK: - Initialization

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    // MARK: - Configuration

    func configure(withViewModel viewModel: LocationRepresentable) {
        mainLabel.text = viewModel.text
    }

}
