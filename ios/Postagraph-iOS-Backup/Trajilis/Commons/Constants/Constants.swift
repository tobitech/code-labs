//
//  Constants.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 21/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

let kDefaultError = "Oops! Something went wrong. We are on it!."
struct Constants {
    struct NotificationName {
        static let Reload = Notification.Name.init("ReloadFeed")
    }
    
    //static let GOOGLEAPIKEY = "AIzaSyB3VTmT-nS_Uv_fk2Y1W_UhlvVlbn_Hss8"
    static let GOOGLEAPIKEY = "AIzaSyAwu-PH_SOo3ekQC9FV0xcIbYSkah5xEew"
    
    // KOUNT keys
    static let kountMerchantId:Int = 171475
    
    // For Apple Pay
    static let kApplePayMerchangId = "merchant.com.trajilis2.app"
}
