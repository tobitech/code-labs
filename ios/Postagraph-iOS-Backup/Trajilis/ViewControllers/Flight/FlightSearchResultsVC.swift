//
//  FlightSearchResultsVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 12/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

let shadeOfBlue = UIColor(hexString: "2389C6")

class FlightSearchResultsVC: BaseVC {
    
    @IBOutlet var tableView: UITableView!
    let header = FlightSearchHeaderCell.fromNib()
    
    var flightType: FlightType = .all
    var itineraryArr: [JSONDictionary] = []
    var passengerArray: [JSONDictionary] = []
    var passengerCount: Int = 0
    var destination: Airport?
    var origin: Airport?
    var param: JSONDictionary!
    var selectedAirlines = [Company]()
    var cabinClass = FlightClass.economy
    var stops = FlightType.all
    var time = "00:00"
    var loaderImageView: UIImageView!
    var travelersData: TravelersData?
    var tripType = FlightTrip.roundTrip
    var departureDate: Date?
    var returnDate: Date?
    
    var airlines = [Company]()
    
    var nonStop = false
    var selectedSortIndex = 0
    
    var outBoundFlightResponse: OutboundFlightData? {
        didSet {
            if let outboundFlights = outBoundFlightResponse?.data.outboundFlights {
                self.originalSearchResult = outboundFlights
                tableView.reloadData()
            }
        }
    }
    
    var originalSearchResult = [FlightDetails]() {
        didSet {
            filterByNonStopResults = originalSearchResult.filter{ $0.flightInfo?.count == 1 }
        }
    }
    var filterByNonStopResults = [FlightDetails]()
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.prefersLargeTitles = false
        self.showNavigationBar()
        
        self.travelersData = (self.navigationController as? BookingNavigationController)?.travelersData
        
