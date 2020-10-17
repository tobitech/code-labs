//
//  FlightDetailsVC.swift
//  Trajilis
//
//  Created by Perfect Aduh on 05/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class FlightDetailsVC: BaseVC {

    @IBOutlet weak var outboundCityTitleLbl: UILabel!
    @IBOutlet weak var outboundDepartureTitleDate: UILabel!
    @IBOutlet weak var outboundFlightNumber: UILabel!
    @IBOutlet weak var outboundAirlineNameLbl: UILabel!
    @IBOutlet weak var outboundDurationLbl: UILabel!
    @IBOutlet weak var outboundOriginCityLbl: UILabel!
    @IBOutlet weak var outboundDestinationCityLbl: UILabel!
    @IBOutlet weak var outboundOriginIataLbl: UILabel!
    @IBOutlet weak var outboundDestinationIataLbl: UILabel!
    @IBOutlet weak var outboundDepartureDateLbl: UILabel!
    @IBOutlet weak var outboundArrivalDateLbl: UILabel!
    @IBOutlet weak var outboundDepartureTimeLbl: UILabel!
    @IBOutlet weak var outboundArrivalTimeLbl: UILabel!
    
    @IBOutlet weak var outboundAirlineLogoImgV: UIImageView!
    
    @IBOutlet weak var returnCityTitleLbl: UILabel!
    @IBOutlet weak var returnDepartureTitleDate: UILabel!
    @IBOutlet weak var returnFlightNumber: UILabel!
    @IBOutlet weak var returnAirlineNameLbl: UILabel!
    @IBOutlet weak var returnDurationLbl: UILabel!
    @IBOutlet weak var returnOriginCityLbl: UILabel!
    @IBOutlet weak var returnDestinationCityLbl: UILabel!
    @IBOutlet weak var returnOriginIataLbl: UILabel!
    @IBOutlet weak var returnDestinationIataLbl: UILabel!
    @IBOutlet weak var returnDepartureDateLbl: UILabel!
    @IBOutlet weak var returnArrivalDateLbl: UILabel!
    @IBOutlet weak var returnDepartureTimeLbl: UILabel!
    @IBOutlet weak var returnArrivalTimeLbl: UILabel!
    
    @IBOutlet weak var continueBtn: UIButton!
    
    @IBOutlet weak var returnAirlineLogoImgV: UIImageView!
    @IBOutlet weak var fareRulesLabel: UILabel!
    
    var tripType = FlightTrip.roundTrip
    
    var param: JSONDictionary!
    
    var departureDate: Date?
    var cabinClass:FlightClass = FlightClass.economy
    var returnDate: Date?
    
    var destination: Airport?
    var origin: Airport?
    
    var inboundFlight: FlightDetails?
    var outboundFlight: FlightDetails?
    
    var bestPricing = [BestPricing]()
    var fareRules = [PGFareRule]()
    var airlines = [Company]()
    var flightFareRules = [String]()
    
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Flight Details"
        
        self.getPricing()
        
        setupViews()
    }
    
    // MARK: View Setup
    
    fileprivate func setupViews() {
        outboundCityTitleLbl.text = destination?.city ?? ""
        outboundDepartureTitleDate.text = Helpers.formattedDateFromString(dateString: outboundFlight?.flightInfo?[0].dateOfDeparture ?? "", withFormat: "EEE, MMM d") //
        outboundFlightNumber.text =  "Flight No: \(outboundFlight?.flightInfo?[0].flightNumber ?? "")"
        outboundAirlineNameLbl.text = outboundFlight?.flightInfo?[0].operatingDetails.fullName
        outboundDurationLbl.text = "\(outboundFlight?.duration ?? "")h"
        outboundOriginCityLbl.text = origin?.city ?? ""
        outboundDestinationCityLbl.text = destination?.city ?? ""
        outboundOriginIataLbl.text = origin?.iata ?? ""
        outboundDestinationIataLbl.text = destination?.iata ?? ""
        outboundDepartureDateLbl.text = Helpers.formattedDateFromString(dateString: outboundFlight?.flightInfo?[0].dateOfDeparture ?? "", withFormat: "EEE, MMM d") //
        outboundArrivalDateLbl.text = Helpers.formattedDateFromString(dateString: outboundFlight?.flightInfo?[0].dateOfArrival ?? "", withFormat: "EEE, MMM d") //
        outboundDepartureTimeLbl.text = outboundFlight?.flightInfo?[0].timeOfDeparture
        outboundArrivalTimeLbl.text = outboundFlight?.flightInfo?[0].timeOfArrival
        if let url = URL(string: outboundFlight?.flightInfo?[0].marketingDetails.logoSmall ?? "") {
            outboundAirlineLogoImgV.sd_setImage(with: url)
        }
        
        returnCityTitleLbl.text = origin?.city ?? ""
        returnDepartureTitleDate.text = Helpers.formattedDateFromString(dateString: inboundFlight?.flightInfo?[0].dateOfDeparture ?? "", withFormat: "EEE, MMM d") //
        returnFlightNumber.text =   "Flight No: \(inboundFlight?.flightInfo?[0].flightNumber ?? "")"
        returnAirlineNameLbl.text = inboundFlight?.flightInfo?[0].operatingDetails.fullName
        returnDurationLbl.text = "\(inboundFlight?.duration ?? "")h"
        returnOriginCityLbl.text = origin?.city ?? ""
        returnDestinationCityLbl.text = destination?.city ?? ""
        returnOriginIataLbl.text = origin?.iata ?? ""
        returnDestinationIataLbl.text = destination?.iata ?? ""
        returnDepartureDateLbl.text = Helpers.formattedDateFromString(dateString: inboundFlight?.flightInfo?[0].dateOfDeparture ?? "", withFormat: "EEE, MMM d") //
        returnArrivalDateLbl.text = Helpers.formattedDateFromString(dateString: inboundFlight?.flightInfo?[0].dateOfArrival ?? "", withFormat: "EEE, MMM d") //
        returnDepartureTimeLbl.text = inboundFlight?.flightInfo?[0].timeOfDeparture
        returnArrivalTimeLbl.text = inboundFlight?.flightInfo?[0].timeOfArrival
        
        if let url = URL(string: inboundFlight?.flightInfo?[0].marketingDetails.logoSmall ?? "") {
            returnAirlineLogoImgV.sd_setImage(with: url)
        }
        
        continueBtn.makeCornerRadius(cornerRadius: 4.0)
        continueBtn.addTarget(self, action: #selector(handleContinueBtn), for: .touchUpInside)
    }
    
    // MARK: - Helpers
    
    fileprivate func getPricing() {
        self.spinner(with: "Getting Pricing", blockInteraction: true)
        self.getBestPricing {[weak self] (success, error) in
            self?.hideSpinner()
        }
    }
    
    @objc func handleContinueBtn() {
        
        if outboundFlight?.fareFamily ?? false {
            let controller = FlightOptionVC.instantiate(fromAppStoryboard: .flight)
            controller.outboundFlight = self.outboundFlight
            controller.inboundFlight = self.inboundFlight
            
            controller.fareRules = self.fareRules
            controller.tripType = self.tripType
            controller.destination = destination
            controller.origin = origin
            
            navigationController?.pushViewController(controller, animated: true)
            
        } else {
            
            let controller = TravelerInformationVC.instantiate(fromAppStoryboard: .flight)
            
            controller.outboundFlight = self.outboundFlight
            controller.inboundFlight = self.inboundFlight
            controller.tripType = self.tripType
            controller.param = param
            controller.departureDate = departureDate
            controller.returnDate = returnDate
            controller.destination = destination
            controller.origin = origin
            controller.bestPricing = nil
            controller.fareRules = self.fareRules
            
            controller.airlines = self.airlines
            navigationController?.pushViewController(controller, animated: true)
        }
    }
}

