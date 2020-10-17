//
//  FollowTableViewController.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 10/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class MyHotelsBookingsViewController: BaseVC {
    
    @IBOutlet weak var tableView:UITableView!
    @IBOutlet weak var segmentControl: CustomSegmentedControl!
    @IBOutlet weak var flightButton: UIButton!
    @IBOutlet weak var hotelButton: UIButton!
    @IBOutlet weak var noDataView: UIView!
    
    @IBOutlet weak var noDataSubtitle: UILabel!
    @IBOutlet weak var noDataTitle: UILabel!
    @IBOutlet weak var noDataActionButton: UIButton!
    
    var hotelBookings:[PGHotelBookingDetail] = [PGHotelBookingDetail]()
    var flightBookings:[PGFlightBookingDetail] = [PGFlightBookingDetail]()
    
    var filteredFlightBookings:[PGFlightBookingDetail] = []
    var filteredHotelsBookings:[PGHotelBookingDetail] = []
    var didAnimate: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        noDataView.isHidden = true
        self.tableView.separatorStyle = .none
        
        title = "My Bookings"
        
        tableView.tableFooterView = UIView()
        
        tableView.rowHeight = UITableView.automaticDimension
        
        self.loadBookiings()
        
        noDataActionButton.set(borderWidth: 2, of: UIColor(hexString: "#E5E5E5"))
        noDataActionButton.set(cornerRadius: 4)
    }
    
    private func reload() {
        noDataView.isHidden = true
        if isHotels() {
            noDataSubtitle.text = "Ready to book your hotel?"
            noDataTitle.text = "No Hotels Found"
            noDataActionButton.setTitle("Book Hotel", for: .normal)
            noDataView.isHidden = !filteredHotelsBookings.isEmpty
        } else {
            noDataSubtitle.text = "Ready to book your flight?"
            noDataTitle.text = "No Flights Found"
            noDataActionButton.setTitle("Book Flight", for: .normal)
            noDataView.isHidden = !filteredFlightBookings.isEmpty
        }
        
        if didAnimate {
            tableView.reloadData()
        }else {
            didAnimate = true
            animateTable(tableView: tableView)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    func isHotels() -> Bool {
        return hotelButton.isSelected
    }
    
    @IBAction func flightButtonTapped(_ sender: Any) {
        noDataView.isHidden = true
        tableView.reloadData()
        flightButton.isSelected = true
        hotelButton.isSelected = false
        segmentControl.selectedSegmentIndex = 0
        loadBookiings()
    }
    
    @IBAction func hotelButtonTapped(_ sender: Any) {
        noDataView.isHidden = true
        tableView.reloadData()
        flightButton.isSelected = false
        hotelButton.isSelected = true
        segmentControl.selectedSegmentIndex = 0
        loadBookiings()
    }
    
    @IBAction func segmengtValueChanged(sender: CustomSegmentedControl) {
        filterBookings()
    }
    
    @IBAction func noDataActionButtonTapped(_ sender: Any) {
        if let navVC = self.tabBarController?.viewControllers?[kTabIndex.Book.rawValue] as? UINavigationController {
            
            if let bookVC = navVC.viewControllers.first as? BookingViewController {
                bookVC.isFlightBooking =  !isHotels()
                self.tabBarController?.selectedIndex = kTabIndex.Book.rawValue
            }
        }
    }
    
    func loadBookiings() {
        if self.isHotels() {
            self.getHotelsBookings()
        } else {
            self.getFlightBookings()
        }
    }
    
    func getFlightBookings() {
        self.spinner(with: "Getting Flight Bookings...", blockInteraction: true)
        self.flightBookings.removeAll()
        APIController.makeRequest(request: .getFlightBookings) { [weak self](response) in
            DispatchQueue.main.async {
                if let strngSelf = self {
                    strngSelf.hideSpinner()
                    switch response {
                    case .failure(let e):
                        strngSelf.showAlert(message: e.desc)
                    case .success(let result):
                        guard let json = try? result.mapJSON() as? JSONDictionary,
                            let data = json?["data"] as? [JSONDictionary] else {
                                strngSelf.filterBookings()
                                return
                        }
                        let bookings = data.compactMap{ PGFlightBookingDetail.init(json: $0) }
                        if bookings.count > 0 {
                            strngSelf.flightBookings.append(contentsOf: bookings)
                        }
                    }
                    strngSelf.filterBookings()
                }
            }
        }
    }
    
    func getHotelsBookings() {
        self.spinner(with: "Getting Hotel Bookings...", blockInteraction: true)
        self.hotelBookings.removeAll()
        APIController.makeRequest(request: .getHotelBookings) { [weak self](response) in
            DispatchQueue.main.async {
                if let self = self {
                    self.hideSpinner()
                    switch response {
                    case .failure(let e):
                        self.showAlert(message: e.desc)
                    case .success(let result):
                        guard let json = try? result.mapJSON() as? JSONDictionary,
                            let data = json?["data"] as? [JSONDictionary] else {
                                self.filterBookings()
                                return
                                
                        }
                        let bookings = data.compactMap{ PGHotelBookingDetail.init(json: $0) }
                        if bookings.count > 0 {
                            self.hotelBookings.append(contentsOf: bookings)
                        }
                    }
                    self.filterBookings()
                }
            }
        }
    }
    
    func filterBookings() {
        self.filteredFlightBookings = []
        self.filteredHotelsBookings = []
        
        if self.isHotels() {
            if self.hotelBookings.count > 0 {
                if segmentControl.selectedSegmentIndex == 0 {
                    let fitered = self.hotelBookings.filter { (booking) -> Bool in
                        if booking.isUpcoming() {
                            return true
                        }
                        return false
                    }
                    self.filteredHotelsBookings = fitered
                } else if segmentControl.selectedSegmentIndex == 1 {
                    let fitered = self.hotelBookings.filter { (booking) -> Bool in
                        if !booking.isUpcoming() {
                            return true
                        }
                        return false
                    }
                    self.filteredHotelsBookings = fitered
                }
            }
        } else {
            if self.flightBookings.count > 0 {
                if segmentControl.selectedSegmentIndex == 0 {
                    let fitered = self.flightBookings.filter { (booking) -> Bool in
                        if booking.isUpcoming() {
                            return true
                        }
                        return false
                    }
                    self.filteredFlightBookings = fitered
                } else if segmentControl.selectedSegmentIndex == 1 {
                    let fitered = self.flightBookings.filter { (booking) -> Bool in
                        if !booking.isUpcoming() {
                            return true
                        }
                        return false
                    }
                    self.filteredFlightBookings = fitered
                }
            }
        }
        reload()
    }

}

extension MyHotelsBookingsViewController : UITableViewDataSource,UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        //return 5
        if !didAnimate {
            return 0
        }
        if self.isHotels() {
            return self.filteredHotelsBookings.count
        } else {
            return self.filteredFlightBookings.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if self.isHotels() {
            let cell = tableView.dequeue(MyHotelBookingTableViewCell.self, for: indexPath)
            cell.set(booking: filteredHotelsBookings.item(at: indexPath.row))
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "MyFlightBookingTableViewCell", for: indexPath) as! MyFlightBookingTableViewCell
            cell.set(booking: filteredFlightBookings.item(at: indexPath.row))
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if self.isHotels() {
//            if indexPath.row < filteredHotelsBookings.count {
//                let bookingDetails = filteredHotelsBookings[indexPath.row]
//                let vc = PGHotelBookingConfirmationViewController.instantiate(fromAppStoryboard: .hotels)
//                vc.hideNavigationBar()
//                vc.isFromMyBookings = true
//                vc.hotelBookingDetails = bookingDetails
//                vc.selectedHotel = bookingDetails.hotel
//                self.navigationController?.pushViewController(vc, animated: true)
//            }
        } else {
//            if indexPath.row < filteredFlightBookings.count {
//                let booking = filteredFlightBookings[indexPath.row]
//                let controller =  FlightDetailsVC.instantiate(fromAppStoryboard: .flight)
//                controller.inboundFlight = self.inboundFlight
//                controller.outboundFlight = self.outboundFlight
//                controller.origin = self.origin
//                controller.destination = self.destination
//                controller.departureDate = self.departureDate
//                controller.returnDate = self.returnDate
//                controller.param = self.param
//                navigationController?.pushViewController(controller, animated: true)
//            }
        }
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

}


