//
//  Flight.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 12/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

class FlightResponse {
    var data: FlightResult

    init(json: JSONDictionary) {
        data = FlightResult.init(json: json["data"] as! JSONDictionary)
    }
}

class FlightResult {
    var incoming: FlightBooking?
    var outgoing: FlightBooking

    init(json: JSONDictionary) {
        if let inco = json["incoming"] as? JSONDictionary {
            incoming = FlightBooking.init(json: inco)
        } else {
            incoming = nil
        }
        outgoing = FlightBooking.init(json: json["outgoing"] as! JSONDictionary)
    }
}

class FlightBooking {
    var results: [FlightSearchResult]
    var airlines: [Company]
    var noOfFlights: Int

    init(json: JSONDictionary) {
        noOfFlights = json["noOfFlights"] as? Int ?? 0
        
        if let a = json["airlines"] as? [JSONDictionary] {
            airlines = a.compactMap{ Company.init(json: $0) }
        } else {
            airlines = []
        }
        if let a = json["results"] as? [JSONDictionary] {
            results = a.enumerated().compactMap{ index, json in
                FlightSearchResult.init(json: json, index: index)
            }
        } else {
            results = []
        }
    }
}

class FlightSearchResult: Hashable {
    var segmentRef: String
    var details: [Detail]
    var totalAggAmount: Double
    var flights: [Flight]
    var totalAggTax: Double
    var duration: String
    var index: Int
    let fareFamily: FareFamily?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self.totalAggAmount)
        hasher.combine(self.totalAggTax)
        hasher.combine(self.details.count)
        hasher.combine(self.duration)
        hasher.combine(self.flights.first!)
    }
    
    init(json: JSONDictionary, index: Int) {
        self.index = index
        segmentRef = json["segmentRef"] as? String ?? ""
        totalAggAmount = json["totalAggAmount"] as? Double ?? 0.0
        totalAggTax = json["totalAggTax"] as? Double ?? 0.0
        duration = json["duration"] as? String ?? ""
        if let d = json["details"] as? [JSONDictionary] {
            details = d.compactMap { Detail.init(json: $0) }
        } else {
            details = []
        }
        if let d = json["flights"] as? [JSONDictionary] {
            flights = d.compactMap { Flight.init(json: $0) }
        } else {
            flights = []
        }
        
        if let fareFamily = json["fareFamily"] as? JSONDictionary {
            self.fareFamily = FareFamily(json: fareFamily)
        } else {
            self.fareFamily = nil
        }
    }

    var durationInMinutes: Int {
        var sum = 0
        for flight in flights {
            let components = flight.flightDuration.components(separatedBy: ".")
            guard let hour = components.first,
                let minute = components.last else { continue }
            if let hourToInt = Int(hour) {
                sum += (hourToInt * 60)
            }
            if let minutesToInt = Int(minute) {
                sum += minutesToInt
            }
        }
        return sum
    }
}

extension FlightSearchResult {
    static func ==(lhs: FlightSearchResult, rhs: FlightSearchResult) -> Bool {
        return lhs.totalAggAmount == rhs.totalAggAmount &&
        lhs.details.count == rhs.details.count &&
        lhs.totalAggTax == rhs.totalAggTax &&
        lhs.duration == rhs.duration &&
        lhs.flights.first == rhs.flights.first
    }
}

class Flight: Hashable {
    var operatingCompany: Company?
    var flightNumber: String
    var availabilityCtx: String?
    var timeOfDeparture: String
    var dateOfDeparture: String
    let arrivalLocation: String
    let timeOfArrival: String
    let departureLocation: String
    let arrivalAirport: Airport?
    let departureTerminal: String?
    let departureAirport: Airport?
    let flightDuration: String
    let marketingCompany: Company?
    let electronicTicketing: String
    let currency: String
    let arrivalTerminal: String?
    let dateOfArrival: String

