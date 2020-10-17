//
//  PlaceSearchVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 14/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Alamofire
import CoreLocation

let kLocationRadius = 482.803 //160.934 // in meters
final class PlaceSearchVC: UITableViewController {

    var selected: ((Venue) -> Void)?

    var venues = [Venue]()
    var coordinates: CLLocationCoordinate2D?
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.navigationBar.prefersLargeTitles = false
        title = "Location"
        tableView.tableFooterView = UIView.init(frame: .zero)
        checkLocation()
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
                Locator.shared.reset()
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
        search(text: "")
    }

    @objc fileprivate func search(text: String) {
        var lng = "\(UserDefaults.standard.double(forKey: "longitude"))"
        var lat = "\(UserDefaults.standard.double(forKey: "latitude"))"
        
        if let ln = self.coordinates?.longitude,let lt = self.coordinates?.latitude {
            lng = "\(ln)"
            lat = "\(lt)"
        }
        var urlString = ""
        if text.isEmpty {
            urlString = String(format: "https://api.foursquare.com/v2/venues/search?ll=%@,%@&client_id=3P1KGZPYB5XETWEGOAS235WEZTGFTHOF11CB3AXM2YDVRI3N&client_secret=AB5UEOONXC1TGOGZPS5LDOFGUVF4ZAU21SF5BGQELQXMRBHF&categoryId=4d4b7105d754a06375d81259,4e67e38e036454776db1fb3a,4d4b7105d754a06378d81259,4d4b7105d754a06377d81259,4d4b7104d754a06370d81259,4d4b7105d754a06372d81259,4d4b7105d754a06373d81259,4d4b7105d754a06374d81259,4d4b7105d754a06376d81259,4d4b7105d754a06379d81259&v=20161304&radius=\(kLocationRadius)&limit=100",lat,lng)
        } else {
            urlString = String(format: "https://api.foursquare.com/v2/venues/search?ll=%@,%@&categoryId=4bf58dd8d48988d124941735,4d4b7105d754a06375d81259,4d4b7105d754a06379d81259,4d4b7105d754a06378d81259,4e67e38e036454776db1fb3a,4d4b7105d754a06377d81259,4d4b7104d754a06370d81259,4d4b7105d754a06372d81259,4d4b7105d754a06373d81259,4d4b7105d754a06374d81259,4d4b7105d754a06376d81259&client_id=3P1KGZPYB5XETWEGOAS235WEZTGFTHOF11CB3AXM2YDVRI3N&client_secret=AB5UEOONXC1TGOGZPS5LDOFGUVF4ZAU21SF5BGQELQXMRBHF&v=20161006&query=%@&radius=\(kLocationRadius)&limit=100",lat,lng,text.encoded() )
        }

        let escapedString = urlString.replacingOccurrences(of: "|", with: ",")
        Alamofire.request(escapedString).validate().responseJSON { (response) in
            DispatchQueue.main.async {
                switch response.result {
                case .success(let value):
                    guard let json = (value as! JSONDictionary)["response"] as? JSONDictionary,
                        let data = json["venues"] as? [JSONDictionary] else { return }
                    self.venues = data.compactMap{ Venue.init(json: $0) }
                    self.tableView.reloadData()
                case .failure(let e):
                    self.showAlert(message: e.localizedDescription)
                }
            }

        }
    }

}


extension PlaceSearchVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return venues.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AirportSelectionTableViewCell.kIdentifier) as! AirportSelectionTableViewCell
        let venue = venues[indexPath.row]
        cell.configure(venue: venue)
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let venue = venues[indexPath.row]
        selected?(venue)
        navigationController?.popViewController(animated: true)
    }

    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchbarView = SearchView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 44))
        searchbarView.searchBar.delegate = self
        return searchbarView
    }
}

extension PlaceSearchVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: searchText)
        perform(#selector(search), with: searchText, afterDelay: 0.75)
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