// MARK:- Best pricing
extension FlightDetailsVC {
    fileprivate func bestPricingObject() -> JSONDictionary {
        var itinerary: [JSONDictionary] = []
        guard let outboundFlights = outboundFlight?.flightInfo else { return [:] }
        
        for flight in outboundFlights {
            let dict: JSONDictionary = [
                "dateOfDeparture": flight.dateOfDeparture,
                "timeOfDeparture": flight.timeOfDeparture,
                "dateOfArrival": flight.dateOfArrival,
                "timeOfArrival": flight.timeOfArrival,
                "departureLocation": flight.departureLocation,
                "departureTerminal": flight.departureTerminal ?? "",
                "arrivalLocation": flight.arrivalLocation,
                "arrivalTerminal": flight.arrivalTerminal ?? "",
                "marketingCompany": flight.marketingCompany,
                "operatingCompany": flight.operatingCompany,
                "flightNumber": flight.flightNumber,
                "groupNumber": "1",
                "bookingClass": outboundFlight?.bookingClass ?? ""
            ]
            itinerary.append(dict)
        }
        
        if let incomingFlights = inboundFlight?.flightInfo {
            for flight in incomingFlights {
                let dict: JSONDictionary = [
                    "dateOfDeparture": flight.dateOfDeparture,
                    "timeOfDeparture": flight.timeOfDeparture,
                    "dateOfArrival": flight.dateOfArrival,
                    "timeOfArrival": flight.timeOfArrival,
                    "departureLocation": flight.departureLocation,
                    "departureTerminal": flight.departureTerminal ?? "",
                    "arrivalLocation": flight.arrivalLocation,
                    "arrivalTerminal": flight.arrivalTerminal ?? "",
                    "marketingCompany": flight.marketingCompany,
                    "operatingCompany": flight.operatingCompany,
                    "flightNumber": flight.flightNumber,
                    "groupNumber": "1",
                    "bookingClass": inboundFlight?.bookingClass ?? ""
                ]
                itinerary.append(dict)
            }
        }
        let currency = CurrencyManager.shared.getUserCurrencyCode()
        return ["itinerary": itinerary, "currency": currency, "passengers": param["passenger"] as! [JSONDictionary]]
    }
    