    var departureDate: Date {
        let departureDate = "\(dateOfDeparture) \(timeOfDeparture)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: departureDate)
        return date!
    }

    var arrivalDate: Date {
        let departureDate = "\(dateOfArrival) \(timeOfArrival)"
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd HH:mm"
        let date = dateFormatter.date(from: departureDate)
        return date!
    }

    init(json: JSONDictionary) {
        
        flightNumber = json["flightNumber"] as? String ?? ""
        availabilityCtx = json["flightNumber"] as? String
        timeOfDeparture = json["timeOfDeparture"] as? String ?? ""
        timeOfArrival = json["timeOfArrival"] as? String ?? ""
        dateOfDeparture = json["dateOfDeparture"] as? String ?? ""
        arrivalLocation = json["arrivalLocation"] as? String ?? ""
        departureLocation = json["departureLocation"] as? String ?? ""
        dateOfArrival = json["dateOfArrival"] as? String ?? ""
        departureTerminal = json["departureTerminal"] as? String
        arrivalTerminal = json["arrivalTerminal"] as? String
        flightDuration = json["flightDuration"] as? String ?? ""
        electronicTicketing = json["electronicTicketing"] as? String ?? ""
        currency = json["currency"] as? String ?? ""

        if let company = json["operatingCompany"] as? JSONDictionary {
            operatingCompany = Company.init(json: company)
        } else {
            operatingCompany = nil
        }
        
        
        if let company = json["marketingCompany"] as? JSONDictionary {
            marketingCompany = Company.init(json: company)
        } else {
            marketingCompany = nil
        }
        if let airport = json["arrivalAirport"] as? JSONDictionary {
            arrivalAirport = Airport.init(json: airport)
        } else {
            arrivalAirport = nil
        }
        if let airport = json["departureAirport"] as? JSONDictionary {
            departureAirport = Airport.init(json: airport)
        } else {
            departureAirport = nil
        }
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(self.flightNumber)
        hasher.combine(self.timeOfDeparture)
        hasher.combine(self.operatingCompany!._id)
    }
}

extension Flight {
    static func ==(lhs: Flight, rhs: Flight) -> Bool {
        return lhs.flightNumber == rhs.flightNumber &&
            lhs.timeOfDeparture == rhs.timeOfDeparture &&
            lhs.operatingCompany == rhs.operatingCompany
    }
}

class Company: Codable, Hashable {
    var iata: String?
    let full_name: String?
    let country_name: String?
    let logo_small: String?
    let logo: String?
    let _id: String?
    let designator: String?

    init(json: JSONDictionary) {
        logo = json["logo_square"] as? String ?? ""
        _id = json["_id"] as? String ?? ""
        designator = json["designator"] as? String ?? json["iata"]  as? String ?? ""
        full_name = json["name"] as? String ??  json["full_name"] as? String ??  ""
        country_name = json["country"] as? String ?? json["country_name"] as? String ?? ""
        logo_small = json["logo_square"] as? String ?? ""
        iata = json["iata"] as? String ?? ""
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(self._id)
    }
}

extension Company {
    static func ==(lhs: Company, rhs: Company) -> Bool {
        return lhs._id == rhs._id
    }
}

class Detail {
    let fareAmount: Double
    let amount: Double
    let passengerType: String
    let rbd: String?
    let fareRule: FareRule?
    let totalPassenger: Int
    let totalAmount: Double
    let fareBasis: String?
    let cabin: String
    let taxAmount: Double

    init(json: JSONDictionary) {
        fareAmount = json["fareAmount"] as? Double ?? 0.0
        amount = json["amount"] as? Double ?? 0.0
        passengerType = json["passengerType"] as? String ?? ""
        rbd = json["rbd"] as? String
        if let rule = json["fareRule"] as? JSONDictionary {
            fareRule = FareRule(json: rule)
        } else {
            fareRule = nil
        }
        totalPassenger = json["totalPassenger"] as? Int ?? 0
        totalAmount = json["totalAmount"] as? Double ?? 0.0
        fareBasis = json["fareBasis"] as? String
        cabin = json["cabin"] as? String ?? ""
        taxAmount = json["taxAmount"] as? Double ?? 0.0
    }
}


