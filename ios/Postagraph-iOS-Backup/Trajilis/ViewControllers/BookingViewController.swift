//
//  BookingViewController.swift
//  Trajilis
//
//  Created by bharats802 on 10/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class BookingViewController: BaseVC {

    @IBOutlet weak var btnFlight:TrajilisButton!
    @IBOutlet weak var btnHotel:TrajilisButton!
    @IBOutlet weak var viewContainer:UIView!
    @IBOutlet weak var imgVieBG:UIImageView!
    
    var flightSearchVC: SearchFlightVC! = SearchFlightVC.instantiate(fromAppStoryboard: .flight)
    var hotelSearch1ViewController: HotelSearch1ViewController! = HotelSearch1ViewController.instantiate(fromAppStoryboard: .hotels)
    
    var searchOrigin:Airport?
    var searchDestination:Airport?
    
    var isFlightBooking = true {
        didSet {
            self.btnFlight?.isSelected = isFlightBooking
            self.btnHotel?.isSelected = !isFlightBooking
            
            if btnFlight != nil {
                setupUI()
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
        self.btnFlight.isSelected = isFlightBooking
        self.btnHotel.isSelected = !isFlightBooking
        
        self.viewContainer.backgroundColor = .clear
        
        self.flightSearchVC.pushSearchResult =  { vc in
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
 
    func setupUI() {
        self.setButton(btn: self.btnFlight, imageName: "flight-icon")
        self.setButton(btn: self.btnHotel, imageName: "hotel-icon")
        
        self.viewContainer.removeAllViews()
        self.flightSearchVC.removeFromParent()
        if self.btnHotel.isSelected {
            self.title = "Book Hotel"
            self.viewContainer.addSubview(self.hotelSearch1ViewController.view)
            self.viewContainer.addChildViewConstraints(subView: self.hotelSearch1ViewController.view)
            self.addChild(self.hotelSearch1ViewController)
        } else {
            self.title = "Book Flight"
            self.viewContainer.addSubview(self.flightSearchVC.view)
            self.viewContainer.addChildViewConstraints(subView: self.flightSearchVC.view)
            self.addChild(self.flightSearchVC)
        }
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.setupUI()
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        //self.hideNavigationBar()
        self.tabBarController?.tabBar.backgroundColor = UIColor.white
        if let dst = self.searchDestination,let org = self.searchOrigin {
            self.showFlights(origin: org, destination: dst)
            self.searchDestination = nil
            self.searchOrigin = nil
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .default
    }
    func setButton(btn:TrajilisButton, imageName: String? = nil) {
        if btn.isSelected {
            btn.setImage(UIImage(named: "\(imageName ?? "")-selected"), for: .selected) //= UIColor.appRed
            //btn.setTitleColor(UIColor.white, for: .normal)
           //btn.setGradient = true
        } else {
            btn.setImage(UIImage(named: "\(imageName ?? "")-unselected"), for: .normal)
//            btn.bgColor = UIColor.white
//            btn.setTitleColor(UIColor.lightGray, for: .normal)
//            btn.setGradient = false
        }
    }
    func showFlights(origin:Airport,destination:Airport) {
        self.btnFlightTapped(sender: self.btnFlight)
        self.flightSearchVC.showFlights(origin: origin, destination: destination)
    }
    @IBAction func btnFlightTapped(sender:UIButton) {
        sender.isSelected = true
        self.btnHotel.isSelected = false
        self.setupUI()        
    }
    @IBAction func btnHotelTapped(sender:UIButton) {
        sender.isSelected = true
        self.btnFlight.isSelected = false
        self.setupUI()
    }

}
