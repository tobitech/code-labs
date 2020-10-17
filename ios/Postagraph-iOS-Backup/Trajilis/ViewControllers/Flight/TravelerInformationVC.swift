//
//  ItinararyVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 28/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
//import Stripe
import PassKit
import SkyFloatingLabelTextField

final class TravelerInformationVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    
    fileprivate let cellId = "cellId"
    
    var inboundFlight: FlightDetails?
    var outboundFlight: FlightDetails?
    
    var paymentRequest: PKPaymentRequest!
    var transactionId = ""
    var status = ""
    var fareRules = [PGFareRule]()
    var tripType = FlightTrip.roundTrip
    var param: JSONDictionary!
    var departureDate: Date?
    weak var selectedTravlerView:TravelerView?
    var returnDate: Date?
    var destination: Airport?
    var origin: Airport?
    var bestPricing: BestPricing?
    let pickerView = UIPickerView()

    var selectedApplePay:Bool = false
    
    var travelersData: TravelersData?
    var travelers = [TravelerInfo]()
    
    var isFlightBooking:Bool = true
    var hotelBooking: PGHotelBooking?
    var airlines = [Company]()
    var fareFamilyName = ""
    var bookingClass = ""
    var upsellPrice: Double?
    
    
    @IBOutlet weak var btnContinue:UIButton!
    
    let defaltPriceDetailHeight:CGFloat =  195
    private func format(date: Date, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from:date)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if isFlightBooking {
            title = "Who's Flying?"
        } else {
            title = "Guest Information"
        }
        
        self.travelersData = (self.navigationController as? BookingNavigationController)?.travelersData
        if let travelersData = self.travelersData {
            self.travelers = travelersData.allTravelers()
            self.travelersData?.adults.removeAll()
            self.travelersData?.children.removeAll()
            self.travelersData?.infantOwnSeat.removeAll()
            self.travelersData?.infantOnLap.removeAll()
        }
        
        configureForms()
    }
    
    fileprivate func configureForms() {
        btnContinue.layer.cornerRadius = 4.0
        btnContinue.layer.masksToBounds = true
        
        // tableView.register(TravelerInfoCell.self, forCellReuseIdentifier: cellId)
        
        tableView.delegate = self
        tableView.dataSource = self
        
        tableView.contentInset = .init(top: 0, left: 0, bottom: 84, right: 0)
        tableView.tableFooterView = UIView()
        tableView.backgroundColor = .white
    }
    
    @IBAction func btnContinueTapped(sender:UIButton) {
        
        guard let outboundFlight = self.outboundFlight, let inboundFlight = self.inboundFlight else { return }
        
        var itineraryArray = [JSONDictionary]()
        
        let incomingItinerary = bookabilityObject(flightDetails: inboundFlight, isReturn: true)
        itineraryArray.append(incomingItinerary)
        
        let outgoingItinerary = bookabilityObject(flightDetails: outboundFlight)
        itineraryArray.append(outgoingItinerary)
        
        let controller = PaymentVC.instantiate(fromAppStoryboard: .flight)
        controller.tripType = self.tripType
        controller.bookingItinerary = itineraryArray
        controller.passengerArray = self.getPassengers()
        controller.bestPricing = bestPricing
        controller.fareRules = self.fareRules
        controller.fareFamilyName = self.fareFamilyName
        
        controller.outboundFlight = outboundFlight
        controller.inboundFlight = inboundFlight
        
        let contact: JSONDictionary = [
            "phone": self.travelersData?.adults.first?.phone,
            "email": self.travelersData?.adults.first?.email
        ]
        controller.contact = contact

        let fareRulesVC = PGFareRuleAcknowledgeViewController.instantiate(fromAppStoryboard: .flight)
        fareRulesVC.paymentVC = controller
        navigationController?.pushViewController(fareRulesVC, animated: true)
    }
    
    fileprivate func getPassengers() -> [JSONDictionary] {
        guard let travelersData = self.travelersData else { return [] }
        
        var passengers = [JSONDictionary]()
        
        for passenger in travelersData.allTravelers() {
            var passengerDict: JSONDictionary = [
                "travellerType": passenger.travelerType.value,
                "withInfant": passenger.withInfant,
                "lastName": passenger.bio.lastname,
                "dateOfBirth": passenger.bio.dateOfBirth,
                "firstName": passenger.bio.firstname
            ]
            
            if let infant = passenger.infant {
                let infantDict: JSONDictionary = [
                    "lastName": infant.lastname,
                    "firstName": infant.firstname,
                    "dateOfBirth": infant.dateOfBirth
                ]
                
                passengerDict["infant"] = infantDict
            }
            
            passengers.append(passengerDict)
        }
        
        return passengers
    }
    
    fileprivate func bookabilityObject(flightDetails: FlightDetails, isReturn: Bool = false) -> JSONDictionary {
        var itinerary: JSONDictionary = [
            "origin": isReturn ? destination!.iata : origin!.iata,
            "destination": isReturn ? origin!.iata : destination!.iata
        ]
        guard let flights = flightDetails.flightInfo else { return JSONDictionary() }
        
        let passenger = self.travelersData?.allTravelers().count
        var segment = [JSONDictionary]()
        for flight in flights {
            
            let dict: JSONDictionary = [
                "marketingCompany": flight.marketingCompany ?? "",
                "flightNumber": flight.flightNumber,
                "departureTerminal": flight.departureTerminal ?? "",
                "dateOfDeparture": flight.dateOfDeparture,
                "dateOfArrival": flight.dateOfArrival,
                "arrivalLocation": flight.arrivalLocation,
                "groupNumber": "1",
                "timeOfDeparture": flight.timeOfDeparture,
                "operatingCompany": flight.operatingCompany ?? "",
                "timeOfArrival": flight.timeOfArrival,
                "bookingClass": flightDetails.bookingClass,
                "arrivalTerminal": flight.arrivalTerminal ?? "",
                "departureLocation": flight.departureLocation,
                "totalPassenger": passenger,
                ]
            segment.append(dict)
        }
        
        itinerary["segment"] = segment
        
        return itinerary
    }
}

