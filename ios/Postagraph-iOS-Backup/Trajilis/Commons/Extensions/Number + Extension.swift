//
//  Number + Extension.swift
//  Trajilis
//
//  Created by bibek timalsina on 10/7/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation

extension CGFloat {
    func rounded(toPlaces places: Int) -> CGFloat {
        let divisor = pow(10.0, CGFloat(places))
        return (self * divisor).rounded() / divisor
    }
}
