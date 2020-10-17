//
//  PGBookingModels.swift
//  Trajilis
//
//  Created by bharats802 on 26/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit


struct  PGHotelBookingDetail {
    var order_number:String!
    var start_date:String!
    var end_date:String!
    var hotel_name:String!
    var totalOccupants:Int = 0
    var numOfRooms:Int = 1
    var user_id:String!
    var created_at:String!
    var feeAmount:String!
    var bookingId:String!
    var updated_at:String!
    var control_number:String!
    var hotel_city:String!
    
    
    var currency:String!
    var hotel:PGHotel?
    init(json: JSONDictionary) {
        order_number = json["order_number"] as? String ??  ""
        start_date = json["start_date"] as? String ??  ""
        end_date = json["end_date"] as? String ??  ""
        hotel_name = json["hotel_name"] as? String ??  ""
        totalOccupants = json["totalOccupants"] as? Int ??  0
        numOfRooms = json["quantity"] as? Int ??  1
        user_id = json["user_id"] as? String ??  ""
        created_at = json["created_at"] as? String ??  ""
        feeAmount = json["feeAmount"] as? String ??  ""
        bookingId = json["_id"] as? String ??  ""
        updated_at = json["updated_at"] as? String ??  ""
        control_number = json["control_number"] as? String ??  ""
        hotel_city = json["hotel_city"] as? String ??  ""
        currency = json["currency"] as? String ??  CurrencyManager.shared.getUserCurrencyCode()
        
        if let hotelData = json["description"] as? JSONDictionary {
            hotel = PGHotel(json: hotelData)
        }
    }
    func isUpcoming() -> Bool {
        if let date = Helpers.dateFromString(dateString: self.end_date, inputDateFormat: kDate_yyyy_MM_dd){
            if date.isFuture  {
                return true
            }
        }
        return false
    }
    
}

struct  PGFlightBookingDetail {
    var _id:String! = ""
    var control_number:String = ""
    var fareAmount:String = ""
    var company_id:String! = ""
    var created_at:String! = ""
    var currency:String! = ""
    var user_id:String! = ""
    var updated_at:String! = ""
    var passengers:[PGFlightPassenger] = [PGFlightPassenger]()
    var itinerary:[PGFlightItinary] = [PGFlightItinary]()
    var priceString:String?
    var tripType:String = "-"
    init(json: JSONDictionary) {
        print(json)
        _id = json["_id"] as? String ?? ""
        control_number = json["control_number"] as? String ?? ""
        fareAmount = json["fareAmount"] as? String ?? ""
        company_id = json["company_id"] as? String ?? ""
        created_at = json["created_at"] as? String ?? ""
        user_id = json["user_id"] as? String ?? ""
        updated_at = json["updated_at"] as? String ?? ""
        currency = json["currency"] as? String ?? CurrencyManager.shared.getUserCurrencyCode()
        
        if let fm = Double(fareAmount) {
            let currencySym = CurrencyManager.shared.getSymbol(forCurrency: currency)
            priceString = "\(currencySym)\(fm.rounded(toPlaces: 2))"
        }
        
        
        if let pax = json["passengers"] as? [JSONDictionary] {
            let paxes = pax.compactMap{ return PGFlightPassenger(json: $0) }
            if paxes.count > 0 {
                self.passengers.append(contentsOf: paxes)
            }
        }
        if let ttype = json["tripType"] as? Int {
            tripType = (ttype == 1) ? "One Way" : "Round Trip"
        }
        
        if let itinerary = json["itinerary"] as? [JSONDictionary] {
            let ities = itinerary.compactMap{ return PGFlightItinary(json: $0) }
            if ities.count > 0 {
                self.itinerary.append(contentsOf: ities)
            }
        }
        
    }
    
    func isUpcoming() -> Bool {        
        for itinary in self.itinerary {
            for seg in itinary.segments {
                if let date = Helpers.dateFromString(dateString: seg.dateOfArrival,inputDateFormat: kDate_yyyy_MM_dd){
                    if date.isFuture  {
                        return true
                    }
                }
            }
        }
        return false
    }
}
struct  PGFlightItinary {
    var origin:PGFlightCity?
    var destination:PGFlightCity?
    
