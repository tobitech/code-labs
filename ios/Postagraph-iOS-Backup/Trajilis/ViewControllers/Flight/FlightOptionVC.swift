//
//  FlightOptionVC.swift
//  Trajilis
//
//  Created by Perfect Aduh on 09/07/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import PassKit

class FlightOptionVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var chooseOptionButton: UIButton!
    
    var inboundFlight: FlightDetails?
    var outboundFlight: FlightDetails?
    
    var fareRules = [PGFareRule]()
    var tripType = FlightTrip.roundTrip
    
    var destination: Airport?
    var origin: Airport?
    
    var travelersData: TravelersData?
    
    var isFlightBooking: Bool = true
    var hotelBooking: PGHotelBooking?
    
    var fareFamilyDataArray = [FareFamilyData]() {
        didSet {
            tableView.reloadData()
            self.selectedFareFamilyData = fareFamilyDataArray.first
            tableView.isHidden = false
            let indexPath = IndexPath(item: 0, section: 0)
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .top)
        }
    }
    
    var selectedFareFamilyData: FareFamilyData?
    
    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Flight Options"
        
        self.travelersData = (self.navigationController as? BookingNavigationController)?.travelersData
        
        setupViews()
        
        handlefareFamilyReq()
    }
    
    fileprivate func setupViews() {
        tableView.isHidden = true
        view.backgroundColor = .white
        tableView.register(FlightOptionsTVCell.self)
        tableView.register(FlightOptionsHeader.self)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.contentInset = .init(top: 0, left: 0, bottom: 84, right: 0)
        
        chooseOptionButton.makeCornerRadius(cornerRadius: 4.0)
        chooseOptionButton.addTarget(self, action: #selector(handleChooseOptionButton), for: .touchUpInside)
    }
    
    @objc func handleChooseOptionButton() {
        guard let selectedFareFamilyData = self.selectedFareFamilyData else {
            self.showAlert(message: "Please choose an option")
            return
        }
        
        let controller = TravelerInformationVC.instantiate(fromAppStoryboard: .flight)
        controller.fareFamilyName = selectedFareFamilyData.familyDescription?.familyName ?? ""
        controller.bookingClass = selectedFareFamilyData.details.first?.segments.first?.bookingClass ?? ""
        controller.upsellPrice = selectedFareFamilyData.price?.totalAmount
        
        controller.tripType = self.tripType
        controller.destination = destination
        controller.origin = origin
        controller.bestPricing = nil
        controller.fareRules = self.fareRules
        controller.inboundFlight = self.inboundFlight
        controller.outboundFlight = self.outboundFlight
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func handlefareFamilyReq() {
        self.spinner(with: "Getting Flight Options...", blockInteraction: true)
        let param = self.fareFamilyObject()
        
        guard JSONSerialization.isValidJSONObject(param) else {
            print(param)
            return
        }
        
        APIController.makeRequest(request: .flightUpsell(param: param)) {[weak self] (response) in
            guard let strongSelf = self else  { return }
            strongSelf.hideSpinner()
            switch response {
            case .success(let result ):
                do {
                    guard let json = try result.mapJSON() as? JSONDictionary, let _ = json["data"] as? [JSONDictionary] else {
                        if let res = try result.mapJSON() as? JSONDictionary, let msg = res["msg"] as? String,!msg.isEmpty {
                            strongSelf.showAlert(message: msg)
                        } else {
                            strongSelf.showAlert(message: kDefaultError)
                        }
                        return
                    }
                    let dict = FareFamilyResult.init(json: json)
                    let fareFamilyData = dict.data
                    strongSelf.fareFamilyDataArray = fareFamilyData
                } catch {
                     print(error)
                }
            case .failure(let error):
                strongSelf.showAlert(message: error.desc)
                strongSelf.navigationController?.popViewController(animated: true)
            }
        }
    }

    private func format(date: Date, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from:date)
    }
    
}

