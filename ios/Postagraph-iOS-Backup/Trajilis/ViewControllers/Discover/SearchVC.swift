//
//  SearchVC.swift
//  Trajilis
//
//  Created by Perfect Aduh on 17/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import SDWebImage
import CoreLocation

let kCityImages = ["Banjul",
    "Dakar",
    "Doha",
    "Lyon",
    "Marrakech",
    "Puerto Vallarta",
    "Ponta Delgada",
    "Zadar","Geneva"]

class SearchVC: BaseVC {
    
    private enum Section {
        case people, hashTag, places, feeds, deals
    }
    
    private var sections: [Section] = [.deals]
    //Outlets
    @IBOutlet var tableView: UITableView!
    @IBOutlet var headerView: UIView!
    @IBOutlet weak var searchComponentsContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet var headerViewsContainers: [UIView]!
    
    private var didAnimate: Bool = false
    private var firstSearchDidAnimate: Bool = false
    
    let viewModel = SearchViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.tableHeaderView = headerView
        searchTextField.delegate = self
        searchComponentsContainerView.set(borderWidth: 0.5, of: UIColor(hexString: "#e5e5e5"))
        searchComponentsContainerView.set(cornerRadius: 2)
        headerViewsContainers.forEach {
            $0.set(cornerRadius: 4)
        }
        viewModel.searchComplete = { [weak self] text in
            guard let self = self else {return}
            DispatchQueue.main.async {
                self.sections = []
                if let message = text {
                    if self.viewModel.cityFares?.exploreCities.count ?? 0 > 0 {
                        self.sections = [.deals]
                    }
                    self.showAlert(message: message)
                }else if self.viewModel.isSearching == true {
                    if self.viewModel.people.isEmpty == false {
                        self.sections.append(.people)
                    }
                    if self.viewModel.hashTags.isEmpty == false {
                        self.sections.append(.hashTag)
                    }
                    if self.viewModel.places.isEmpty == false {
                        self.sections.append(.places)
                    }
                    if self.viewModel.feeds.isEmpty == false {
                        self.sections.append(.feeds)
                    }
                }else {
                    self.sections = [.deals]
                }
                if self.viewModel.isSearching == true {
                    self.tableView.tableHeaderView = UIView(frame: .zero)
                }else {
                    self.tableView.tableHeaderView = self.headerView
                }
                if self.firstSearchDidAnimate {
                    self.tableView.reloadData()
//                    self.animateTable(tableView: self.tableView)
                } else {
                    self.firstSearchDidAnimate = true
                    self.animateTable(tableView: self.tableView)
                }
            }
        }

