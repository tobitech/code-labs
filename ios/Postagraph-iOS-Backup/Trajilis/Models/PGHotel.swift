//
//  PGHotel.swift
//  Trajilis
//
//  Created by bharats802 on 16/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import CoreLocation

enum kAmenities:String {
    case bar
    case housekeeping
    case internet
    case Laundry
    case Lounges
    case parking
    case Pets
    case Rental
    case restaurant
    case roomservice = "room service"
    case skyscrapers
    case Breakfast
    case Checkin = "Check-in"
    case Coffee
    
    case elevator
    case conference
    case hotspot
    case ice
    case jacuzzi
    case maternity
    case pool
    case atm
    
    
    static func allValues() -> [String] {
        return [kAmenities.bar.rawValue,kAmenities.housekeeping.rawValue,kAmenities.internet.rawValue,kAmenities.Laundry.rawValue,kAmenities.Lounges.rawValue,kAmenities.parking.rawValue,kAmenities.Pets.rawValue,kAmenities.Rental.rawValue,kAmenities.restaurant.rawValue,kAmenities.roomservice.rawValue,kAmenities.skyscrapers.rawValue,kAmenities.Breakfast.rawValue,kAmenities.Checkin.rawValue,kAmenities.Coffee.rawValue,
        kAmenities.elevator.rawValue,
        kAmenities.conference.rawValue,
        kAmenities.hotspot.rawValue,
        kAmenities.ice.rawValue,
        kAmenities.jacuzzi.rawValue,
        kAmenities.maternity.rawValue,
        kAmenities.pool.rawValue,
        kAmenities.atm.rawValue
        ]
    }
}

struct PGHotel {
    var hotelAddress:String!
    var hotelCity:String!
    var hotelCode:String!
    var hotelName:String!
    var vendorMessages:String!
    var rooms = [PGHotelRoom]()
    var hotelDescription:PGHotelDescription?
    var hotelImage:String?
    
    init(json: JSONDictionary) {
        
        hotelAddress = json["HotelAddress"] as? String ?? ""
        hotelCity = json["HotelCity"] as? String ?? ""
        hotelCode = json["HotelCode"] as? String ?? ""
        hotelName = json["HotelName"] as? String ?? ""
        vendorMessages = json["VendorMessages"] as? String ?? ""
        
        if let roomsData = json["HotelRooms"] as? [JSONDictionary],roomsData.count > 0  {
            for room in roomsData {
                let roomObj = PGHotelRoom(json: room)
                self.rooms.append(roomObj)
            }
        }
        if let descriptionData = json["description"] as? JSONDictionary,let hotelsData = descriptionData["hotels"] as? [JSONDictionary], hotelsData.count > 0  {
            if let desData = hotelsData.first {
                let desHotel = PGHotelDescription(json: desData)
                self.hotelDescription = desHotel
                if let imgs = self.hotelDescription?.images,imgs.count > 0 {
                    for img in imgs {
                        if img.width > 1000 {
                            break
                        }
                        self.hotelImage = img.url
                    }
                }
            }
        } else {
            let desHotel = PGHotelDescription(json: json)
            self.hotelDescription = desHotel
            if let imgs = self.hotelDescription?.images,imgs.count > 0 {
                for img in imgs {
                    if img.width > 1000 {
                        break
                    }
                    self.hotelImage = img.url
                }
            }
        }
        
    }
    mutating func updateHotel(json:JSONDictionary) {
        print(json)
        let desHotel = PGHotelDescription(json: json)
        self.hotelDescription = desHotel
    }
    func getMinimumPriceValue() -> Double {
        if let room = self.getMinimumPriceHotelRoom() {
            return room.totalFare.rounded(toPlaces: 2)
        }
        return 0
    }
    func getMinimumPrice() -> String {
        if let room = self.getMinimumPriceHotelRoom() {
            let currency = CurrencyManager.shared.getSymbol(forCurrency: room.currencyCode)
            return "\(currency)\(room.totalFare.rounded(toPlaces: 2))"
            
        }
        return "0"
    }
    func getMinimumPriceHotelRoom() -> PGHotelRoom? {
        
        let filteredRoom = self.rooms.filter { (room) -> Bool in
            return room.isSelected
        }
        return filteredRoom.first
        
//        let sortedRooms = self.rooms.sorted { (r1, r2) -> Bool in
//            if r1.totalFare < r2.totalFare {
//                return true
//            }
//            return false
//        }
//        if let room = sortedRooms.first {
//            return room
//        }
//        return nil
    }
}
struct PGHotelRoom {
    var bookingCode:String!
    var ratePlanCode:String!
    var currencyCode:String!
    var guestCounts:String!
    var roomDescription:String!
    var totalFare:Double = 0
    var isSelected:Bool = false
    
