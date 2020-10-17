//
//  PassengerListVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 28/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class PassengerListVC: BaseVC {
    
    @IBOutlet var tableView: UITableView!
    var adultCount = 0
    var childCount = 0
    var infantCount = 0

    var outgoing: FlightSearchResult!
    var incoming: FlightSearchResult?
    var param: JSONDictionary!
    var departureDate: Date?

    var returnDate: Date?
    var destination: Airport?
    var origin: Airport?
    var bestPricing: BestPricing?

    var passengers = [Passenger]()

    var child = [Passenger]()
    var infant = [Passenger]()
    var adult = [Passenger]()

    var bookingItinerary = [JSONDictionary]()
    var passengerArray = [JSONDictionary]()

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Traveler Information"
        print("total -- \(outgoing.totalAggAmount)")
        
        tableView.tableFooterView = UIView(frame: .zero)
    }

    fileprivate func updateDataSource() {
        child.removeAll()
        infant.removeAll()
        adult.removeAll()
        for passenger in passengers {
            if passenger.type == .adult {
                adult.append(passenger)
            }
            if passenger.type == .child {
                child.append(passenger)
            }
            if passenger.type == .infant {
                infant.append(passenger)
            }
        }
        tableView.reloadData()
    }

    fileprivate func add(passenger: Passenger? = nil, type: PassengerType) {
        let controller = AddPassengerVC.instantiate(fromAppStoryboard: .flight)
        controller.didEnterPassenger = { [weak self] passenger in
            self?.passengers.append(passenger)
            self?.updateDataSource()
        }
        controller.didDismiss = { [weak self] in
            self?.dim(.out, speed: 0)
        }
        controller.passenger = passenger
        controller.type = type
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = .overFullScreen
        controller.providesPresentationContextTransitionStyle = true
        self.dim(.in, color: UIColor.black, alpha: 0.3, speed: 0.5)
        present(controller, animated: true, completion: nil)
    }

    fileprivate func delete(passenger: Passenger) {
        for (index, pass) in passengers.enumerated() {
            if pass.firstname == passenger.firstname && pass.dob == passenger.dob {
                passengers.remove(at: index)
                return
            }
        }
    }

    @IBAction func continueTapped(_ sender: Any) {
        guard !passengers.isEmpty else {
            showAlert(message: "Please enter passenger detail")
            return
        }
        
        spinner(with: "Check bookability...")
        checkBookability { (success, msg) in
            DispatchQueue.main.async {
                self.hideSpinner()
                if !success {
                    self.showAlert(message: msg ?? "Unable to book flight")
                } else {
                    print(success)
                    self.goToPayment()
                }
            }

        }
    }

    private func goToPayment() {
        let controller = PaymentVC.instantiate(fromAppStoryboard: .flight)
        controller.bookingItinerary = bookingItinerary
        controller.passengerArray = passengerArray
        controller.bestPricing = bestPricing
        navigationController?.pushViewController(controller, animated: true)
    }

    fileprivate func bookabilityObject(outgoing: FlightSearchResult, isReturn: Bool = false) -> JSONDictionary {
        var itinerary: JSONDictionary = [
            "origin": isReturn ? destination!.iata : origin!.iata,
            "destination": isReturn ? origin!.iata : destination!.iata
        ]
        let flights = outgoing.flights
        let adult = outgoing.details.first(where: { $0.passengerType == "ADT" })?.totalPassenger ?? 0
        let child = outgoing.details.first(where: { $0.passengerType == "CHD" })?.totalPassenger ?? 0
        let passenger = adult + child
        var segment = [JSONDictionary]()
        for flight in flights {
            let bestFare = bestPricing?.flights.first(where: { $0.flightNumber == flight.flightNumber })
            let dict: JSONDictionary = [
                "dateOfDeparture": flight.dateOfDeparture,
                "timeOfDeparture": flight.timeOfDeparture,
                "dateOfArrival": flight.dateOfArrival,
                "timeOfArrival": flight.timeOfArrival,
                "departureLocation": flight.departureLocation,
                "departureTerminal": flight.departureTerminal ?? "",
                "arrivalLocation": flight.arrivalLocation,
                "arrivalTerminal": flight.arrivalTerminal ?? "",
                "marketingCompany": flight.marketingCompany?.designator ?? "",
                "operatingCompany": flight.operatingCompany?.designator ?? "", 
                "flightNumber": flight.flightNumber,
                "groupNumber": "1",
                "totalPassenger": passenger,
                "bookingClass": bestFare?.bookingClass?.id ?? outgoing.details.first?.rbd ?? "",
            ]
            segment.append(dict)
        }
        itinerary["segment"] = segment
        return itinerary
    }

    fileprivate func checkBookability(completion: @escaping ((Bool, String?) -> Void)) {
        var itineraryArray = [JSONDictionary]()
        let outgoingItinerary = bookabilityObject(outgoing: outgoing)
        itineraryArray.append(outgoingItinerary)
        if let incoming = self.incoming {
            let incomingItinerary = bookabilityObject(outgoing: incoming)
            itineraryArray.append(incomingItinerary)
        }
        let pass = passengers.compactMap{ $0.toJSON() }
        let param: JSONDictionary = [
            "itinerary": itineraryArray,
            "passenger": pass
        ]
        self.bookingItinerary = itineraryArray
        self.passengerArray = pass
        APIController.makeRequest(request: .bookability(param: param)) { (response) in
            switch response {
            case .failure(_):
                completion(false, "This itinerary can not be booked at the moment")
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let success = json?["status"] as? Bool else {
                        completion(false, "This itinerary can not be booked at the moment")
                        return
                }
                let msg: String? = success ? nil : json?["data"] as? String
                completion(success, msg)
            }
        }
    }
}