    var segments:[PGFlightItinarySegment] = [PGFlightItinarySegment]()
    init(json: JSONDictionary) {
        print(json)
        if let value = json["origin"] as? JSONDictionary  {
            origin = PGFlightCity(json: value)
        }
        if let value = json["destination"] as? JSONDictionary  {
            destination = PGFlightCity(json: value)
        }
        if let segment = json["segments"] as? [JSONDictionary] {
            let segs = segment.compactMap{ return PGFlightItinarySegment(json: $0) }
            if segs.count > 0 {
                self.segments.append(contentsOf: segs)
            }
        }
    }
}
struct  PGFlightCity {
    var _id:String! = ""
    var city_photo:String! = ""
    var code:String! = ""
    var country_name:String! = ""
    var name:String! = ""
    var airportName:String! = ""
    var state_full:String! = ""
    init(json: JSONDictionary) {
        _id = json["_id"] as? String ?? ""
        city_photo = json["city_photo"] as? String ?? ""
        code = json["code"] as? String ?? json["iata"] as? String ?? ""
        country_name = json["country_name"] as? String ?? ""
        name = json["city_name"] as? String ?? ""
        airportName = json["name"] as? String ?? ""
        state_full = json["state_full"] as? String ?? ""
    }
}
struct  PGFlightItinarySegment {
    
    var operatingCompany:String! = ""
    var groupNumber:String! = ""
    var availabilityCtx:Bool! = false
    var timeOfDeparture:String = ""
    var dateOfDeparture:String = ""
    
    var timeOfArrival:String  = ""
    var departureTerminal:String! = ""
    var totalPassenger:String! = ""
    var marketingCompany:String! = ""
    var marketingCompanyLogo:String! = ""
    var bookingClass:String! = ""
    var electronicTicketing:String! = ""
    var arrivalTerminal:String! = ""
    var flightNumber:String = ""
    var dateOfArrival:String = ""
    var arrivalLocation:PGFlightCity?
    var departureLocation:PGFlightCity?
    
    
    var departureDateTime: Date {
        let departureDate = "\(dateOfDeparture) \(timeOfDeparture)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: departureDate)
        return date!
    }
    
    var arrivalDateTime: Date {
        let departureDate = "\(dateOfArrival) \(timeOfArrival)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: departureDate)
        return date!
    }
    
    init(json: JSONDictionary) {
        print(json)
        
        
        groupNumber = json["groupNumber"] as? String ?? ""
        availabilityCtx = json["availabilityCtx"] as? Bool ?? false
        timeOfDeparture = json["timeOfDeparture"] as? String ?? ""
        dateOfDeparture = json["dateOfDeparture"] as? String ?? ""
        
        timeOfArrival = json["timeOfArrival"] as? String ?? ""
        
        departureTerminal = json["departureTerminal"] as? String ?? ""
        totalPassenger = json["totalPassenger"] as? String ?? ""
        
        bookingClass = json["bookingClass"] as? String ?? ""
        electronicTicketing = json["electronicTicketing"] as? String ?? ""
        arrivalTerminal = json["arrivalTerminal"] as? String ?? ""
        flightNumber = json["flightNumber"] as? String ?? ""
        dateOfArrival = json["dateOfArrival"] as? String ?? ""

        
        if let value = json["arrivalLocation"] as? JSONDictionary  {
            arrivalLocation = PGFlightCity(json: value)
        }
        if let value = json["departureLocation"] as? JSONDictionary  {
            departureLocation = PGFlightCity(json: value)
        }
        if let value = json["marketingCompany"] as? JSONDictionary  {
            marketingCompany = value["full_name"] as? String
            marketingCompanyLogo = value["logo_small"] as? String
        }
        if let value = json["operatingCompany"] as? JSONDictionary  {
            operatingCompany = value["full_name"] as? String
        }
    }
}
struct  PGFlightPassenger {
    var lastName:String = ""
    var firstName:String = ""
    var dateOfBirth:String! = ""
    var travellerType:String! = ""
    var withInfant:Bool! = false
    var infantfirstName:String = ""
    var infantdateOfBirth:String! = ""
    var infantlastName:String = ""
    init(json: JSONDictionary) {
        lastName = json["lastName"] as? String ?? ""
        firstName = json["firstName"] as? String ?? ""
        dateOfBirth = json["dateOfBirth"] as? String ?? ""
        travellerType = json["travellerType"] as? String ?? ""
        withInfant = json["withInfant"] as? Bool ?? false
        
        if let infant = json["infant"] as? JSONDictionary {
            infantfirstName = infant["firstName"] as? String ?? ""
            infantdateOfBirth = infant["dateOfBirth"] as? String ?? ""
            infantlastName = infant["lastName"] as? String ?? ""
        }
        
    }
}
