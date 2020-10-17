//
//  HotelSearch1ViewController.swift
//  Trajilis
//
//  Created by bharats802 on 12/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class HotelSearch1ViewController: UIViewController {

    @IBOutlet weak var searchBG:UIView!
    @IBOutlet weak var btnCurrentLocation:UIButton!
    let searchbarView = SearchView()
    var selectedCity:PGCity?
    var checkInDate:Date?
    var checkOutDate:Date?
    var currentLat:String?
    var currentLng:String?
    let viewCheckInOut:HotelCheckInOutView! = HotelCheckInOutView.getView()
    
    @IBOutlet weak var viewCheckInOutContainer:UIView!
    @IBOutlet weak var stackViewCheckInOutContainer:UIStackView!
    var totalOccupants:Int = 1
    var numOfRooms:Int = 1
    @IBOutlet var searchButton: TrajilisButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnCurrentLocation.isSelected = false
        searchButton.isEnabled = false
        searchButton.removeSublayer()
        self.btnCurrentLocation.layer.cornerRadius = 22.5
        
        self.checkInDate = Date()
        self.checkOutDate = Date().dateByAddingDays(days: 1)
        self.viewCheckInOut.setDate(isCheckIn: true, date: self.checkInDate)
        self.viewCheckInOut.setDate(isCheckIn: false, date: self.checkOutDate)
        
        self.viewCheckInOutContainer.backgroundColor = .clear
        self.searchBG.backgroundColor = .clear
        self.searchbarView.backgroundColor = .clear
        self.searchbarView.contentView.backgroundColor = .clear
        self.view.backgroundColor = .clear
        self.searchBG.addSubview(self.searchbarView)
        self.searchBG.addChildViewConstraints(subView: self.searchbarView)
        
        // Do any additional setup after loading the view.
        
        stackViewCheckInOutContainer.addArrangedSubview(self.viewCheckInOut)
        
        
        self.setupUI()
    }
    @IBAction func btnCurrentLocationTappedTapped() {
        self.btnCurrentLocation.isSelected = !self.btnCurrentLocation.isSelected
        if self.btnCurrentLocation.isSelected {
            self.selectedCity = nil
            self.searchbarView.searchBar.text = nil
            checkLocation()
        }
        self.updateSearchButton()
    }
    private func checkLocation() {
        Locator.shared.authorize()
        self.searchButton.isEnabled = false
        Locator.shared.locate { (result) in
            self.searchButton.isEnabled = true
            switch result {
            case .success(let location):
                if let loc = location.location {
                    self.currentLat = "\(loc.coordinate.latitude)"
                    self.currentLng = "\(loc.coordinate.longitude)"
                }
                Locator.shared.reset()
            case .failure(_):
                self.btnCurrentLocation.isSelected = false
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
    @IBAction func btnCityTapped() {
        self.selectAirport()
    }
    func setupUI() {
        self.searchbarView.searchBar.isUserInteractionEnabled = false
        
        let gesture = UITapGestureRecognizer(target: self, action: #selector(btnCityTapped))
        self.searchbarView.addGestureRecognizer(gesture)

        self.viewCheckInOut.lblRooms.text = "\(self.numOfRooms)"
        
        self.viewCheckInOut.btnRoomsMinus.addTarget(self, action: #selector(btnRoomsMinusTapped(sender:))
            , for: .touchUpInside)
        
        
        self.viewCheckInOut.btnRoomsAdd.addTarget(self, action: #selector(btnRoomsAddTapped(sender:))
            , for: .touchUpInside)
 
        self.viewCheckInOut.btnCheckIn.addTarget(self, action: #selector(btnCheckInTapped(sender:))
            , for: .touchUpInside)
        self.viewCheckInOut.btnCheckOut.addTarget(self, action: #selector(btnCheckOutTapped(sender:))
            , for: .touchUpInside)
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    @IBAction func btnRoomsAddTapped(sender:UIButton) {
        if self.numOfRooms < 9 {
            self.numOfRooms = self.numOfRooms + 1
            self.viewCheckInOut.lblRooms.text = "\(self.numOfRooms)"
        }
    }
    
    @IBAction func btnRoomsMinusTapped(sender:UIButton) {
        self.numOfRooms = self.numOfRooms - 1
        if self.numOfRooms == 0 {
            self.numOfRooms =  1
        }
        self.viewCheckInOut.lblRooms.text = "\(self.numOfRooms)"
        
    }
    
    @IBAction func btnCheckOutTapped(sender:UIButton) {
        self.selectDate(tag: 1)
    }
    
    @IBAction func btnCheckInTapped(sender:UIButton) {
        self.selectDate(tag: 0)
    }
    @IBAction func btnSearchTapped(sender:TrajilisButton) {
        
        let dateFormat = "yyyy-MM-dd"
        var city = ""
        var crntLng = ""
        var crntLat = ""
        if self.btnCurrentLocation.isSelected {
            if  let value = self.currentLng {
                crntLng = value
            }
            if  let value = self.currentLat {
                crntLat = value
            }
        } else {
            if let cityCode = self.selectedCity?.code {
                city = cityCode
            } else {
                self.showAlert(message: "Please select a city.")
                return
            }
        }
        
        var checkInDate = ""
        if let checkIn = self.checkInDate {
            if checkIn.isFuture {
                checkInDate = checkIn.getStringInformat(dateFormat: dateFormat)
            } else {
                self.showAlert(message: "Please select check in date in future.")
                return
            }
        } else {
            self.showAlert(message: "Please select check in date.")
            return
        }
        var checkOutDate = ""
        if let checkOut = self.checkOutDate {
            if checkOut.isFuture {
                checkOutDate = checkOut.getStringInformat(dateFormat: dateFormat)
            } else {
                self.showAlert(message: "Please select check out date in future.")
                return
            }
            
        } else {
            self.showAlert(message: "Please select check out date.")
            return
        }
        var param: JSONDictionary
        
        let controller = PGHotelsViewController.instantiate(fromAppStoryboard: .hotels)
        controller.hidesBottomBarWhenPushed = true
        
        
        if self.btnCurrentLocation.isSelected {
            param = [
                "longitude": crntLng,
                "latitude": crntLat,
                "quantity": self.numOfRooms,
                "totalOccupants": self.totalOccupants,
                "startDate": checkInDate,
                "endDate": checkOutDate,
                "currency": CurrencyManager.shared.getUserCurrencyCode()
            ]
            controller.curntLocParams = param
        } else {
            param = [
                "totalOccupants": self.totalOccupants,
                "quantity": self.numOfRooms,
                "location": city,
                "startDate": checkInDate,
                "endDate": checkOutDate,
                "currency": CurrencyManager.shared.getUserCurrencyCode()
            ]
            controller.searchParams = param
        }
        let hoteBooking = PGHotelBooking()
        hoteBooking.checkInDate = self.checkInDate
        hoteBooking.checkOutDate = self.checkOutDate
        hoteBooking.occupent = self.totalOccupants
        hoteBooking.numOfRooms = self.numOfRooms
        hoteBooking.selectedLocation = city
        controller.hotelBooking = hoteBooking
        self.navigationController?.pushViewController(controller, animated: true)
    }
    private func selectDate(tag: Int) {
        let controller = FlightSelectDateVC.instantiate(fromAppStoryboard: .flight)
        controller.tripType = .roundTrip
//        controller.calenderUseType = .hotel
//        controller.isHotelsMode = true
//        controller.checkout = self.checkOutDate
//        controller.checkIn = self.checkInDate
        controller.selectedDate = { [weak self] departDate, returnDate in
            self?.checkOutDate = returnDate
            self?.checkInDate = departDate
            self?.viewCheckInOut.setDate(isCheckIn: true, date: departDate)
            self?.viewCheckInOut.setDate(isCheckIn: false, date: returnDate)
            self?.updateSearchButton()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    private func updateSearchButton() {
        
        if (!self.btnCurrentLocation.isSelected && self.selectedCity == nil) || self.checkInDate == nil || self.checkOutDate == nil {
            return
        }
        searchButton.isEnabled = true
        searchButton.removeSublayer()
        searchButton.setGradient = true
        searchButton.setTitleColor(UIColor.white, for: .normal)
    }
}

extension HotelSearch1ViewController {
    
    private func selectAirport() {
        // do something reasonable here later.
    }

}