class FareRule {
    let PEN: String?
    let LTD: String?
    let SUR: String?

    init(json: JSONDictionary) {
        PEN = json["PEN"] as? String
        LTD = json["LTD"] as? String
        SUR = json["SUR"] as? String
    }
}

class FareFamily {
    var name: String?
    var carrier: String?
    let status: Bool
    
    init(json: JSONDictionary) {
        name = json["name"] as? String
        carrier = json["carrier"] as? String
        status = json["status"] as? Bool ?? false
    }
}

class FareFamilyResult {
    
    var data: [FareFamilyData]
    
    init(json: JSONDictionary) {
        if let dataDict = json["data"] as? [JSONDictionary] {
            data = dataDict.compactMap{FareFamilyData.init(json: $0)}
        }else {
            data = []
        }
    }
}

class FareFamilyPrice {
    
    var currency: String
    var totalAmount: Double
    var totalTaxAmount: Double
    
    init(json: JSONDictionary) {
        currency = json["currency"] as? String ?? ""
        totalAmount = json["totalAmount"] as? Double ?? 0.0
        totalTaxAmount = json["totalTaxAmount"] as? Double ?? 0.0
    }
}

class FareFamilyDetails {

    var departureLocation: String
    var currency: String
    var marketingCompany: String
    var fareClass: String
    var fareFamily: String
    var arrivalLocation: String
    var segments: [FareFamilySegment]
    
    init(json: JSONDictionary) {
        departureLocation = json["departureLocation"] as? String ?? ""
        currency = json["currency"] as? String ?? ""
        marketingCompany = json["marketingCompany"] as? String ?? ""
        fareClass = json["fareClass"] as? String ?? ""
        fareFamily = json["fareFamily"] as? String ?? ""
        arrivalLocation = json["arrivalLocation"] as? String ?? ""
        if let segmentsDict = json["segments"] as? [JSONDictionary] {
            segments = segmentsDict.compactMap{FareFamilySegment(json: $0)}
        }else {
            segments = []
        }
    }
}


class FareFamilySegment {
    
    var operatingCompany: String
    var timeOfDeparture: String
    var arrivalLocation: String
    var timeOfArrival: String
    var departureLocation: String
    var departureTerminal: String
    var departureDate: String
    var marketingCompany: String
    var bookingClass: String
    var arrivalTerminal: String
    var flightNumber: String
    var dateOfArrival: String
    
    init(json: JSONDictionary) {
        
        operatingCompany = json["operatingCompany"] as? String ?? ""
        timeOfDeparture = json["timeOfDeparture"] as? String ?? ""
        arrivalLocation = json["arrivalLocation"] as? String ?? ""
        timeOfArrival = json["timeOfArrival"] as? String ?? ""
        departureLocation = json["departureLocation"] as? String ?? ""
        departureTerminal = json["departureTerminal"] as? String ?? ""
        departureDate = json["departureDate"] as? String ?? ""
        marketingCompany = json["marketingCompany"] as? String ?? ""
        bookingClass = json["bookingClass"] as? String ?? ""
        arrivalTerminal = json["arrivalTerminal"] as? String ?? ""
        flightNumber = json["flightNumber"] as? String ?? ""
        dateOfArrival = json["dateOfArrival"] as? String ?? ""
    }
}

class FareFamilyData {
    
    var price: FareFamilyPrice?
    var details: [FareFamilyDetails]
    var familyDescription: FamililyDescription?
   
