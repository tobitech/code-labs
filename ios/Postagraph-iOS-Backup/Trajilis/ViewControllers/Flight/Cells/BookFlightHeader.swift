//
//  BookFlightHeader.swift
//  Trajilis
//
//  Created by Perfect Aduh on 27/08/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

class BookFlightHeader: UIView {

    @IBOutlet weak var outboundTxtField: SkyFloatingLabelTextField!
    @IBOutlet weak var inboundTxtField: SkyFloatingLabelTextField!
    @IBOutlet weak var outboundBtn: UIButton!
    @IBOutlet weak var inboundBtn: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        outboundTxtField.titleFormatter = {$0}
        inboundTxtField.titleFormatter = {$0}
        outboundTxtField.selectedTitle = ""
        inboundTxtField.selectedTitle = "Where to fly to?"
    }
}
