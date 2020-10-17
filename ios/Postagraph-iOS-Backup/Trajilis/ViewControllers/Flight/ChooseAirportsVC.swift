//
//  ChooseAirportsVC.swift
//  Trajilis
//
//  Created by Perfect Aduh on 29/08/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class ChooseAirportsVC: UITableViewController {
    
    var airports = [Airport]()
    
    var isSelectingOutbound: Bool = false
    
    var departureAirport: Airport?
    var returnAirport: Airport?
    
    let flightSearchHeader = BookFlightHeader.fromNib()
    
    // MARK: - View Controller Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        title = "Choose Airports"
        tableView.tableFooterView = UIView.init(frame: .zero)
        
        flightSearchHeader.outboundTxtField.addTarget(self, action: #selector(handleSearch(textField:)), for: .editingChanged)
        flightSearchHeader.inboundTxtField.addTarget(self, action: #selector(self.handleSearch(textField:)), for: UIControl.Event.editingChanged)
        
        if let airport = self.departureAirport {
            self.flightSearchHeader.outboundTxtField.placeholder = ""
            self.flightSearchHeader.outboundTxtField.text = airport.city + " " + "(\(airport.iata))"
        } else {
            checkLocation()
        }
    }
    
    private func checkLocation() {
        Locator.shared.authorize()
        Locator.shared.locate { (result) in
            switch result {
            case .success(let location):
                if let loc = location.location {
                    UserDefaults.standard.set(loc.coordinate.latitude, forKey: "latitude")
                    UserDefaults.standard.set(loc.coordinate.longitude, forKey: "longitude")
                }
                
                self.searchWithLocation()
            case .failure(_):
                let alertController = UIAlertController(title: "Error", message: "Enable Location permissions in settings", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                }
                alertController.addAction(settingsAction)
                // If user cancels, do nothing, next time Pick Video is called, they will be asked again to give permission
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                // Run GUI stuff on main thread
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @objc fileprivate func handleSearch(textField: UITextField) {
        if textField == flightSearchHeader.outboundTxtField {
            isSelectingOutbound = true
            if textField.text?.count ?? 0 > 0 {
                self.flightSearchHeader.outboundTxtField.placeholder = ""
            } else {
                self.flightSearchHeader.outboundTxtField.placeholder = "Where from?"
            }
        } else {
            isSelectingOutbound = false
            if textField.text?.count ?? 0 > 0 {
                self.flightSearchHeader.inboundTxtField.placeholder = ""
                self.flightSearchHeader.inboundTxtField.selectedTitle = ""
            } else {
                self.flightSearchHeader.inboundTxtField.placeholder = "Where to fly to?"
            }
        }
        
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(searchWithText), object: nil)
        perform(#selector(searchWithText), with: nil, afterDelay: 0.5)
    }
    
    fileprivate func searchWithLocation() {
        
        let lng = "\(UserDefaults.standard.double(forKey: "longitude"))"
        let lat = "\(UserDefaults.standard.double(forKey: "latitude"))"
        guard lat != "0", lng != "0" else { return }
        
        APIController.makeRequest(request: .airportByLatLong(lat: "\(lat)", lng: "\(lng)")) { (response) in
            switch response {
            case .failure(let error):
                self.showAlert(message: error.desc)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary, let data = json?["data"]  as? [JSONDictionary] else { return }
                self.airports = data.compactMap{ Airport.init(json: $0) }
                self.departureAirport = self.airports[0]
                self.flightSearchHeader.outboundTxtField.text = self.airports[0].city + " " + "(\(self.airports[0].iata))"
                self.tableView.reloadData()
            }
        }
    }
    
    @objc fileprivate func searchWithText() {
        guard let term = isSelectingOutbound ? flightSearchHeader.outboundTxtField.text : flightSearchHeader.inboundTxtField.text, term.count > 0 else {
            if isSelectingOutbound {
                departureAirport = nil
            } else {
                returnAirport = nil
            }
            return
        }
        
        APIController.makeRequest(request: .airportSearch(searchText: term)) { (response) in
            switch response {
            case .failure(let error):
                self.showAlert(message: error.desc)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary, let data = json?["data"]  as? [JSONDictionary] else { return }
                self.airports = data.compactMap{ Airport.init(json: $0) }
                self.tableView.reloadData()
            }
        }
    }
    
    fileprivate func selectDates() {
        
        guard let origin = self.departureAirport, let destination = self.returnAirport else {
            return
        }
        
        guard origin.iata != destination.iata else {
            self.showAlert(message: "Please select different origin and destination");
            return
        }
        
        let controller = FlightSelectDateVC.instantiate(fromAppStoryboard: .flight)
        controller.tripType = .roundTrip
        
        controller.origin = self.departureAirport
        controller.destination = self.returnAirport
        
        navigationController?.pushViewController(controller, animated: true)
    }
    
}


extension ChooseAirportsVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return airports.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AirportSelectionTableViewCell.kIdentifier) as! AirportSelectionTableViewCell
        if indexPath.row < airports.count {
            let airport = airports[indexPath.row]
            cell.configure(airport: airport)
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let airport = airports[indexPath.row]
        if isSelectingOutbound {
            self.departureAirport = airport
            self.flightSearchHeader.outboundTxtField.placeholder = ""
            self.flightSearchHeader.outboundTxtField.text = airport.city + " " + "(\(airport.iata))"
            selectDates()
        } else {
            self.returnAirport = airport
            self.flightSearchHeader.inboundTxtField.placeholder = ""
            self.flightSearchHeader.inboundTxtField.text = airport.city + " " + "(\(airport.iata))"
            selectDates()
        }
        
        airports.removeAll()
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 160
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        flightSearchHeader.inboundBtn.isUserInteractionEnabled = false
        flightSearchHeader.outboundBtn.isUserInteractionEnabled = false
        return flightSearchHeader
    }
}
