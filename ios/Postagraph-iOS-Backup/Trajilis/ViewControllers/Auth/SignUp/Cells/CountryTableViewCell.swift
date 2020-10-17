//
//  CountryTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 01/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class CountryTableViewCell: UITableViewCell {

    @IBOutlet var flagWidthConstraint: NSLayoutConstraint!
    @IBOutlet var dialCodeLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var flagImageView: UIImageView!
    
    override func layoutSubviews() {
        super.layoutSubviews()
        flagImageView.layer.shadowRadius = 4.0
        flagImageView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        flagImageView.layer.opacity = 1.0
        flagImageView.layer.shadowColor = UIColor.appRed.cgColor
        flagImageView.layer.masksToBounds = false
        flagImageView.layer.borderColor = UIColor.appRed.cgColor
        flagImageView.layer.borderWidth = 1
        flagImageView.clipsToBounds = true
    }
    
    func configure(with country: Country) {
        dialCodeLabel.text = country.dialCode
        nameLabel.text = country.name
        let urlString = "http://www.geonames.org/flags/x/\(country.sortName.lowercased()).\("gif")"
        if let url = URL.init(string: urlString) {
            flagImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    func configure(name: String) {
        flagWidthConstraint.constant = 0
        nameLabel.text = name
        flagImageView.layer.borderWidth = 0
        flagImageView.alpha = 0
        dialCodeLabel.alpha = 0
    }

}
