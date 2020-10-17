//
//  FlightUtilities.swift
//  Trajilis
//
//  Created by Oluwatobi Omotayo on 16/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation



enum FlightTrip: String {
    case oneway = "oneway"
    case roundTrip = "return"
    case none = ""
}

enum FlightType: Int {
    case nonStop = 0
    case connecting = 1
    case all = 3
    
    var value: [String] {
        switch self {
        case .nonStop:
            return ["N"]
        case .connecting:
            return ["C"]
        default:
            return ["N", "D", "C"]
        }
    }
}

enum FlightClass: String {
    case economy = "Economy"
    case business = "Business"
    case first = "First"
    case premium = "Premium Economy"
    case standard = "Standard"
    
    var code: String {
        switch self {
        case .premium:
            return "W"
        case .business:
            return "C"
        case .first:
            return "F"
        case .economy:
            return "Y"
        case .standard:
            return "M"
        }
    }
    
    var abbr: String {
        return self.rawValue
        //        switch self {
        //        case .premium:
        //            return "PREM"
        //        case .business:
        //            return "BUSI"
        //        case .first:
        //            return "FIRST"
        //        case .economy:
        //            return "ECON"
        //        case .standard:
        //            return "STAN"
        //        default:
        //            return "ECON"
        //        }
    }
    
    static func flightClass(code: String) -> FlightClass {
        switch code {
        case "W":
            return FlightClass.premium
        case "C":
            return FlightClass.business
        case "F":
            return FlightClass.first
        case "Y":
            return FlightClass.economy
        case "M":
            return FlightClass.standard
        default:
            return FlightClass.economy
        }
    }
}

enum SortType: Int {
    case cheapest = 0
    case shortest = 1
    //    case earliest
    case stops = 2
}

struct TravelerInfo: Codable {
    var travelerType: PassengerType
    var withInfant: Bool
    var email: String?
    var bio: TravelerBioInfo
    var phone: String?
    var gender: String
    var infant: TravelerBioInfo?
}

extension TravelerInfo: Equatable {
    static func == (lhs: TravelerInfo, rhs: TravelerInfo) -> Bool {
        return lhs.bio.firstname == rhs.bio.firstname
    }
}

struct TravelerBioInfo: Codable {
    var firstname: String
    var lastname: String
    var dateOfBirth: String
}

// Enum which encapsulates different card types and method to find the type of card.
enum CreditCardType: Int {
    
    case Visa
    case Master
    case Amex
    case Discover
    case DinerClub
    
    func validationRegex() -> String {
        var regex = ""
        switch self {
        case .Visa:
            regex = "^4[0-9]{6,}$"
        case .Master:
            regex = "^5[1-5][0-9]{5,}$"
        case .Amex:
            regex = "^3[47][0-9]{13}$"
        case .Discover:
            regex = "^6(?:011|5[0-9]{2})[0-9]{12}$"
        case .DinerClub:
            regex = "^3(?:0[0-5]|[68][0-9])[0-9]{11}$"
        }
        
        return regex
    }
    
    func validate(cardNumber: String) -> Bool {
        let predicate = NSPredicate(format: "SELF MATCHES %@", validationRegex())
        return predicate.evaluate(with: cardNumber)
    }
    
    // Method returns the credit card type for given card number
    static func cardTypeForCreditCardNumber(cardNumber: String) -> CreditCardType?  {
        var creditCardType: CreditCardType?
        
        var index = 0
        while let cardType = CreditCardType(rawValue: index) {
            if cardType.validate(cardNumber: cardNumber) {
                creditCardType = cardType
                break
            } else {
                index += 1
            }
        }
        return creditCardType
    }
}
