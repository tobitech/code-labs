//
//  RootViewController.swift
//  Cloudy
//
//  Created by Bart Jacobs on 01/10/16.
//  Copyright © 2016 Cocoacasts. All rights reserved.
//

import UIKit
import CoreLocation

final class RootViewController: UIViewController {

    // MARK: - Constants

    private let segueDayView = "SegueDayView"
    private let segueWeekView = "SegueWeekView"
    private let SegueSettingsView = "SegueSettingsView"
    private let segueLocationsView = "SegueLocationsView"

    // MARK: - Properties

    @IBOutlet private var dayViewController: DayViewController!
    @IBOutlet private var weekViewController: WeekViewController!
    
    // MARK: -

    private var currentLocation: CLLocation? {
        didSet {
            fetchWeatherData()
        }
    }

    private lazy var dataManager = {
        return DataManager(baseURL: API.AuthenticatedBaseURL)
    }()

    private lazy var locationManager: CLLocationManager = {
        // Initialize Location Manager
        let locationManager = CLLocationManager()

        // Configure Location Manager
        locationManager.distanceFilter = 1000.0
        locationManager.desiredAccuracy = 1000.0

        return locationManager
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        setupNotificationHandling()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {
        case segueDayView:
            guard let destination = segue.destination as? DayViewController else {
                fatalError("Unexpected Destination View Controller")
            }

            // Configure Destination
            destination.delegate = self

            // Update Day View Controller
            self.dayViewController = destination
        case segueWeekView:
            guard let destination = segue.destination as? WeekViewController else {
                fatalError("Unexpected Destination View Controller")
            }

            // Configure Destination
            destination.delegate = self

            // Update Week View Controller
            self.weekViewController = destination
        case SegueSettingsView:
            guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected Destination View Controller")
            }

            guard let destination = navigationController.topViewController as? SettingsViewController else {
                fatalError("Unexpected Destination View Controller")
            }

            // Configure Destination
            destination.controllerDidChangeTimeNotation = { [weak self, weak destination] in
                self?.dayViewController.reloadData()
                self?.weekViewController.reloadData()
                
                destination?.dismiss(animated: true)
            }
            
            destination.controllerDidChangeUnitsNotation = { [weak self, weak destination] in
                self?.dayViewController.reloadData()
                self?.weekViewController.reloadData()
                
                destination?.dismiss(animated: true)
            }
            
            destination.controllerDidChangeTemperatureNotation = { [weak self, weak destination] in
                self?.dayViewController.reloadData()
                self?.weekViewController.reloadData()
                
                destination?.dismiss(animated: true)
            }
        case segueLocationsView:
            guard let navigationController = segue.destination as? UINavigationController else {
                fatalError("Unexpected Destination View Controller")
            }

            guard let destination = navigationController.topViewController as? LocationsViewController else {
                fatalError("Unexpected Destination View Controller")
            }

            // Configure Destination
            destination.delegate = self
            destination.currentLocation = currentLocation
        default: break
        }
    }

    // MARK: - Actions

    @IBAction func unwindToRootViewController(segue: UIStoryboardSegue) {
        
    }

    // MARK: - Helper Methods

    private func setupNotificationHandling() {
        NotificationCenter.default.addObserver(forName: .UIApplicationDidBecomeActive, object: nil, queue: nil) { [weak self] (_) in
            self?.requestLocation()
        }
    }

    private func requestLocation() {
        // Configure Location Manager
        locationManager.delegate = self

        if CLLocationManager.authorizationStatus() == .authorizedWhenInUse {
            // Request Current Location
            locationManager.requestLocation()

        } else {
            // Request Authorization
            locationManager.requestWhenInUseAuthorization()
        }
    }

    private func fetchWeatherData() {
        guard let location = currentLocation else {
            return
        }

        let latitude = location.coordinate.latitude
        let longitude = location.coordinate.longitude
        
        dataManager.weatherDataForLocation(latitude: latitude, longitude: longitude) { [weak self] (response, error) in
            guard let _self = self else {
                return
            }
            
            if let error = error {
                print(error)
            } else if let response = response {
                // Configure Day View Controller
                _self.dayViewController.viewModel = DayViewViewModel(weatherData: response)

                // Configure Week View Controller
                _self.weekViewController.viewModel = WeekViewViewModel(weatherData: response.dailyData)
            }
        }
    }

}

extension RootViewController: CLLocationManagerDelegate {

    // MARK: - Authorization

    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedWhenInUse {
            // Request Location
            manager.requestLocation()

        } else {
            // Fall Back to Default Location
            currentLocation = CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        }
    }

    // MARK: - Location Updates
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        if let location = locations.first {
            // Update Current Location
            currentLocation = location

            // Reset Delegate
            manager.delegate = nil

            // Stop Location Manager
            manager.stopUpdatingLocation()

        } else {
            // Fall Back to Default Location
            currentLocation = CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)

        if currentLocation == nil {
            // Fall Back to Default Location
            currentLocation = CLLocation(latitude: Defaults.Latitude, longitude: Defaults.Longitude)
        }
    }

}

extension RootViewController: DayViewControllerDelegate {

    func controllerDidTapSettingsButton(controller: DayViewController) {
        performSegue(withIdentifier: SegueSettingsView, sender: self)
    }

    func controllerDidTapLocationButton(controller: DayViewController) {
        performSegue(withIdentifier: segueLocationsView, sender: self)
    }

}

extension RootViewController: WeekViewControllerDelegate {

    func controllerDidRefresh(controller: WeekViewController) {
        fetchWeatherData()
    }

}

extension RootViewController: LocationsViewControllerDelegate {

    func controller(_ controller: LocationsViewController, didSelectLocation location: CLLocation) {
        // Update Current Location
        currentLocation = location
    }

}