    init(json: JSONDictionary) {
        bookingCode = json["BookingCode"] as? String ?? ""
        currencyCode = json["CurrencyCode"] as? String ?? ""
        guestCounts = json["GuestCounts"] as? String ?? ""
        roomDescription = json["RoomDescription"] as? String ?? ""
        
        ratePlanCode = json["ratePlanCode"] as? String ?? ""
        isSelected = json["isSelected"] as? Bool ?? false
        
        if let fare = json["TotalFare"] as? Double {
            totalFare = fare.rounded(toPlaces: 2)
        }
    }
}
struct PGHotelDescription {
    var ratings_value:Double = 0
    var ratings_provider:String! = ""
    var ratings_symbol:String! = ""
    var phoneNumber:String?
    var website:String?
    var email:String?
    
    var images = [PGHotelImage]()
    var texts = [String]()
    var location:CLLocation?
    var services:[PGHotelServices] = [PGHotelServices]()
    var policyInfo:PGHotelPolicyInfo?
    init(json: JSONDictionary) {
        if let contacts = json["contact"] as? JSONDictionary {
            if let phoneNumbers = contacts["phoneNumbers"] as? JSONDictionary{
                if let key = phoneNumbers.first?.key {
                    phoneNumber = phoneNumbers[key] as? String
                }
            }
            if let url = contacts["url"] as? String,!url.isEmpty {
                website = url
            }
            if let url = contacts["email"] as? String,!url.isEmpty {
                email = url
            }
        }
        if let position = json["position"] as? JSONDictionary {
            if let lat = position["latitude"] as? String,let lng = position["longitude"] as? String,let dblLat = Double(lat),let dblLng = Double(lng)  {
                self.location =  CLLocation(latitude: dblLat, longitude: dblLng)
            }
        }
        
        
        
        if let policyInformation = json["policyInformation"] as? JSONDictionary {
            self.policyInfo = PGHotelPolicyInfo(json: policyInformation)
        }
        if let services = json["services"] as? JSONDictionary {
            if let arrServices = services["services"] as? [JSONDictionary],arrServices.count > 0  {
                let srvces = arrServices.compactMap{ PGHotelServices(json: $0) }
                let topServices = kAmenities.allValues()
                let sorted = srvces.sorted { (service1, service2) -> Bool in
                    for serv in topServices {
                        if service1.value.lowercased().contains(serv.lowercased()) {
                            return true
                        }
                    }
                    return false
                }
                if sorted.count > 0 {
                    self.services.append(contentsOf: sorted)
                }
            }
        }
        
        if let rating = json["ratings"] as? JSONDictionary {
            if let rating = rating["value"] as? String,let dbl = Double(rating) {
                self.ratings_value = dbl
            }            
            self.ratings_provider = rating["provider"] as? String ?? ""
            self.ratings_symbol = rating["symbol"] as? String ?? ""
        }
        
        if let multmedia = json["multimedia"] as AnyObject? {
            
            if let images = multmedia["images"] as? [JSONDictionary],images.count > 0 {
                for image in  images {
                    let img = PGHotelImage(json: image)
                    self.images.append(img)
                }
                self.images.sort { (img1, img2) -> Bool in
                    if img1.width < img2.width {
                        return true
                    }
                    return false
                }
            }
            if let texts = multmedia["text"] as? [String],texts.count > 0 {
                self.texts.append(contentsOf: texts)
            }
        }
        else if let guestRoomInfo = json["hotelDescriptions"] as? JSONDictionary, let multmedia = guestRoomInfo["multimedia"] as? JSONDictionary {
            
            if let images = multmedia["images"] as? [AnyObject],images.count > 0 {
                if let imgdata = images.first as? [JSONDictionary] {
                    for image in  imgdata {
                        
                        var imgObj = [PGHotelImage]()
                        if let formats = image["formats"] as? [JSONDictionary] {
                            for format in formats {
                                let img = PGHotelImage(json: format)
                                imgObj.append(img)
                                //self.images.append(img)
                            }
                        }
                        
                        imgObj.sort { (img1, img2) -> Bool in
                            if img1.width < img2.width {
                                return true
                            }
                            return false
                        }
                        
                        ///////
                        var selImage:PGHotelImage? = imgObj.first
                        for img in imgObj {
                            if img.width > 1000 {
                                break
                            }
                            selImage = img
                        }
                        if let caption = image["caption"] as? String {
                            selImage?.caption = caption
                        }
                        if let imgHotel = selImage {
                            self.images.append(imgHotel)
                        }
                    }
                }
                
                self.images.sort { (img1, img2) -> Bool in
                    if img1.width < img2.width {
                        return true
                    }
                    return false
                }
            }
            
            
            if let texts = multmedia["texts"] as? [String],texts.count > 0 {
                self.texts.append(contentsOf: texts)
            }
            
            
        }
        else if let guestRoomInfo = json["guestRoomInfo"] as? JSONDictionary, let multmedia = guestRoomInfo["multimedia"] as? JSONDictionary {
            
            if let images = multmedia["images"] as? [AnyObject],images.count > 0 {
                if let imgdata = images.first as? [JSONDictionary] {
                    for image in  imgdata {
                        
                        var imgObj = [PGHotelImage]()
                        if let formats = image["formats"] as? [JSONDictionary] {
                            for format in formats {
                                let img = PGHotelImage(json: format)
                                imgObj.append(img)
                                //self.images.append(img)
                            }
                        }
                        
                        imgObj.sort { (img1, img2) -> Bool in
                            if img1.width < img2.width {
                                return true
                            }
                            return false
                        }
                        
                        ///////
                        var selImage:PGHotelImage? = imgObj.first
                        for img in imgObj {
                            if img.width > 1000 {
                                break
                            }
                            selImage = img
                        }
                        if let caption = image["caption"] as? String {
                            selImage?.caption = caption
                        }
                        if let imgHotel = selImage {
                            self.images.append(imgHotel)
                        }
                    }
                }
                
                self.images.sort { (img1, img2) -> Bool in
                    if img1.width < img2.width {
                        return true
                    }
                    return false
                }
            }
            
            
            if let texts = multmedia["texts"] as? [String],texts.count > 0 {
                self.texts.append(contentsOf: texts)
            }
            
            
        }
    }
    
    
    
    
}
struct PGHotelImage {
    var url:String = ""
    var name:String = ""
    var size:CGFloat = 0
    var height:CGFloat = 0
    var width:CGFloat = 0
    var caption:String = ""
    init(json: JSONDictionary) {
        url = json["url"] as? String ?? ""
        name = json["name"] as? String ?? ""
        if let value = json["size"] as? String {
            size = CGFloat((value as NSString).floatValue)
        }
        if let value = json["height"] as? String {
            height = CGFloat((value as NSString).floatValue)
        }
        if let value = json["width"] as? String {
            width = CGFloat((value as NSString).floatValue)
        }
        
    }
    init(json: AnyObject) {
        url = json["url"] as? String ?? ""
        name = json["name"] as? String ?? ""
        if let value = json["size"] as? String {
            size = CGFloat((value as NSString).floatValue)
        }
        if let value = json["height"] as? String {
            height = CGFloat((value as NSString).floatValue)
        }
        if let value = json["width"] as? String {
            width = CGFloat((value as NSString).floatValue)
        }
        
    }
}
struct PGHotelServices {
    var code:Int = 0
    var value:String! = ""
    init(json: JSONDictionary) {
        code = json["code"] as? Int ?? 0
        value = json["value"] as? String ?? ""
    }
}
struct PGHotelPolicyInfo {
    var checkInTime:String = ""
    var checkOutTime:String = ""
    var texts:[String] = [String]()
    
    
    init(json: JSONDictionary) {
        checkInTime = json["checkInTime"] as? String ?? ""
        checkOutTime = json["checkOutTime"] as? String ?? ""
        if let descArr = json["description"] as? JSONDictionary {
            if let text = descArr["Text"] as? JSONDictionary {
                if let text2 = text["#text"] as? String {
                    texts.append(text2)
                }
            }
        }
    }
}