        setupNavBar()
        setupViews()
        updateSearchParam()
    }
    
    fileprivate func setupViews() {
        tableView.register(FlightSearchResultCell.self)
        
        loaderImageView = UIImageView(frame: CGRect(x: view.frame.size.width/2, y: view.frame.size.height/2, width: 100, height: 100))
        loaderImageView.center = view.center
        loaderImageView.loadGif(name: "act1")
        view.addSubview(loaderImageView)
    }
    
    func setupNavBar() {
        let filterIcon = UIBarButtonItem(image: UIImage(named: "flightFilter-icon"), style: .plain, target: self, action: #selector(filterTapped(_:)))
        navigationItem.rightBarButtonItem = filterIcon
        
        navigationItem.title = "\(origin?.iata.uppercased() ?? "") - \(destination?.iata.uppercased() ?? "")"
    }
    
    func search() {
        originalSearchResult.removeAll()
        filterByNonStopResults.removeAll()
        airlines.removeAll()
        
        tableView.reloadData()
        loaderImageView.isHidden = false
        
        APIController.makeRequest(request: .getOutbound(param: param)) {[weak self] (response) in
            
            if let strngSelf = self {
                strngSelf.loaderImageView.isHidden = true
                switch response {
                case .failure(let error):
                    strngSelf.showAlert(message: error.desc)
                    strngSelf.navigationController?.popViewController(animated: true)
                case .success(let result):
                    do {
                        let outboundFlight = try JSONDecoder.decode(result.data, to: OutboundFlightData.self)
                        strngSelf.outBoundFlightResponse = outboundFlight
                        if let airlines = outboundFlight.data.airlines {
                            strngSelf.airlines = airlines
                        }
                    } catch {
                        print(error)
                        strngSelf.showAlert(message: strngSelf.getResponseError(data: result.data))
                    }
                }
            }
        }
    }
    
    func getResponseError(data: Data) -> String {
        do {
            let basicResponse = try JSONDecoder.decode(data, to: BasicResponse.self)
            return basicResponse.msg ?? "Something went wrong!"
        } catch {
            return error.localizedDescription
        }
    }
    
    @objc func filterTapped(_ sender: UIButton) {
        guard !airlines.isEmpty else { return }
        let controller = FilterVC.instantiate(fromAppStoryboard: .flight)
        controller.airlines = airlines
        controller.selectedAirline = selectedAirlines
        controller.cabinClass = cabinClass
        controller.stops = stops
        controller.selectedFilters = { [weak self] time, airlines, stops, fClass in
            if !time.isEmpty {
                self?.time = time
            }
            
            if !airlines.isEmpty {
                self?.selectedAirlines = airlines
            }
            
            self?.stops = stops
            self?.cabinClass = fClass
            self?.updateSearchParam()
        }
        navigationController?.pushViewController(controller, animated: true)
        
    }
    
    
    func updateSearchParam() {
        
        let onewayDict = [
            "departureLocation": origin!.iata,
            "arrivalLocation": destination!.iata,
            "departureDate": String(format:"%@ %@", format(date: departureDate!, dateFormat: "yyyy-MM-dd"), time),
            ] as [String : Any]
        var itineraryArr: [JSONDictionary] = []
        itineraryArr.append(onewayDict)
        
        if tripType == .roundTrip {
            let returnDict = [
                "departureLocation": destination!.iata,
                "arrivalLocation": origin!.iata,
                "departureDate": String(format:"%@ 00:00", format(date: returnDate!, dateFormat: "yyyy-MM-dd")),
                ] as [String : Any]
            itineraryArr.append(returnDict)
        }
        self.itineraryArr = itineraryArr
        
        var passengerArray: [JSONDictionary] = []
        if let adults = self.travelersData?.adults, adults.count > 0 {
            passengerArray.append(["type": "ADT", "count": adults.count])
        }
        if let children = self.travelersData?.children, children.count > 0 {
            passengerArray.append(["type": "CH", "count": children.count])
        }
        
        if let infantsOnLap = self.travelersData?.infantOnLap, infantsOnLap.count > 0 {
            passengerArray.append(["type": "INF", "count": infantsOnLap.count])
        }
        
        if let infantsOwnSeat = self.travelersData?.infantOwnSeat, infantsOwnSeat.count > 0 {
            passengerArray.append(["type": "INS", "count": infantsOwnSeat.count])
        }
        
        self.passengerArray = passengerArray
        let currency = CurrencyManager.shared.getUserCurrencyCode()
        
        self.passengerCount = self.travelersData?.totalSeats() ?? 0
        var searchDict = [
            "totalPassenger": self.passengerCount,
            "itinerary": itineraryArr,
            "passenger": passengerArray,
            "currency": currency,
            "cabinClass": self.cabinClass.code,
            "flightType": flightType.value
            ] as [String : Any]
        if !selectedAirlines.isEmpty {
            searchDict["airlines"] = selectedAirlines.map{ $0.iata }
        }
        
        param = searchDict
        search()
    }
    
    private func format(date: Date, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from:date)
    }
    
    func showNextScreen(_ selectedFlight: FlightDetails) {
        if tripType == .roundTrip {
            let controller = InboundSearchResultVC.instantiate(fromAppStoryboard: .flight)
            controller.selectedOutboundFlight = selectedFlight
            controller.outBoundFlight = outBoundFlightResponse
            
            controller.passengerArray = self.passengerArray
            controller.itineraryArr = self.itineraryArr
            controller.passengerCount = self.passengerCount
            controller.destination = destination
            controller.origin = origin
            controller.param = param
            controller.cabinClass = self.cabinClass
            controller.departureDate = departureDate
            controller.returnDate = returnDate
            controller.tripType = tripType
            
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = ConfirmItineraryVC.instantiate(fromAppStoryboard: .flight)
            controller.outboundFlight = selectedFlight
            controller.cabinClass = self.cabinClass
            controller.param = param
            controller.destination = destination
            controller.origin = origin
            controller.departureDate = departureDate
            controller.returnDate = returnDate
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
}

extension FlightSearchResultsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return nonStop ? self.filterByNonStopResults.count : self.originalSearchResult.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FlightSearchResultCell.self, for: indexPath)
        
        cell.flightDetails = nonStop ? self.filterByNonStopResults[indexPath.row] : self.originalSearchResult[indexPath.row]
        
        if indexPath.row == 0 {
            cell.cheapestLbl.isHidden = false
            switch selectedSortIndex {
            case 1:
                cell.cheapestLbl.text = "Shortest"
            case 2:
                cell.cheapestLbl.text = "Least Stops"
            default:
                cell.cheapestLbl.text = "Cheapest"
            }
        } else {
            cell.cheapestLbl.isHidden = true
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return  UITableView.automaticDimension
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 170
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        guard let firstFlight = self.originalSearchResult.first, let firstFlightAmount = firstFlight.amount, let lastFlight = self.originalSearchResult.last, let lastFlightAmount = lastFlight.amount else { return nil }
        header.delegate = self
        header.sortSegmentedControl.initialWidth = header.frame.width - 32
        
        let dateOfDeparture = Helpers.formattedDateFromString(dateString: firstFlight.flightInfo?.first?.dateOfDeparture ?? "", withFormat: "EEE, MMM d")
        let dateOfArrival = Helpers.formattedDateFromString(dateString: firstFlight.flightInfo?.last?.dateOfArrival ?? "", withFormat: "EEE, MMM d")
        header.flightDatesLabel.text = "\(dateOfDeparture) - \(dateOfArrival)"
        
        let cityName = destination?.city ?? ""
        let resultsTitle = NSMutableAttributedString(string: "Outbound", attributes: [NSAttributedString.Key.font : UIFont(name: "PTSans-Bold", size: 20) ?? UIFont.systemFont(ofSize: 20), NSAttributedString.Key.foregroundColor: UIColor.appRed])
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
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return self.originalSearchResult.count > 0 || self.filterByNonStopResults.count > 0 ? 176 : 0
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let selectedOutboundFlight: FlightDetails
        if nonStop {
            selectedOutboundFlight = self.filterByNonStopResults[indexPath.row]
        } else {
            selectedOutboundFlight = self.originalSearchResult[indexPath.row]
        }
        
        showNextScreen(selectedOutboundFlight)
    }
}

