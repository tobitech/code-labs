//
//  NearByViewController.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/27/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import CoreLocation
import SDWebImage

class NearbyViewController: BaseVC {
    
    var viewModel: NearByViewModel!
    private var didAnimate = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchComponentsContainerView: UIView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var searchIconImageView: UIImageView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkLocation()
        tableView.delegate = self
        tableView.dataSource = self
        searchTextField.delegate = self
        searchComponentsContainerView.set(borderWidth: 0.5, of: UIColor(hexString: "#e5e5e5"))
        searchComponentsContainerView.set(cornerRadius: 2)
        
        viewModel.reload = { [weak self] in
            guard let self = self else { return }
            self.hideSpinner()
            if self.didAnimate {
                self.tableView.reloadData()
            } else {
                self.didAnimate = true
                self.animateTable(tableView: self.tableView)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
        navigationController?.navigationBar.shadowImage = UIColor.white.image()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        UINavigationBar.setWhiteAppearance()
    }
    
    private func getPlace() {
        Locator.shared.placemark { (placemark) in
            if let mark = placemark {
                self.viewModel.city = mark.locality ?? mark.subAdministrativeArea ?? mark.administrativeArea ?? ""
                self.navigationItem.title = "Nearby places in \(self.viewModel.city)"
                self.viewModel.getInterestingPlacesFromGoogle()
            } else {
                self.viewModel.getInterestingPlacesFromGoogle()
            }
        }
    }
    
    
    
    private func checkLocation() {
        Locator.shared.authorize()
        
        Locator.shared.locate { (result) in
            switch result {
            case .success(let location):
                if let loc = location.location {
                    self.viewModel.lat = "\(loc.coordinate.latitude)"
                    self.viewModel.lng = "\(loc.coordinate.longitude)"
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
    
    @IBAction func filterTapped(_ sender: Any) {
        let controller = storyboard?.instantiateViewController(withIdentifier: "NearbyFilterViewController") as! NearbyFilterViewController
        controller.selectedDistance = Helpers.meterToMile(mtr: viewModel.radius)
        controller.selectedPlaceType = viewModel.type
        controller.onDistanceSet = { [weak self] distance in
            self?.viewModel.radius = Helpers.mileToMtr(mile: distance)
            self?.viewModel.getInterestingPlacesFromGoogle(new: true)
        }
        
        controller.ondSelectPlace = { [weak self] place in
            self?.viewModel.type = place
            self?.viewModel.getInterestingPlacesFromGoogle(new: true)
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension NearbyViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.places.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(SearchPlacesTableViewCell.self, for: indexPath)
        cell.contentView.elevate(2)
        let place = viewModel.places.item(at: indexPath.row)
        let location = CLLocation(latitude: Double(viewModel.lat) ?? 0, longitude: Double(viewModel.lng) ?? 0)
        cell.place = place
        cell.location = location
        if indexPath.row == viewModel.places.count - 1 {
            viewModel.getInterestingPlacesFromGoogle()
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 136
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let place = viewModel.places[indexPath.row]
        let controller = PlacesVC.instantiate(fromAppStoryboard: .places)
        controller.location = place.name
        controller.address = nil
        controller.rating = place.rating
        controller.viewModel = FeedViewModel(type: .places(id: place.id))
        //            controller.isUsersPlaces = false
        controller.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension NearbyViewController: UITextFieldDelegate {
    
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
        viewModel.searchText = text
        if text.isEmpty {
            tableView.reloadData()
        }else {
            if !Helpers.isLoggedIn() {
                unauthenticatedBlock(canDismiss: true)
                return
            }
            viewModel.isSearching = true
        }
        viewModel.getInterestingPlacesFromGoogle(new: true)
    }
    
}
