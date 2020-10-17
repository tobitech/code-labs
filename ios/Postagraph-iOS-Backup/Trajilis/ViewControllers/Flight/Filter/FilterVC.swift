//
//  FilterVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 21/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Parchment

final class FilterVC: BaseVC {

    @IBOutlet var applyButton: TrajilisButton!
    let stopsVC = StopsFilterVC.instantiate(fromAppStoryboard: .flight)
    let cabinVC = CabinClassFilterVC.instantiate(fromAppStoryboard: .flight)
    let timeVC = TimeFilterVC.instantiate(fromAppStoryboard: .flight)
    let airlineVC = AirlineFilterVC.instantiate(fromAppStoryboard: .flight)

    var airlines = [Company]()
    var selectedAirline = [Company]()
    var cabinClass = FlightClass.economy
    var stops = FlightType.all

    var selectedFilters:((String, [Company], FlightType, FlightClass) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        airlineVC.airlines = airlines
        airlineVC.selectedAirlines = selectedAirline
        cabinVC.cabin = cabinClass
        stopsVC.stops = stops
        title = "Filter"
        let pagingViewController = FixedPagingViewController(viewControllers: [stopsVC, timeVC, airlineVC, cabinVC])
        pagingViewController.textColor = UIColor.appBlack
        pagingViewController.selectedTextColor = UIColor.appRed
        pagingViewController.indicatorColor = UIColor.appRed

        addChild(pagingViewController)
        view.insertSubview(pagingViewController.view, belowSubview: applyButton)
        pagingViewController.view.translatesAutoresizingMaskIntoConstraints = false
        pagingViewController.view.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        pagingViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        pagingViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        pagingViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        pagingViewController.didMove(toParent: self)
    }

    @IBAction func applyTapped(_ sender: Any) {
        let time = timeVC.time
        let selectedAirline = airlineVC.selectedAirlines
        let stops = stopsVC.stops
        let cabin = cabinVC.cabin
        selectedFilters?(time, selectedAirline, stops, cabin)
        navigationController?.popViewController(animated: true)
    }
    
}

