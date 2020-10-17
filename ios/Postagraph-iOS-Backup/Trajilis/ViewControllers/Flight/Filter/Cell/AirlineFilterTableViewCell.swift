//
//  AirlineFilterTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 21/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class AirlineFilterTableViewCell: UITableViewCell {

    
    @IBOutlet var airlIneSwitch: UISwitch!
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var logoImageView: UIImageView!

    var switchDidChange: ((Bool) -> Void)?

    override func awakeFromNib() {
        super.awakeFromNib()
        selectionStyle = .none
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        logoImageView.makeRounded()
    }

    func configure(company: Company, isOn: Bool) {
        nameLabel.text = company.full_name
        airlIneSwitch.isOn = isOn
        if let logo = company.logo, let url = URL.init(string: logo) {
            logoImageView.sd_setImage(with: url, completed: nil)
        }
    }

    @IBAction func switchChanged(_ sender: UISwitch) {
        switchDidChange?(sender.isOn)
    }
}
