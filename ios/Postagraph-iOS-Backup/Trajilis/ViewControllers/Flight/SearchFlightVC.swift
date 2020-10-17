//
//  SearchFlightVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 05/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class SearchFlightVC: UIViewController {

    static let TRIP_TYPE_KEY = "trip_type"
    static let FLIGHT_CLASS_KEY = "flight_class"
    static let INFANT_COUNT_KEY = "infant_count"
    static let CHILD_COUNT_KEY = "child_count"
    static let ADULT_COUNT_KEY = "adult_count"
    static let DEPART_DATE_KEY = "depart_date"
    static let RETURN_DATE_KEY = "return_date"
    
    @IBOutlet var travelerCountLbl: UILabel!
    @IBOutlet var travelerContainerView: UIView!
    @IBOutlet var flightHeaderContainerView: UIView!
    @IBOutlet var editTravelerBtn: UIButton!
    
    var travelersData: TravelersData?
    
    let viewModel = FlightViewModel()
    let bookFlightHeader = BookFlightHeader.fromNib()

    var isSelectingOutbound: Bool = true
    var pushSearchResult:((FlightSearchResultsVC) -> Void)?

    var departureDate: Date?

    var returnDate: Date?

    var destination: Airport?
    
    var origin: Airport?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.travelersData = TravelersData(adults: [TravelersData.newAdult()], children: [], infantOwnSeat: [], infantOnLap: [])
        
        navigationItem.title = "Search Flights"
        
        editTravelerBtn.addTarget(self, action: #selector(handleEditTravelerBtn), for: .touchUpInside)
        flightHeaderContainerView.addSubview(bookFlightHeader)
        bookFlightHeader.fillSuperview(padding: .init(top: 0, left: -16, bottom: 0, right: -16))
        
        bookFlightHeader.outboundBtn.addTarget(self, action: #selector(showChooseAirports), for: .touchUpInside)
        bookFlightHeader.inboundBtn.addTarget(self, action: #selector(showChooseAirports), for: .touchUpInside)
        
        viewModel.airportSearchByLocation()
        viewModel.airportSearchComplete = { msg, airport in
            if let msg = msg {
                self.showAlert(message: msg)
            }
            if let airport = airport {
                self.bookFlightHeader.outboundTxtField.placeholder = ""
                self.bookFlightHeader.outboundTxtField.text = "\(airport.city)(\(airport.iata))"
                self.origin = airport
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    func showFlights(origin: Airport, destination: Airport) {
        self.origin = origin
        self.destination = destination
    }
    
    @objc func handleEditTravelerBtn() {
        
        let controller = EditTravellerVC.instantiate(fromAppStoryboard: .flight)
        controller.editTravlerDelegate = self
        controller.travelersData = self.travelersData
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = .overFullScreen
        self.present(controller, animated: true, completion: nil)
    }
    
    @objc func showChooseAirports() {
        let controller = ChooseAirportsVC.instantiate(fromAppStoryboard: .flight)
        controller.departureAirport = self.origin
        navigationController?.pushViewController(controller, animated: true)
    }

    private func updateLabelColor(label: UILabel) {
        guard let adultCount = label.text, let count = Int(adultCount) else { return }
        if count > 0 {
            label.textColor = UIColor.appRed
        } else {
            label.textColor = UIColor.init(hexString: "#CF1D20").withAlphaComponent(0.3)
        }
    }

    private func format(date: Date, dateFormat: String) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = dateFormat
        return formatter.string(from:date)
    }
    
    private func selectClassType(button: UIButton, isSelected: Bool) {
        button.isSelected = isSelected
    }
    
    private func select(button: TrajilisButton, isSelected: Bool) {
        button.setGradient = isSelected
        button.setTitleColor(isSelected ? UIColor.white : UIColor.appBlack, for: .normal)
        if(!isSelected) {
            button.borderColor = .clear
        } else {
            button.borderColor = .appRed
        }
    }

}

extension SearchFlightVC: EditTravellerDelegate {
    
    func didFinishPickingTravellers(data: TravelersData) {
        
        self.travelersData = data
        (self.navigationController as? BookingNavigationController)?.travelersData = self.travelersData
        
        guard let totalCount = self.travelersData?.total() else { return }
        if totalCount <= 1 {
            self.travelerCountLbl.text = "\(totalCount) traveller"
        } else {
            self.travelerCountLbl.text = "\(totalCount) travellers"
        }
    }
}
