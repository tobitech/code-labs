//
//  FlightOptionsCVCell.swift
//  Trajilis
//
//  Created by Perfect Aduh on 11/07/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FlightOptionsCVCell: UICollectionViewCell {

    @IBOutlet weak var serviceNamelbl: UILabel!
    
    var fareFamilyComplete: (()->())?
    
    var fareFamilyServices: FareFamilyServices! {
        didSet {
            serviceNamelbl.text = fareFamilyServices.serviceName
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

}