extension FlightOptionVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            if self.fareFamilyDataArray.count > 0 {
                return 1
            } else {
                return 0
            }
        default:
            return self.fareFamilyDataArray.count > 1 ? self.fareFamilyDataArray.count - 1 : 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        switch indexPath.section {
        case 0:
            let cell = tableView.dequeue(FlightOptionsTVCell.self, for: indexPath)
            if self.fareFamilyDataArray.count > 0 {
                cell.data = fareFamilyDataArray[0].familyDescription?.services
                cell.price = fareFamilyDataArray[0].price
                cell.titleLbl.text = fareFamilyDataArray[0].familyDescription?.description.capitalized
                return cell
            } else {
                return cell
            }
        default:
            let cell = tableView.dequeue(FlightOptionsTVCell.self, for: indexPath)
            if self.fareFamilyDataArray.count > 1,
                self.fareFamilyDataArray.count - 1 > indexPath.row {
                cell.data = self.fareFamilyDataArray[indexPath.row + 1].familyDescription?.services
                cell.price = self.fareFamilyDataArray[indexPath.row + 1].price
                cell.titleLbl.text = self.fareFamilyDataArray[indexPath.row + 1].familyDescription?.description.capitalized
                return cell
            } else {
                return cell
            }
        }
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
         return 400
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 300
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.selectedFareFamilyData = fareFamilyDataArray[indexPath.row]
        default:
            self.selectedFareFamilyData = fareFamilyDataArray[indexPath.row + 1]
        }
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
}



extension FlightOptionVC {
    
    fileprivate func fareFamilyObject() -> JSONDictionary {
        
        var itinerary: [JSONDictionary] = []
//        let flights = outgoing.flights
        var passengerArray: [JSONDictionary] = []
        if let count = self.travelersData?.adults.count, count > 0 {
            passengerArray.append(["type": "ADT", "count": count])
        }
        if let count = self.travelersData?.children.count, count > 0 {
            passengerArray.append(["type": "CH", "count": count])
        }
        
        if let count = self.travelersData?.infantOnLap.count, count > 0 {
            passengerArray.append(["type": "INF", "count": count])
        }
        if let count = self.travelersData?.infantOwnSeat.count, count > 0 {
            passengerArray.append(["type": "INF", "count": count])
        }
        
        guard let flightInfo = outboundFlight?.flightInfo else { return [:] }
        
        for outboundFlightInfo in flightInfo {
            let outboundDict: JSONDictionary = [
                "dateOfDeparture": outboundFlightInfo.dateOfDeparture,
                "timeOfDeparture": outboundFlightInfo.timeOfDeparture,
                "dateOfArrival": outboundFlightInfo.dateOfArrival,
                "timeOfArrival": outboundFlightInfo.timeOfArrival,
                "departureLocation": outboundFlightInfo.departureLocation,
                "departureTerminal": outboundFlightInfo.departureTerminal,
                "arrivalLocation": outboundFlightInfo.arrivalLocation,
                "arrivalTerminal": outboundFlightInfo.arrivalTerminal,
                "marketingCompany": outboundFlightInfo.marketingCompany,
                "operatingCompany": outboundFlightInfo.operatingCompany,
                "flightNumber": outboundFlightInfo.flightNumber,
                "groupNumber": "1",
                "bookingClass": outboundFlight?.bookingClass,
            ]
            itinerary.append(outboundDict)
        }
        
        // compose inbound information
        if let flightInfo = inboundFlight?.flightInfo {
            for inboundFlightInfo in flightInfo {
                let returnDict: JSONDictionary = [
                    "dateOfDeparture": inboundFlightInfo.dateOfDeparture,
                    "timeOfDeparture": inboundFlightInfo.timeOfDeparture,
                    "dateOfArrival": inboundFlightInfo.dateOfArrival,
                    "timeOfArrival": inboundFlightInfo.timeOfArrival,
                    "departureLocation": inboundFlightInfo.departureLocation,
                    "departureTerminal": inboundFlightInfo.departureTerminal,
                    "arrivalLocation": inboundFlightInfo.arrivalLocation,
                    "arrivalTerminal": inboundFlightInfo.arrivalTerminal,
                    "marketingCompany": inboundFlightInfo.marketingCompany,
                    "operatingCompany": inboundFlightInfo.operatingCompany,
                    "flightNumber": inboundFlightInfo.flightNumber,
                    "groupNumber": "1",
                    "bookingClass": outboundFlight?.bookingClass,
                ]
                itinerary.append(returnDict)
            }
        }
        
        let currency = CurrencyManager.shared.getUserCurrencyCode()
        return ["itinerary": itinerary, "currency": currency, "passengers": passengerArray]
    }
}