    init(json: JSONDictionary) {
        if let priceDict = json["price"] as? JSONDictionary {
            self.price = FareFamilyPrice(json: priceDict)
        }else {
            price = nil
        }
        
        if let detialsDict = json["details"] as? [JSONDictionary] {
            details = detialsDict.compactMap {FareFamilyDetails.init(json: $0)}
        }else {
            details = []
        }
        if let familyDescriptionDict = json["familyDescription"] as? JSONDictionary {
            familyDescription = FamililyDescription(json: familyDescriptionDict)
        }else {
            familyDescription = nil
        }
    }
}

class FamililyDescription {
    
    var familyName: String
    var marketingCompany: String
    var description: String
    var services: [FareFamilyServices]
    
    init(json: JSONDictionary) {
        familyName = json["familyName"] as? String ?? ""
        marketingCompany = json["marketingCompany"] as? String ?? ""
        description = json["description"] as? String ?? ""
        if let servicesDict = json["services"] as? [JSONDictionary] {
            services = servicesDict.compactMap { FareFamilyServices.init(json: $0) }
        } else {
            services = []
        }
    }
}

class FareFamilyServices {
    
    var serviceName: String
    var serviceDescription: String
    
    init(json: JSONDictionary) {
        serviceName = json["serviceName"] as? String ?? ""
        serviceDescription = json["serviceDescription"] as? String ?? ""
    }
}


class FareRules {
    
    var data: [String]
    
    init(json: JSONDictionary) {
       data = json["data"] as? [String] ?? []
    }
}

extension Double {
    func rounded(toPlaces places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}

// MARK: - Air Get Outbound Flights Response

struct InboundFlightData: Codable {
    var data: InboundFlight
}


struct OutboundFlightData: Codable {
    var data: OutboundFlight
}


struct BasicResponse: Codable {
    let status: Bool?
    let statusCode: Int?
    let msg: String?
}

struct InboundFlight: Codable {
    var inboundFlights: [FlightDetails]
}

struct OutboundFlight: Codable {
    var outboundFlights: [FlightDetails]
    var airlines: [Company]?
}

struct FlightDetails: Codable {
    
    var amount: String?
    var fareFamily: Bool?
    var bookingClass: String?
    var fareBasis: String?
    var duration: String?
    var flightInfo: [OutboundFlightItinerary]?
    
}

extension FlightDetails {
    var durationInMinutes: Int? {
        var sum = 0
        let components = duration?.components(separatedBy: ":")
        guard let hour = components?.first,
            let minute = components?.last else {
                return nil
        }
        
        if let hourToInt = Int(hour) {
            sum += (hourToInt * 60)
        }
        
        if let minutesToInt = Int(minute) {
            sum += minutesToInt
        }
        
        return sum
    }
}

struct OutboundFlightItinerary: Codable {
    
    var timeOfDeparture: String
    var timeOfArrival: String
    var dateOfDeparture: String
    var dateOfArrival: String
    var departureLocation: String
    var departureDetails: FlightItineraryDetails?
    var arrivalLocation: String
    var arrivalDetails: FlightItineraryDetails?
    var departureTerminal: String?
    var arrivalTerminal: String?
    var operatingCompany: String?
    var operatingDetails: FlightItineraryOperatingDetails
    var marketingCompany: String?
    var marketingDetails: FlightItineraryOperatingDetails
    var flightNumber: String
    var electronicTicketing: String
}

struct FlightItineraryOperatingDetails: Codable {
    
    var iata: String
    var fullName: String
    var countryName: String
    var logoSmall: String
    var logo: String
    
    enum CodingKeys: String, CodingKey {
        case iata
        case fullName = "full_name"
        case logoSmall = "logo_small"
        case logo
        case countryName = "country_name"
    }
}


struct FlightItineraryDetails: Codable {
    
    var iata: String
    var name: String
    var cityName: String
    var stateName: String
    var countryName: String
    