        viewModel.reload = { [weak self] in
            DispatchQueue.main.async {
                guard let self = self else {return}
                self.searchTextField.text = ""
                self.view.endEditing(true)
                if self.viewModel.cityFares?.exploreCities.count ?? 0 > 0 {
                    self.sections = [.deals]
                }
                if self.didAnimate {
                    self.tableView.reloadData()
                } else {
                    self.didAnimate = true
                    self.animateTable(tableView: self.tableView)
                }
            }
        }
        setTableViewHeaderHeight()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.getOfflineTrendingLocation()
        hideNavigationBar()
        checkLocation()
        tableView.reloadData()
//        viewModel.getTrendingLocations()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        viewModel.getTrendingLocations()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        setTableViewHeaderHeight()
    }
    
    private func setTableViewHeaderHeight() {
        guard let headerView = tableView.tableHeaderView else {return}
            
        headerView.translatesAutoresizingMaskIntoConstraints = false
        
        let headerWidth = headerView.bounds.size.width;
        let temporaryWidthConstraints = NSLayoutConstraint.constraints(withVisualFormat: "[headerView(width)]", options: NSLayoutConstraint.FormatOptions(rawValue: UInt(0)), metrics: ["width": headerWidth], views: ["headerView": headerView])
        
        headerView.addConstraints(temporaryWidthConstraints)
        
        headerView.setNeedsLayout()
        headerView.layoutIfNeeded()
        
        let headerSize = headerView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
        let height = headerSize.height
        var frame = headerView.frame
        
        frame.size.height = height
        headerView.frame = frame
        
        tableView.tableHeaderView = headerView
        
        headerView.removeConstraints(temporaryWidthConstraints)
        headerView.translatesAutoresizingMaskIntoConstraints = true
    }

    private func checkLocation() {
        Locator.shared.authorize()
        Locator.shared.locate { (result) in
            switch result {
            case .success(let location):
                if let loc = location.location {
                    self.viewModel.lat = "\(loc.coordinate.latitude)"
                    self.viewModel.lng = "\(loc.coordinate.longitude)"
                    print("self.viewModel.getTrendingLocations()")
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
            self.viewModel.getTrendingLocations()
        }
    }
    
    @IBAction private func goToFriendSearchVC() {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        let controller: PGExploreViewController = PGExploreViewController.instantiate(fromAppStoryboard: .search)
        controller.viewModel = ExploreViewModel()
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction private func goToNearbyVC() {
        let controller: NearbyViewController = Router.get()
        let model = NearByViewModel()
        controller.viewModel = model
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction private func goToTrendingVC() {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        
        let controller = TripsterListViewController.instantiate(fromAppStoryboard: .tripster)
        let viewModel = TripListViewModel()
        viewModel.viewMode = .Public
        viewModel.isOnMainTab = false
        controller.hidesBottomBarWhenPushed = true
        controller.viewModel = viewModel
        navigationController?.pushViewController(controller, animated: true)
    }

}

extension SearchVC: UITableViewDataSource, UITableViewDelegate {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        if !didAnimate {
            return 0
        }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch sections[section] {
        case .deals:
            return self.viewModel.cityFares?.exploreCities.count ?? 0
        case .people:
            return viewModel.people.count
        case .hashTag:
            return viewModel.hashTags.count
        case .feeds:
            return viewModel.feeds.count
        case .places:
            return viewModel.places.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        switch sections[indexPath.section] {
        case .deals:
            return getDealsTableViewCell(indexPath: indexPath)
        case .people:
            return getPeopleTableViewCell(indexPath: indexPath)
        case .feeds:
            return getFeedTableViewCell(indexPath: indexPath)
        case .places:
            return getPlacesTableViewCell(indexPath: indexPath)
        case .hashTag:
            return getHashTagTableViewCell(indexPath: indexPath)
        }
    }
    
    private func getFeedTableViewCell(indexPath: IndexPath) -> SearchPlacesTableViewCell {
        let cell = tableView.dequeue(SearchPlacesTableViewCell.self, for: indexPath)
        let feed = viewModel.feeds.item(at: indexPath.row)
        cell.placeImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
        cell.placeImageView.image = nil
        if let url = try? feed?.imageURL.asURL() {
            cell.placeImageView.sd_setImage(with: url)
        }
//        cell.viewCountStackView.isHidden = true
        cell.ratingView.isHidden = true
        cell.distanceLabel.isHidden = true
        cell.nameLabel.text = feed?.component
        cell.typeLabel.text = feed?.type
        cell.nameLabel.numberOfLines = 3
        return cell
    }
    
    private func getPlacesTableViewCell(indexPath: IndexPath) -> SearchPlacesTableViewCell {
        let cell = tableView.dequeue(SearchPlacesTableViewCell.self, for: indexPath)
        let place = viewModel.places.item(at: indexPath.row)
        let location = CLLocation(latitude: Double(viewModel.lat) ?? 0, longitude: Double(viewModel.lng) ?? 0)
        cell.place = place
        cell.location = location
        return cell
    }
    
    private func getHashTagTableViewCell(indexPath: IndexPath) -> SearchHashTagTableViewCell {
        let cell = tableView.dequeue(SearchHashTagTableViewCell.self, for: indexPath)
        let hashTag = viewModel.hashTags.item(at: indexPath.row)
        cell.hashTagLabel.text = hashTag?.tag
        return cell
    }
    
    private func getPeopleTableViewCell(indexPath: IndexPath) -> SearchPeopleTableViewCell {
        let cell = tableView.dequeue(SearchPeopleTableViewCell.self, for: indexPath)
        let people = viewModel.people.item(at: indexPath.row)
        cell.user = people
        return cell
    }
    
    private func getDealsTableViewCell(indexPath: IndexPath) -> SearchDealsTableViewCell {
        let cell = tableView.dequeue(SearchDealsTableViewCell.self, for: indexPath)
        
        let cityInfo = self.viewModel.cityFares?.exploreCities.item(at: indexPath.row)
        if let name = cityInfo?.name, kCityImages.contains(name) {
            cell.dealBgImageView.image = UIImage(named:name)
        } else {
            let placeHolderImage = UIImage(named: "paris")
            cell.dealBgImageView.image = placeHolderImage
            
            if let urlString = cityInfo?.city_photo,
                let url = URL(string: urlString) {
                cell.dealBgImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.dealBgImageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
            }
        }
        cell.cityNameLabel.text = cityInfo?.name
        if cityInfo?.name == "Geneva" { //// we need to display Vevey in place of Geneva
            cell.cityNameLabel.text = "Vevey"
        }else if cityInfo?.name == "Ponta Delgada" { //// we need to display Vevey in place of Geneva
            cell.cityNameLabel.text = "Sao Miguel"
        }
        
        cell.costLabel.text = nil
        if let amnt = cityInfo?.flightDetails?.totalAggAmount {
            let currency = self.getCurrencty(cityInfo: cityInfo)
            let curncySym = CurrencyManager.shared.getSymbol(forCurrency: currency)
            let curr = curncySym.isEmpty ? "$" : curncySym
            cell.costLabel.text = "\(curr)\(amnt.rounded(toPlaces: 2))"
        } else {
            if self.viewModel.cityFares?.nearestAirport.first == nil {
            } else {
                cell.costLabel.text = "--"
            }
        }
        return cell
    }
    
    func getCurrencty(cityInfo: PGExploreCity?) -> String {
        if let currency = cityInfo?.flightDetails?.flights.first?.currency {
            return currency
        } else {
            return  CurrencyManager.shared.getUserCurrencyCode()
        }
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        if tableView == exploreTableView {
        
        let cell = tableView.dequeue(SearchHeaderTableViewCell.self)
        switch sections[section] {
        case .deals:
            cell.headerLabel.text = "Latest Deals"
        case .feeds:
            cell.headerLabel.text = "Posts"
        case .people:
            cell.headerLabel.text = "People"
        case .hashTag:
            cell.headerLabel.text = "Hashtags"
        case .places:
            cell.headerLabel.text = "Places"
        }
        return cell.contentView
    }
    
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let cell = tableView.dequeueReusableCell(withIdentifier: "footerCell")
        return cell?.contentView
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch sections[indexPath.section] {
        case .deals:
            return 144
        case .feeds, .places:
            return 136
        case .hashTag:
            return 42
        case .people:
            return 60
        }
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 58
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        switch sections[section] {
        case .deals:
            return 32
        case .people:
            return 12
        case .feeds, .places:
            return 28
        case .hashTag:
            return 20
        }
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch sections[indexPath.section] {
        case .deals:
            if let cities = self.viewModel.cityFares?.exploreCities,cities.count > indexPath.row {
                let cityInfo = cities[indexPath.row]
                var destinationAirport = cityInfo.flightDetails?.flights.last?.arrivalAirport
                
                if destinationAirport == nil {
                    destinationAirport = self.getAirport(code: cityInfo.code)
                }
                
                let bookingTabIndex:Int = kTabIndex.Book.rawValue
                let originAirport = viewModel.cityFares?.nearestAirport.first
                
                if originAirport == nil || destinationAirport == nil {
                    checkLocation()
                }
                
                if let navVC = self.tabBarController?.viewControllers?[bookingTabIndex] as? UINavigationController {
                    
                    if let bookVC = navVC.viewControllers.first as? BookingViewController {
                        //bookVC.showFlights(origin: origin, destination: destinatoin)
                        bookVC.searchOrigin = originAirport
                        bookVC.searchDestination = destinationAirport
                        self.tabBarController?.selectedIndex = bookingTabIndex
                    }
                }
            }
        case .people:
            let user = viewModel.people[indexPath.row]
            let controller: ProfileViewController = Router.get()
            let vModel = ProfileViewModel(userId:  user.userId)
            controller.viewModel = vModel
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        case .places:
            let place = viewModel.places[indexPath.row]
            let controller = PlacesVC.instantiate(fromAppStoryboard: .places)
            controller.location = place.name
            controller.address = nil
            controller.rating = place.rating
            controller.viewModel = FeedViewModel(type: .places(id: place.id))
            //            controller.isUsersPlaces = false
            controller.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(controller, animated: true)
        case .feeds:
            let controller = FeedDetailVC.instantiate(fromAppStoryboard: .feed)
            controller.feedId = viewModel.feeds[indexPath.row].id
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        case .hashTag:
            let tag = viewModel.hashTags[indexPath.row]
            let controller = HashTagFeedVC.instantiate(fromAppStoryboard: .places)
            controller.hashTag = tag.tag
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    func getAirport(code:String ) -> Airport? {
        if code == "LAX" {
            let jsn:JSONDictionary = ["_id" : "5caf497315f280000f7104b8",
                                      "state_name" : "California",
                                      "country_name" : "United States",
                                      "country_code" : "US",
                                      "iata" : "LAX",
                                      "city_name" : "Los Angeles",
                                      "name" : "Los Angeles International Airport"]
            return Airport(json: jsn)
        } else if code == "DKR" {
            let jsn:JSONDictionary = [      "_id" : "5caf489915f280000f70f711",
                                            "state_name" : "",
                                            "country_name" : "Senegal",
                                            "country_code" : "SN",
                                            "iata" : "DKR",
                                            "city_name" : "Dakar",
                                            "name" : "Leopold Sedar Senghor International Airport"]
            return Airport(json: jsn)
        } else if code == "LAS" {
            let jsn:JSONDictionary = [
                "_id" : "5caf497315f280000f7104b5",
                "state_name" : "Nevada",
                "country_name" : "United States",
                "country_code" : "US",
                "iata" : "LAS",
                "city_name" : "Las Vegas",
                "name" : "McCarran International Airport"
            ]
            return Airport(json: jsn)
        }
        return nil
    }

}

extension SearchVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        search(text: newText)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        search(text: textField.text!)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        search(text: "")
        return true
    }
    
    private func search(text: String) {
        searchIconImageView.tintColor = text.isEmpty ? UIColor(hexString: "#e5e5e5") : UIColor(hexString: "#aeaeae")
        viewModel.isSearching = false
        if text.isEmpty {
            sections = []
            if viewModel.cityFares?.exploreCities.count ?? 0 > 0 {
                sections = [.deals]
            }
            tableView.tableHeaderView = headerView
            tableView.reloadData()
        }else {
            if !Helpers.isLoggedIn() {
                unauthenticatedBlock(canDismiss: true)
                return
            }
            viewModel.isSearching = true
            viewModel.searchTrending(searchParam: text)
        }
    }
    
}
