//
//  InboundSearchResult.swift
//  Trajilis
//
//  Created by Oluwatobi Omotayo on 24/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class InboundSearchResultVC: FlightSearchResultsVC {
    
    var searchDict = [String: Any]()
    
    var selectedOutboundFlight: FlightDetails?
    var outBoundFlight: OutboundFlightData?
    
    var inBoundFlightResponse: InboundFlightData? {
        didSet {
            if let inboundFlights = inBoundFlightResponse?.data.inboundFlights {
                self.originalSearchResult = inboundFlights
                tableView.reloadData()
            }
        }
    }
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func setupNavBar() {
        navigationItem.title = "\(origin?.iata.uppercased() ?? "") - \(destination?.iata.uppercased() ?? "")"
    }
    
    // MARK: - Helpers
    
    override func search() {
        originalSearchResult.removeAll()
        filterByNonStopResults.removeAll()
        airlines.removeAll()
        
        tableView.reloadData()
        loaderImageView.isHidden = false
        
        APIController.makeRequest(request: .getInbound(param: searchDict)) { [weak self] (result) in
            guard let `self` = self else { return }
            `self`.loaderImageView.isHidden = true
            switch result {
            case .failure(let error):
                self.showAlert(message: error.desc)
            case .success(let value):
                do {
                    let inboundFlight = try JSONDecoder.decode(value.data, to: InboundFlightData.self)
                    self.inBoundFlightResponse = inboundFlight
                } catch {
                    self.showAlert(message: self.getResponseError(data: value.data))
                }
            }
        }
    }
    
    override func updateSearchParam() {
        let currency = CurrencyManager.shared.getUserCurrencyCode()
        var flightInfo: [JSONDictionary] = []
        
        guard let selectedFlightInfo = self.selectedOutboundFlight?.flightInfo else { return }
        
        for flight in selectedFlightInfo {
            let outboundFlightInfo = [
                "timeOfDeparture":  flight.timeOfDeparture,
                "timeOfArrival": flight.timeOfArrival,
                "dateOfDeparture": flight.dateOfDeparture,
                "dateOfArrival": flight.dateOfArrival,
                "departureLocation": flight.departureLocation,
                "arrivalLocation": flight.arrivalLocation,
                "departureTerminal": flight.departureTerminal,
                "arrivalTerminal": flight.arrivalTerminal,
                "operatingCompany": flight.operatingCompany,
                "marketingCompany": flight.marketingCompany,
                "flightNumber": flight.flightNumber,
                "electronicTicketing": flight.electronicTicketing
                ] as [String : Any?]
            
            flightInfo.append(outboundFlightInfo)
        }
        
        let searchDict = [
            "totalPassenger": self.passengerCount,
            "itinerary": itineraryArr,
            "flightInfo": flightInfo,
            "passenger": passengerArray,
            "currency": currency,
            "cabinClass": cabinClass.code,
            "flightType": flightType.value
            ] as [String : Any]
        
        self.searchDict = searchDict
        self.search()
    }
    
    override func showNextScreen(_ selectedFlight: FlightDetails) {
        let controller = ConfirmItineraryVC.instantiate(fromAppStoryboard: .flight)
        
        controller.inboundFlight = selectedFlight
        controller.outboundFlight = self.selectedOutboundFlight
        controller.cabinClass = self.cabinClass
        controller.param = param
        controller.destination = destination
        controller.origin = origin
        controller.departureDate = departureDate
        controller.returnDate = returnDate
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension InboundSearchResultVC {
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let firstFlight = self.originalSearchResult.first, let firstFlightAmount = firstFlight.amount, let lastFlight = self.originalSearchResult.last, let lastFlightAmount = lastFlight.amount else { return nil }

        header.delegate = self
        header.sortSegmentedControl.initialWidth = header.frame.width - 32
        
        let dateOfDeparture = Helpers.formattedDateFromString(dateString: firstFlight.flightInfo?.first?.dateOfDeparture ?? "", withFormat: "EEE, MMM d")
        let dateOfArrival = Helpers.formattedDateFromString(dateString: firstFlight.flightInfo?.last?.dateOfArrival ?? "", withFormat: "EEE, MMM d")
        header.flightDatesLabel.text = "\(dateOfDeparture) - \(dateOfArrival)"
        
        let cityName = origin?.city ?? ""
        let resultsTitle = NSMutableAttributedString(string: "Return", attributes: [NSAttributedString.Key.font : UIFont(name: "PTSans-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.appRed])
        resultsTitle.append(NSAttributedString(string: " to \(cityName)", attributes: [NSAttributedString.Key.font : UIFont(name: "PTSans-Regular", size: 20) ?? UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.defaultText]))
        
        header.cityNameLbl.attributedText = resultsTitle
        
        let results = nonStop ? self.filterByNonStopResults.count : self.originalSearchResult.count
        header.flightCountLbl.text = "\(results) results"
        
        let cheapestTitle = "\(CurrencyManager.shared.getUserCurrencySymbol())\(firstFlightAmount)"
        let shortestTitle = "\(CurrencyManager.shared.getUserCurrencySymbol())\(firstFlightAmount)"
        let stopsTitle = "\(CurrencyManager.shared.getUserCurrencySymbol())\(lastFlightAmount)"
        header.sortSegmentedControl.titles = "\(cheapestTitle),\(shortestTitle),\(stopsTitle)"
        
        header.sortSegmentedControl.selectedSegmentIndex = self.selectedSortIndex
        header.stopToggleSwitch.isOn = self.nonStop
        
        return header
    }
}