    enum CodingKeys: String, CodingKey {
        case iata
        case name
        case cityName = "city_name"
        case stateName = "state_name"
        case countryName = "country_name"
    }
}





// MARK: - DataClass
struct DataClass: Codable {
    let outboundFlights: [OutboundFlights]
}
// MARK: - OutboundFlight
struct OutboundFlights: Codable {
    let amount, cabin, fareBasis: String
    let itinerary: [Itinerary]
    let fareFamily: Bool
    let duration: String
}

// MARK: - Itinerary
struct Itinerary: Codable {
//    let arrivalDetails: ArrivalDetails
//    let operatingCompany: String
//    let timeOfDeparture, dateOfDeparture, arrivalLocation, timeOfArrival: String
//    let departureLocation: String
//    let marketingDetails: TingDetails
//    let departureDetails: Details
//    let departureTerminal: String?
//    let operatingDetails: TingDetails
//    let marketingCompany: String
//    let electronicTicketing: String
//    let arrivalTerminal: String?
//    let flightNumber, dateOfArrival: String
}
enum ArrivalDetails: Codable {
    case anythingArray([JSONAny])
    case details(Details)
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let x = try? container.decode([JSONAny].self) {
            self = .anythingArray(x)
            return
        }
        if let x = try? container.decode(Details.self) {
            self = .details(x)
            return
        }
        throw DecodingError.typeMismatch(ArrivalDetails.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for ArrivalDetails"))
    }
    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .anythingArray(let x):
            try container.encode(x)
        case .details(let x):
            try container.encode(x)
        }
    }
}
// MARK: - Details
struct Details: Codable {
    let iata, stateName, cityName, name: String
    let countryName: String
    enum CodingKeys: String, CodingKey {
        case iata
        case stateName = "state_name"
        case cityName = "city_name"
        case name
        case countryName = "country_name"
    }
}

// MARK: - TingDetails
struct TingDetails: Codable {
    let iata: String
    let fullName: String
    let logoSmall: String
    let countryName: String
    let logo: String
    enum CodingKeys: String, CodingKey {
        case iata
        case fullName = "full_name"
        case logoSmall = "logo_small"
        case countryName = "country_name"
        case logo
    }
}

