//
//  CurrentTripsVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class CurrentTripsVC: BaseVC {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var noTripView: UIView!

    var trips = [Trip]()

    var selected:((Trip) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        getCurrentTrips()
        navigationItem.title = "Trips List"
    }

    private func getCurrentTrips() {
        spinner()
        let timestamp = Date().timeIntervalSince1970
        let timeStampStr : String! = String(format:"%.0f", timestamp)
        let userId = UserDefaults.standard.string(forKey: USERID)!
        let param: JSONDictionary = [
            "current_date": timeStampStr,
            "user_id": userId
        ]
        APIController.makeRequest(request: .getCurrentTrips(param: param)) { (response) in
            DispatchQueue.main.async {
                self.hideSpinner()
                switch response {
                case .failure(let e):
                   self.showAlert(message: e.desc)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else { return }
                    if data.isEmpty {
                        self.tableView.isHidden = true
                        self.noTripView.isHidden = false
                    }
                    self.trips = data.compactMap{ Trip.init(json: $0) }
                    self.tableView.reloadData()
                }
            }
        }
    }

    private func formatDate(timestamp: String) -> String {
        guard let double = Double(timestamp) else { return "" }
        let date = Date(timeIntervalSince1970: double)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "E, MMM d"
        return dateFormatter.string(from: date)
    }
}

extension CurrentTripsVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return trips.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CurrentTripCell")
        let trip = trips[indexPath.row]
        cell?.textLabel?.text = trip.tripName
        cell?.detailTextLabel?.text = String(format:"%@ to %@",formatDate(timestamp: trip.startDate), formatDate(timestamp: trip.endDate))
        return cell!
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        selected?(trips[indexPath.row])
        navigationController?.popViewController(animated: true)
    }
    

}
