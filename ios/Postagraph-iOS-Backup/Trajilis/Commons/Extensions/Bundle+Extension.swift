//
//  Bundle+Extension.swift
//  Trajilis
//
//  Created by Perfect Aduh on 06/08/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

extension Bundle {
    
    var baseUrl: String? {
        return infoDictionary?["baseUrl"] as? String
    }
    
    var chatUrl: String? {
        return infoDictionary?["chatUrl"] as? String
    }
    
    var bookingUrl: String? {
        return infoDictionary?["bookingUrl"] as? String
    }
}
