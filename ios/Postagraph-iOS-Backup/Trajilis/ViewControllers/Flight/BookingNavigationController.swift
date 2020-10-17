//
//  FlightNavigationController.swift
//  Trajilis
//
//  Created by Oluwatobi Omotayo on 15/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class BookingNavigationController: UINavigationController {
    
    struct BookingRequestBody {
        var passenger: [Passenger]?
        var creditCardInfo: PaymentCard?
        var itenary: [OutboundFlight]?
        var contact: Contact?
        var billingAddress: Address?
        var merchant: String?
        var fareAmount: String?
        var currency: String?
        var kount_session_id: String
        var tripType: Int
        var familyName: String
        
        struct Address {
            var zipCode: String
            var city: String
            var addressLines: [String]
            var countryCode: String
        }
        
        struct Contact {
            var phone: String
            var email: String
        }
    }
    
    var bookingRequestBody: BookingRequestBody?
    
    var travelersData: TravelersData?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if self.travelersData == nil {
            self.travelersData = TravelersData(adults: [TravelersData.newAdult()], children: [], infantOwnSeat: [], infantOnLap: [])
        }
    }
    
}
