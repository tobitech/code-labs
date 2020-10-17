//
//  BestFlightVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 01/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation

final class BestFlightVC: BaseVC {
    @IBOutlet var btnIgnoreBestPricing: TrajilisButton!
    @IBOutlet var tableView: UITableView!
    var tripType = FlightTrip.roundTrip
    var outgoing: FlightSearchResult!
    var incoming: FlightSearchResult?
    var param: JSONDictionary!
    var departureDate: Date?

    var returnDate: Date?
    var destination: Airport?
    var origin: Airport?

    var travelersData: TravelersData?

    var bestPricing = [BestPricing]()
    var fareRules = [PGFareRule]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.travelersData = (self.navigationController as? BookingNavigationController)?.travelersData
        
        tableView.tableFooterView = UIView.init(frame: .zero)
        title = "Best Pricing"
        self.btnIgnoreBestPricing.setTitle("Continue With Regular Price", for: .normal)
    }
}

extension BestFlightVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return bestPricing.count
    }
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BestPricingTableViewCell.identifier) as! BestPricingTableViewCell
        let best = bestPricing[indexPath.row]
        cell.configure(best: best)
        return cell
    }
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let best = bestPricing[indexPath.row]
        let controller = TravelerInformationVC.instantiate(fromAppStoryboard: .flight)
        controller.tripType = self.tripType
        controller.param = param
        controller.departureDate = departureDate
        controller.returnDate = returnDate
        controller.destination = destination
        controller.origin = origin
        controller.bestPricing = best
        
        controller.fareRules = fareRules
        navigationController?.pushViewController(controller, animated: true)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 64
    }

    @IBAction func btnIgnoreBestPricingTapped(sender:UIButton) {
        
        let controller = TravelerInformationVC.instantiate(fromAppStoryboard: .flight)
        controller.tripType = self.tripType
        controller.param = param
        controller.departureDate = departureDate
        controller.returnDate = returnDate
        controller.destination = destination
        controller.origin = origin
        controller.bestPricing = nil
        
        controller.fareRules = fareRules
        navigationController?.pushViewController(controller, animated: true)
        
    }
}

struct BestPricing {
    let currency: String
    let fareAmount: Double
    let totalAmount: TotalAmount?
    let flights: [BestPricingFlight]
    let taxAmount: Double

    init(json: JSONDictionary) {
        let pricingDict = json["price"] as! JSONDictionary
        currency = pricingDict["currency"] as? String ?? ""
        fareAmount = pricingDict["fareAmount"] as? Double ?? 0
        if let dict = pricingDict["totalAmount"] as? JSONDictionary {
            totalAmount = TotalAmount.init(json: dict)
        } else {
            totalAmount = nil
        }
        if let arrayOfFlights = json["flights"] as? [JSONDictionary] {
            flights = arrayOfFlights.compactMap{ BestPricingFlight.init(json: $0) }
        } else {
            flights = []
        }
        taxAmount = pricingDict["taxAmount"] as? Double ?? 0
    }
}
struct PGFareRule {
    let category: String
    let text: String
 
    init(json: JSONDictionary) {
        category = json["category"] as? String ?? json["categories"] as? String ?? ""
        text = json["text"] as? String ?? ""
    }
}

struct TotalAmount {
    let amount: String
    let typeQualifier: String?
    let currency: String

    init(json: JSONDictionary) {
        if let value = json["amount"] as? String, !value.isEmpty {
            amount = value
        } else if let value = json["amount"] as? Double {
            amount = "\(value.rounded(toPlaces: 2))"
        } else {
            amount = ""
        }
        typeQualifier = json["typeQualifier"] as? String ?? ""
        currency = json["currency"] as? String ?? ""
    }
}


struct BookingClass {
    let id: String
    let name: String

    init(json: JSONDictionary) {
        id = json["id"] as? String ?? ""
        name = json["name"] as? String ?? ""
    }
}

struct BestPricingFlight {
    let priceTicketDetails: String?
    let timeOfDeparture: String?
    let boardPointDetails: String?
    let companyDetails: String?
    let timeOfArrival: String?
    let offPointDetails: String?
    let rateClass: String?
    let departureDate: String?
    let bookingClass: BookingClass?
    let marketingCompany: Company?
    let flightNumber: String
    let dateOfArrival: String?

    init(json: JSONDictionary) {
        priceTicketDetails = json["priceTicketDetails"] as? String
        timeOfDeparture = json["timeOfDeparture"] as? String

        boardPointDetails = json["boardPointDetails"] as? String
        companyDetails = json["companyDetails"] as? String
        offPointDetails = json["offPointDetails"] as? String
        rateClass = json["rateClass"] as? String
        timeOfArrival = json["timeOfArrival"] as? String
        departureDate = json["departureDate"] as? String
        dateOfArrival = json["dateOfArrival"] as? String
        flightNumber = json["flightNumber"] as? String ?? ""
        if let dict = json["bookingClass"] as? JSONDictionary {
            bookingClass = BookingClass.init(json: dict)
        } else {
            bookingClass = nil
        }

        if let dict = json["marketingCompany"] as? JSONDictionary {
            marketingCompany = Company.init(json: dict)
        } else {
            marketingCompany = nil
        }
    }
}