    fileprivate func getBestPricing(onSuccess:( (Bool,String?) -> Void)?) {
        APIController.makeRequest(request: .bestPricing(param: bestPricingObject())) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    onSuccess?(false, kDefaultError)
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary else {
                        onSuccess?(false, kDefaultError)
                        return
                    }
                    if let data = json?["data"] as? JSONDictionary {
                        if let rules = data["rules"] as? [JSONDictionary] {
                            self.fareRules = rules.compactMap{ PGFareRule.init(json: $0) }
                        }
                        onSuccess?(true, nil)
                        return
                    } else {
                        if let msg = json?["msg"] as? String {
                            onSuccess?(false, msg)
                        } else {
                            onSuccess?(false, kDefaultError)
                        }
                    }
                }
            }
        }
    }
}


// MARK:- Fare Rules

extension FlightDetailsVC {
    
    func getFareRules(onSuccess:( (Bool,String?) -> Void)?) {
        
        let fareBasis = outboundFlight?.fareBasis ?? ""
        let origin = self.origin?.iata ?? ""
        let destination = self.destination?.iata ?? ""
        let airline = self.outboundFlight?.flightInfo?.first?.marketingCompany ?? ""
        let fareRulesParam: [String: String] = [
            "fareBasis": fareBasis,
            "airline": airline,
            "origin": origin,
            "destination": destination
        ]
        
        APIController.makeRequest(request: .fareRules(param: fareRulesParam)) { (response) in
            
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary else {
                        onSuccess?(false, kDefaultError)
                        return
                    }
                    if let data = json?["data"] as? [String] {
                        self.flightFareRules = data
                        onSuccess?(true,nil)
                        return
                    } else {
                        if let msg = json?["msg"] as? String {
                            onSuccess?(false, msg)
                        } else {
                            onSuccess?(false, kDefaultError)
                        }
                    }
                    
                case .failure(_):
                    onSuccess?(false,kDefaultError)
                    break
                }
            }
        }
    }
}
