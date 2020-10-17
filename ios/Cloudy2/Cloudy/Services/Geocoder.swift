//
//  Geocoder.swift
//  Cloudy
//
//  Created by Bart Jacobs on 07/12/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import CoreLocation

class Geocoder: LocationService {

    // MARK: - Properties

    private lazy var geocoder = CLGeocoder()

    // MARK: - Location Service Protocol

    func geocode(addressString: String?, completionHandler: @escaping LocationService.LocationServiceCompletionHandler) {
        guard let addressString = addressString else {
            completionHandler([], nil)
            return
        }

        // Geocode Address String
        geocoder.geocodeAddressString(addressString) { (placemarks, error) in
            if let error = error {
                completionHandler([], error)
                print("Unable to Forward Geocode Address (\(error))")

            } else if let _placemarks = placemarks {
                // Update Locations
                let locations = _placemarks.flatMap({ (placemark) -> Location? in
                    guard let name = placemark.name else { return nil }
                    guard let location = placemark.location else { return nil }
                    return Location(name: name, latitude: location.coordinate.latitude, longitude: location.coordinate.longitude)
                })

                completionHandler(locations, nil)
            }
        }
    }

}
