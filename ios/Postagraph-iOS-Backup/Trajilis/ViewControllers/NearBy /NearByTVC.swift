//
//  NearByTVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 13/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import CoreLocation

final class NearByTVC: BaseTVC {

    var viewModel: NearByViewModel!
    let searchbarView = SearchView()
    var titleLabel: UILabel! = UILabel()

    var curentLoc:CLLocation?
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.largeTitleDisplayMode = .never
        tableView.register(UINib.init(nibName: TrendingTableViewCell.name, bundle: nil), forCellReuseIdentifier: TrendingTableViewCell.reuseIdentifier)
        checkLocation()
        configureNavBar()
        
        navigationController?.navigationBar.barTintColor = UIColor.appRed
        viewModel.reload = { [weak self] in
            guard let strongSelf = self else { return }
            strongSelf.hideSpinner()
            if strongSelf.didAnimate {
                strongSelf.tableView.reloadData()
            } else {
                strongSelf.animateTable()
            }
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }

    func configureNavBar() {
        let filterButton = UIBarButtonItem(image: UIImage.init(named: "nearby_filter"), style: .plain, target: self, action: #selector(filterTapped))
        navigationItem.rightBarButtonItem = filterButton
        let titleView = UIView(frame: .init(x: 0, y: 0, width: 200, height: 30))
        let locationIcon = UIImageView(image: UIImage.init(named: "nearby_location"))
        locationIcon.contentMode = .scaleAspectFit
        titleView.addSubview(locationIcon)

        locationIcon.translatesAutoresizingMaskIntoConstraints = false
        locationIcon.topAnchor.constraint(equalTo: titleView.topAnchor).isActive = true
        locationIcon.bottomAnchor.constraint(equalTo: titleView.bottomAnchor).isActive = true
        locationIcon.leadingAnchor.constraint(equalTo: titleView.leadingAnchor).isActive = true
        locationIcon.heightAnchor.constraint(equalToConstant: 30).isActive = true
        locationIcon.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        titleLabel.textColor = UIColor.white
        titleLabel.numberOfLines = 1
        titleView.addSubview(titleLabel)
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.trailingAnchor.constraint(equalTo: titleView.trailingAnchor).isActive = true
        titleLabel.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: locationIcon.trailingAnchor).isActive = true

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(onTitleViewTapped))
        tapGesture.numberOfTapsRequired = 1
        tapGesture.cancelsTouchesInView = false
        titleView.addGestureRecognizer(tapGesture)
        navigationItem.titleView = titleView

    }

    @objc private func filterTapped() {
     
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        alertController.view.tintColor = UIColor.black
        
        let option1 = UIAlertAction(title: "Filter by place type", style: .default) { (action:UIAlertAction) in
            let controller = FilterByPlaceTypeVC.instantiate(fromAppStoryboard: .nearby)
            controller.selectedPlaceType = self.viewModel.type
            
            controller.didSelectPlace = {[weak self] (placetype) in
                if let strngSelf = self {
                    strngSelf.viewModel.type = placetype
                    strngSelf.loadNewData(showHud:true)
                }
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        let option2 = UIAlertAction(title: "Filter by distance", style: .default) { (action:UIAlertAction) in
            let controller = FilterByDistanceVC.instantiate(fromAppStoryboard: .nearby)
                controller.selectedRadius = Helpers.meterToMile(mtr: self.viewModel.radius)
                controller.didSelectDistance = {[weak self](value) in
                    self?.viewModel.radius = Helpers.mileToMtr(mile: value)
                    self?.loadNewData(showHud:true)
                }
            self.navigationController?.pushViewController(controller, animated: true)
            
        }
        
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        
        alertController.addAction(option1)
        alertController.addAction(option2)
        
        alertController.addAction(cancel)
        
        self.present(alertController, animated: true, completion: nil)
        
    }
    
    @objc private func onTitleViewTapped() {

    }

    private func checkLocation() {
        Locator.shared.authorize()
        
        Locator.shared.locate { (result) in
            switch result {
            case .success(let location):
                if let loc = location.location {
                    self.viewModel.lat = "\(loc.coordinate.latitude)"
                    self.viewModel.lng = "\(loc.coordinate.longitude)"
                    self.curentLoc = loc
                }
                Locator.shared.reset()
                self.getPlace()
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
                MBProgressHUD.hide(for: self.view, animated: true)
                self.present(alertController, animated: true, completion: nil)
            }
        }
      
    }
    func getPlace() {
        Locator.shared.placemark { (placemark) in
            if let mark = placemark {
                self.viewModel.city = mark.locality ?? mark.subAdministrativeArea ?? mark.administrativeArea ?? ""
                self.titleLabel.text = "Nearby places in \(self.viewModel.city)"
                self.viewModel.getInterestingPlacesFromGoogle()
            } else {
                self.viewModel.getInterestingPlacesFromGoogle()
            }
        }
    }
}

extension NearByTVC {
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.viewModel.places.count
    }
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: TrendingTableViewCell.name) as! TrendingTableViewCell
        if self.viewModel.places.count > indexPath.row {
            let place = self.viewModel.places[indexPath.row]
            cell.configure(place: place,isNearBy: true)            
            if let crntLoc = self.curentLoc,let plcLoc = place.location {
                let distanceInMeters = plcLoc.distance(from: crntLoc)/1609.344
                cell.distanceLabel.text = "\(distanceInMeters.rounded(toPlaces: 2)) mile"
            }
            cell.numberOfPostLabel.isHidden = true
            cell.postCountContainerView.isHidden = true
            cell.viewButton.tag = indexPath.row
            cell.viewButton.addTarget(self, action: #selector(btnViewTapped(sender:)), for: .touchUpInside)
        }
        return cell
    }
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if self.viewModel.places.count - 2 == indexPath.row {
            if !self.viewModel.nextToken.isEmpty {
                self.viewModel.getInterestingPlacesFromGoogle()
            }
        }
    }
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 90
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        searchbarView.frame = CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        searchbarView.searchBar.delegate = self
        return searchbarView
    }
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let cell = tableView.cellForRow(at: indexPath) as? TrendingTableViewCell {
            cell.setSelected(false, animated: true)
            self.btnViewTapped(sender: cell.viewButton)
        }
        
    }
    func loadNewData(showHud:Bool = false) {
        if showHud {
            self.spinner(with: "Loading...", blockInteraction: true)
        }
        self.viewModel.places.removeAll()
        self.viewModel.nextToken = ""
        self.viewModel.searchText = self.searchbarView.searchBar.text ?? ""
        self.viewModel.getInterestingPlacesFromGoogle()
    }
    @IBAction func btnViewTapped(sender:UIButton) {
        if self.viewModel.places.count > sender.tag {
            let place = self.viewModel.places[sender.tag]
            let controller = PlaceDetailsViewController.instantiate(fromAppStoryboard: .nearby)
            controller.placeId = place.id
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
}

extension NearByTVC: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        self.loadNewData()
    }
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.loadNewData()
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        self.loadNewData()
    }
    override func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let currentY = scrollView.contentOffset.y
        let headerHeight = self.searchbarView.frame.size.height
        if (currentY > headerHeight) {
            self.searchbarView.searchBar.resignFirstResponder()
        }
    }
}