extension TravelerInformationVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.travelers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! TravelerInfoCell
        
        let traveler = travelers[indexPath.row]
        cell.travelerInfo = traveler
        cell.setFormFieldValues(traveler: traveler)
        
        cell.delegate = self
        return cell
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let view = UIView()
        view.backgroundColor = .white
        
        let label = UILabel()
        label.font = UIFont(name: "PTSans-Regular", size: 16)
        label.numberOfLines = 0
        label.text = "Add your traveler details. Your name must match your photo ID exactly!"
        view.addSubview(label)
        label.fillSuperview(padding: .init(top: 20, left: 20, bottom: 0, right: 20))
        
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 80
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 450
    }
}


extension TravelerInformationVC: TravelerInfoCellDelegate {
    func didCompleteForm(_ cell: TravelerInfoCell, updatedTravelerInfo: TravelerInfo) {
        guard let indexPath = tableView.indexPath(for: cell) else { return }
        travelers[indexPath.row] = updatedTravelerInfo
        
        switch updatedTravelerInfo.travelerType {
        case .adult:
            if let travelersData = self.travelersData,
                !travelersData.adults.contains(updatedTravelerInfo) {
                self.travelersData?.adults.append(updatedTravelerInfo)
            }
        case .child:
            if let travelersData = self.travelersData,
                !travelersData.children.contains(updatedTravelerInfo) {
                self.travelersData?.children.append(updatedTravelerInfo)
            }
        case .infant:
            if let travelersData = self.travelersData,
                !travelersData.infantOnLap.contains(updatedTravelerInfo) {
                self.travelersData?.infantOnLap.append(updatedTravelerInfo)
            }
        case .infantWithSeat:
            if let travelersData = self.travelersData,
                !travelersData.infantOwnSeat.contains(updatedTravelerInfo) {
                self.travelersData?.infantOwnSeat.append(updatedTravelerInfo)
            }
        }
        
        (self.navigationController as? BookingNavigationController)?.travelersData = self.travelersData
        enableContinueButton()
    }
    
    fileprivate func enableContinueButton() {
        guard let travelersData = self.travelersData else { return }
        if travelers.count == travelersData.allTravelers().count {
            btnContinue.isEnabled = true
            btnContinue.backgroundColor = UIColor.appRed
        } else {
            btnContinue.isEnabled = false
            btnContinue.backgroundColor = UIColor.disabledButtonRed
        }
    }
}
