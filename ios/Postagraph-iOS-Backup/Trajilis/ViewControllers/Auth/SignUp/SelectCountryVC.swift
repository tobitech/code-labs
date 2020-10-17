//
//  SelectCountryVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 01/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

final class SelectCountryVC: UITableViewController {
    
    enum CountrySelectionType {
        case country
        case state
        case city        
    }
    
    weak var searchView:SearchView?
    var countries: [Country] = []
    var states = [State]()
    var cities = [City]()
    var countryId: String?
    var stateId: String?
    var filteredCountries = [Country]()
    var filteredStates = [State]()
    var didSelectCountry:((Country) -> ())?
    var didSelectState:((State) -> ())?
    var didSelectCity:((City) -> ())?
    
    var isSearching = false
    var type = CountrySelectionType.country
    
    override func viewDidLoad() {
        super.viewDidLoad()
        fetch()
        navigationController?.navigationBar.prefersLargeTitles = false
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        switch type {
        case .city:
            if let cntrId = self.countryId,!cntrId.isEmpty {
                title = "Search City"
            } else {
                title = Texts.selectCountry
                
            }
            
        case .country:
            title = Texts.selectCountry
        case .state:
            title = "Select State"
        }
        //title = Texts.selectCountry
        showNavigationBar()
    }
    func resetForCity() {
        switch type {
        case .city:
            if let cntrId = self.countryId,!cntrId.isEmpty {
                title = "Search City"
            } else {
                title = Texts.selectCountry
            }
        case .country:
            title = Texts.selectCountry
        case .state:
            title = "Select State"
        }
        self.searchView?.searchBar.text = nil
        self.cities.removeAll()
        self.tableView.reloadData()
        
    }
    
    private func fetch() {
        switch type {
        case .city:
            if self.countryId == nil || self.countryId!.isEmpty {
                fallthrough
            }
            break
        case .country:
            let spinnerActivity = MBProgressHUD.showCustomHud(to: self.view, animated: true)
            spinnerActivity.isUserInteractionEnabled = false
            getCountries()
        case .state:
            let spinnerActivity = MBProgressHUD.showCustomHud(to: self.view, animated: true)
            spinnerActivity.isUserInteractionEnabled = false
            getState()
        }
    }
    
    fileprivate func search(text: String) {
        switch type {
        case .country:
            filteredCountries.removeAll()
            filteredCountries = countries.filter({ (country) -> Bool in
                return country.name.lowercased().contains(text.lowercased())
            })
            tableView.reloadData()
        case .state:
            filteredStates.removeAll()
            filteredStates = states.filter({ (state) -> Bool in
                return state.name.lowercased().contains(text.lowercased())
            })
            tableView.reloadData()
        case .city:
            if self.countryId == nil || self.countryId!.isEmpty {
                filteredCountries.removeAll()
                filteredCountries = countries.filter({ (country) -> Bool in
                    return country.name.lowercased().contains(text.lowercased())
                })
                tableView.reloadData()
            } else {
                getCity(searchText: text)
            }
            
        }
        
    }
}

extension SelectCountryVC {
    
    fileprivate func getCountries() {
        APIController.makeRequest(request: .countries) { (response) in
            switch response {
            case .failure(_):
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                self.countries = data.compactMap{ Country.init(json: $0) }
            }
            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
    fileprivate func getState() {
        if let cntryId = self.countryId {
            APIController.makeRequest(request: .states(country: cntryId)) { (response) in
                switch response {
                case .failure(_):
                    self.showAlert(message: "Request failed.")
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else { return }
                    self.states = data.compactMap{ State.init(json: $0) }
                }
                self.tableView.reloadData()
                MBProgressHUD.hide(for: self.view, animated: true)
            }
        }
    }
    
    fileprivate func getCity(searchText: String) {
        guard let stateId = self.stateId,!searchText.isEmpty else {
            return
        }
        
        print("CountryID \(stateId)")
        APIController.makeRequest(request: .cities(state: stateId, searchText: searchText)) { (response) in
            switch response {
            case .failure(_):
                self.showAlert(message: "Request failed.")
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                self.cities = data.compactMap{ City.init(json: $0) }
            }
            self.tableView.reloadData()
            MBProgressHUD.hide(for: self.view, animated: true)
        }
    }
    
}

extension SelectCountryVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch type {
        case .country:
            return isSearching ? filteredCountries.count : countries.count
        case .state:
            return isSearching ? filteredStates.count : states.count
        case .city:
            if self.countryId == nil || self.countryId!.isEmpty {
                return isSearching ? filteredCountries.count : countries.count
            } else {
                return cities.count
            }
            
        }
        
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "CountryTableViewCell") as! CountryTableViewCell
        switch type {
        case .country:
            let country = isSearching ? filteredCountries[indexPath.row] : countries[indexPath.row]
            cell.configure(with: country)
        case .state:
             let state = isSearching ? filteredStates[indexPath.row] : states[indexPath.row]
            cell.configure(name: state.name)
        case .city:
            if self.countryId == nil || self.countryId!.isEmpty {
                let country = isSearching ? filteredCountries[indexPath.row] : countries[indexPath.row]
                cell.configure(with: country)
            } else {
                let city = cities[indexPath.row]
                cell.configure(name: city.name)
            }
            
        }
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        navigationController?.popViewController(animated: true)
        switch type {
        case .country:
            let country = isSearching ? filteredCountries[indexPath.row] : countries[indexPath.row]
            didSelectCountry?(country)
        case .state:
            let state = isSearching ? filteredStates[indexPath.row] : states[indexPath.row]
            didSelectState?(state)
        case .city:
            if self.countryId == nil || self.countryId!.isEmpty {
                let country = isSearching ? filteredCountries[indexPath.row] : countries[indexPath.row]
                self.countryId = country.id
                didSelectCountry?(country)
                self.resetForCity()
                return
            } else {
                let city = cities[indexPath.row]
                didSelectCity?(city)
            }
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchbarView = SearchView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 44))
        searchbarView.searchBar.delegate = self
        self.searchView = searchbarView
        return searchbarView
    }
}

extension SelectCountryVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = !searchText.isEmpty
        search(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
    }
}
