//
//  TrajilisSkyFloatingLabelTextField.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/14/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class TrajilisSkyFloatingLabelTextField: SkyFloatingLabelTextFieldWithIcon {
    
    override func awakeFromNib() {
        super.awakeFromNib()
        tintColor = UIColor.appRed
        selectedTitleColor = UIColor(hexString: "#3f3f3f", alpha: 0.5)
        selectedLineColor = UIColor(hexString: "#505050")
    }
}
