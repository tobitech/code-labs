//
//  FlightDetailFooterTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 27/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FlightDetailFooterTableViewCell: UITableViewCell {

    var continueBlock:(() -> Void)?
    
    @IBOutlet var button: TrajilisButton!
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    @IBAction func continueButtonTapped(_ sender: Any) {
        continueBlock?()
    }

}
