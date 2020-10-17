//
//  Artwork.swift
//  HonoluluArt
//
//  Created by Oluwatobi Omotayo on 28/08/2018.
//  Copyright © 2018 Ray Wenderlich. All rights reserved.
//

import MapKit

class Artwork: NSObject, MKAnnotation {
    var coordinate: CLLocationCoordinate2D
    
    let title: String?
    let locationName: String
    let discipline: String
    
    init(title: String, locationName: String, discipline: String, coordinate: CLLocationCoordinate2D) {
        self.title = title
        self.locationName = locationName
        self.discipline = discipline
        self.coordinate = coordinate
        
        super.init()
    }
    
    var subtitle: String? {
        return locationName
    }
    
}