extension FlightSearchResultsVC: FlightSearchHeaderCellDelegate {
    func handleStopsToggleChanged(_ cell: FlightSearchHeaderCell, isOn: Bool) {
        self.flightType = isOn ? .nonStop : .all
        self.nonStop = isOn
        self.tableView.reloadData()
    }
    
    func sortArrayWithClosure(closure: ((FlightDetails, FlightDetails)) -> Bool, array: [FlightDetails]) -> [FlightDetails] {
        return array.sorted(by: closure)
    }
    
    func cheapestSort(items: (FlightDetails, FlightDetails)) -> Bool {
        guard let amount1 = items.0.amount?.toDouble(), let amount2 = items.1.amount?.toDouble() else { return false }
        return amount1 < amount2
    }
    
    func shortestSort(items: (FlightDetails, FlightDetails)) -> Bool {
        guard let d1 = items.0.durationInMinutes, let d2 = items.1.durationInMinutes else { return false }
        return d1 < d2
    }
    
    func stopsSort(items: (FlightDetails, FlightDetails)) -> Bool {
        guard let info1 = items.0.flightInfo, let info2 = items.1.flightInfo else { return false }
        return info1.count < info2.count
    }
    
    func handlesortingControlChanged(_ cell: FlightSearchHeaderCell, selectedIndex: Int) {
        self.selectedSortIndex = selectedIndex
        
        switch self.selectedSortIndex {
        case 0:
            if nonStop {
                filterByNonStopResults = sortArrayWithClosure(closure: cheapestSort, array: filterByNonStopResults)
            } else {
                originalSearchResult = sortArrayWithClosure(closure: cheapestSort, array: originalSearchResult)
            }
        case 1:
            if nonStop {
                filterByNonStopResults = sortArrayWithClosure(closure: shortestSort, array: filterByNonStopResults)
            } else {
                originalSearchResult = sortArrayWithClosure(closure: shortestSort, array: originalSearchResult)
            }
        case 2:
            if nonStop {
                filterByNonStopResults = sortArrayWithClosure(closure: stopsSort, array: filterByNonStopResults)
            } else {
                originalSearchResult = sortArrayWithClosure(closure: stopsSort, array: originalSearchResult)
            }
        default:
            break
        }
        
        self.tableView.reloadData()
    }
    
}