// MARK: - Encode/decode helpers
class JSONNull: Codable, Hashable {
    public static func == (lhs: JSONNull, rhs: JSONNull) -> Bool {
        return true
    }
    public var hashValue: Int {
        return 0
    }
    public init() {}
    public required init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if !container.decodeNil() {
            throw DecodingError.typeMismatch(JSONNull.self, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Wrong type for JSONNull"))
        }
    }
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encodeNil()
    }
}
class JSONCodingKey: CodingKey {
    let key: String
    required init?(intValue: Int) {
        return nil
    }
    required init?(stringValue: String) {
        key = stringValue
    }
    var intValue: Int? {
        return nil
    }
    var stringValue: String {
        return key
    }
}
class JSONAny: Codable {
    let value: Any
    static func decodingError(forCodingPath codingPath: [CodingKey]) -> DecodingError {
        let context = DecodingError.Context(codingPath: codingPath, debugDescription: "Cannot decode JSONAny")
        return DecodingError.typeMismatch(JSONAny.self, context)
    }
    static func encodingError(forValue value: Any, codingPath: [CodingKey]) -> EncodingError {
        let context = EncodingError.Context(codingPath: codingPath, debugDescription: "Cannot encode JSONAny")
        return EncodingError.invalidValue(value, context)
    }
    static func decode(from container: SingleValueDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if container.decodeNil() {
            return JSONNull()
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    static func decode(from container: inout UnkeyedDecodingContainer) throws -> Any {
        if let value = try? container.decode(Bool.self) {
            return value
        }
        if let value = try? container.decode(Int64.self) {
            return value
        }
        if let value = try? container.decode(Double.self) {
            return value
        }
        if let value = try? container.decode(String.self) {
            return value
        }
        if let value = try? container.decodeNil() {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer() {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    static func decode(from container: inout KeyedDecodingContainer<JSONCodingKey>, forKey key: JSONCodingKey) throws -> Any {
        if let value = try? container.decode(Bool.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Int64.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(Double.self, forKey: key) {
            return value
        }
        if let value = try? container.decode(String.self, forKey: key) {
            return value
        }
        if let value = try? container.decodeNil(forKey: key) {
            if value {
                return JSONNull()
            }
        }
        if var container = try? container.nestedUnkeyedContainer(forKey: key) {
            return try decodeArray(from: &container)
        }
        if var container = try? container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key) {
            return try decodeDictionary(from: &container)
        }
        throw decodingError(forCodingPath: container.codingPath)
    }
    static func decodeArray(from container: inout UnkeyedDecodingContainer) throws -> [Any] {
        var arr: [Any] = []
        while !container.isAtEnd {
            let value = try decode(from: &container)
            arr.append(value)
        }
        return arr
    }
    static func decodeDictionary(from container: inout KeyedDecodingContainer<JSONCodingKey>) throws -> [String: Any] {
        var dict = [String: Any]()
        for key in container.allKeys {
            let value = try decode(from: &container, forKey: key)
            dict[key.stringValue] = value
        }
        return dict
    }
    static func encode(to container: inout UnkeyedEncodingContainer, array: [Any]) throws {
        for value in array {
            if let value = value as? Bool {
                try container.encode(value)
            } else if let value = value as? Int64 {
                try container.encode(value)
            } else if let value = value as? Double {
                try container.encode(value)
            } else if let value = value as? String {
                try container.encode(value)
            } else if value is JSONNull {
                try container.encodeNil()
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer()
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    static func encode(to container: inout KeyedEncodingContainer<JSONCodingKey>, dictionary: [String: Any]) throws {
        for (key, value) in dictionary {
            let key = JSONCodingKey(stringValue: key)!
            if let value = value as? Bool {
                try container.encode(value, forKey: key)
            } else if let value = value as? Int64 {
                try container.encode(value, forKey: key)
            } else if let value = value as? Double {
                try container.encode(value, forKey: key)
            } else if let value = value as? String {
                try container.encode(value, forKey: key)
            } else if value is JSONNull {
                try container.encodeNil(forKey: key)
            } else if let value = value as? [Any] {
                var container = container.nestedUnkeyedContainer(forKey: key)
                try encode(to: &container, array: value)
            } else if let value = value as? [String: Any] {
                var container = container.nestedContainer(keyedBy: JSONCodingKey.self, forKey: key)
                try encode(to: &container, dictionary: value)
            } else {
                throw encodingError(forValue: value, codingPath: container.codingPath)
            }
        }
    }
    static func encode(to container: inout SingleValueEncodingContainer, value: Any) throws {
        if let value = value as? Bool {
            try container.encode(value)
        } else if let value = value as? Int64 {
            try container.encode(value)
        } else if let value = value as? Double {
            try container.encode(value)
        } else if let value = value as? String {
            try container.encode(value)
        } else if value is JSONNull {
            try container.encodeNil()
        } else {
            throw encodingError(forValue: value, codingPath: container.codingPath)
        }
    }
    public required init(from decoder: Decoder) throws {
        if var arrayContainer = try? decoder.unkeyedContainer() {
            self.value = try JSONAny.decodeArray(from: &arrayContainer)
        } else if var container = try? decoder.container(keyedBy: JSONCodingKey.self) {
            self.value = try JSONAny.decodeDictionary(from: &container)
        } else {
            let container = try decoder.singleValueContainer()
            self.value = try JSONAny.decode(from: container)
        }
    }
    public func encode(to encoder: Encoder) throws {
        if let arr = self.value as? [Any] {
            var container = encoder.unkeyedContainer()
            try JSONAny.encode(to: &container, array: arr)
        } else if let dict = self.value as? [String: Any] {
            var container = encoder.container(keyedBy: JSONCodingKey.self)
            try JSONAny.encode(to: &container, dictionary: dict)
        } else {
            var container = encoder.singleValueContainer()
            try JSONAny.encode(to: &container, value: self.value)
        }
    }
}
