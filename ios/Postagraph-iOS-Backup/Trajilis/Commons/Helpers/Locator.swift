//
//  Locator.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import MapKit
enum LocationResult <T> {
    case success(T)
    case failure(Error)
}
class Locator: NSObject, CLLocationManagerDelegate {
    
    
    static let shared: Locator = Locator()
    
    typealias Callback = (LocationResult <Locator>) -> Void
    
    var requests: Array <Callback> = Array <Callback>()
    
    var location: CLLocation? { return sharedLocationManager.location  }
    
    lazy var sharedLocationManager: CLLocationManager = {
        let newLocationmanager = CLLocationManager()
        newLocationmanager.delegate = self
        //newLocationmanager.setAccuracy()
        return newLocationmanager
    }()
    
    
    // MARK: - Authorization
    
    class func authorize() {
        
        shared.authorize()
        
    }
    func authorize() {
        sharedLocationManager.requestWhenInUseAuthorization()
    }
    
    // MARK: - Helpers
    
    func locate(callback: @escaping Callback) {
        self.requests.append(callback)
        sharedLocationManager.startUpdatingLocation()
    }
    
    func reset() {
//        self.requests = Array <Callback>()
//        sharedLocationManager.stopUpdatingLocation()
    }
    func setAccuracy(isHigh:Bool = true) {        
        sharedLocationManager.desiredAccuracy = (isHigh) ? kCLLocationAccuracyBest : kCLLocationAccuracyBestForNavigation
    }
    func reset2() {
        self.requests = Array <Callback>()
        sharedLocationManager.stopUpdatingLocation()
    }
    

    // MARK: - Delegate
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        for request in self.requests { request(.failure(error)) }
        self.reset2()
    }
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        for request in self.requests { request(.success(self)) }
        self.reset2()
    }
    
    func placemark(_ completion: @escaping ((CLPlacemark?) -> ())) {
        guard let location = location else {
            completion(nil)
            return
        }
        CLGeocoder().reverseGeocodeLocation(location) { (placemarks, error) in
            completion(placemarks?.first)
        }
    }
    
}