extension PassengerListVC: UITableViewDelegate, UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        return 3
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return adult.count
        case 1:
            return child.count
        case 2:
            return infant.count
        default:
            return 0
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PassengerListTableViewCell") as! PassengerListTableViewCell
        var passenger: Passenger?
        switch indexPath.section {
        case 0:
            passenger = adult[indexPath.row]
            cell.nameLabel.text = passenger!.firstname + " " + passenger!.lastname
        case 1:
            passenger = child[indexPath.row]
            cell.nameLabel.text = passenger!.firstname + " " + passenger!.lastname
        case 2:
            passenger = infant[indexPath.row]
            cell.nameLabel.text = passenger!.firstname + " " + passenger!.lastname
        default:
            return UITableViewCell()
        }
        if let pass = passenger {
            cell.editBlock = {
                switch pass.type {
                case .adult:
                    self.adult.remove(at: indexPath.row)
                case .child:
                    self.child.remove(at: indexPath.row)
                case .infant, .infantWithSeat:
                    self.infant.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.delete(passenger: pass)
                self.add(passenger: pass, type: pass.type)
            }
            cell.deleteBlock = {
                switch pass.type {
                case .adult:
                    self.adult.remove(at: indexPath.row)
                case .child:
                    self.child.remove(at: indexPath.row)
                case .infant, .infantWithSeat:
                    self.infant.remove(at: indexPath.row)
                }
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.delete(passenger: pass)
            }
        }

        return cell
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PassengerListSectionHeaderTableViewCell") as! PassengerListSectionHeaderTableViewCell
        var titleText = ""
        var countText = ""
        switch section {
        case 0:
            if adultCount == 0 {
                return nil
            } else {
                titleText = "Select Adult"
                countText = "\(adult.count) adult added"
            }
        case 1:
            if childCount == 0 {
                return nil
            } else {
                titleText = "Select Child"
                countText = "\(child.count) adult added"
            }
        case 2:
            if infantCount == 0 {
                return nil
            } else {
                titleText = "Select Infant"
                countText = "\(infant.count) adult added"
            }
        default:
            break
        }
        cell.titleLabel.text = titleText
        cell.countLabel.text = countText
        return cell
    }

    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PassengerListSectionFooterTableViewCell") as! PassengerListSectionFooterTableViewCell
        cell.addButton.tag = section
        cell.addButton.addTarget(self, action: #selector(addPassenger(_:)), for: .touchUpInside)
        return cell.contentView
    }

    @objc func addPassenger(_ sender: UIButton) {
        switch sender.tag {
        case 0:
            self.add(type: .adult)
        case 1:
            self.add(type: .child)
        case 2:
            self.add(type: .infant)
        default:
            break
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return adultCount == 0 || adultCount == adult.count ? 0 : 44
        case 1:
           return childCount == 0 || childCount == child.count ? 0 : 44
        case 2:
            return infantCount == 0 || infantCount == infant.count ? 0 : 44
        default:
            break
        }
        return 0
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        switch section {
        case 0:
            return adultCount == 0 ? 0 : 44
        case 1:
            return childCount == 0 ? 0 : 44
        case 2:
            return infantCount == 0 ? 0 : 44
        default:
            break
        }
        return 0
    }

}

struct Passenger {
    let firstname: String
    let lastname: String
    let gender: String
    let dob: String
    let isWithInfant: Bool
    let type: PassengerType
    let infant: Infant?

    func toJSON() -> JSONDictionary {
        var param = [
            "firstName": firstname,
            "lastName": lastname,
            "dateOfBirth": dob,
            "travellerType": type.value,
            "withInfant": isWithInfant
            ] as [String : Any]

        if let infant = self.infant {
            param["infant"] = infant.toJSON()
        }
        return param
    }
}

struct Infant {
    let firstname: String
    let lastname: String
    let dob: String

    func toJSON() -> JSONDictionary {
        return [
            "firstName": firstname,
            "lastName": lastname,
            "dateOfBirth": dob,
        ]
    }

}

enum PassengerType: Int, Codable {
    case adult = 0
    case child = 1
    case infant = 2
    case infantWithSeat = 3

    var value: String {
        switch self {
        case .child:
            return "CHD"
        case .adult:
            return "ADT"
        case .infant:
            return "INF"
        case .infantWithSeat:
            return "INS"
        }
    }
    
    static func getValue(type:String) -> String {
        switch type {
        case kPaxType.adult.rawValue:
            return "Adult"
        case kPaxType.child.rawValue:
            return "Child"
        case kPaxType.infant.rawValue:
            return "infant"
        default:
            return "Adult"
        }
    }
}
enum kPaxType:String {
    case adult = "ADT"
    case child = "CH"
    case infant = "INF"
}
