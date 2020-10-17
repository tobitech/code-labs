//
//  NearbyViewModel.swift
//  Trajilis
//
//  Created by Perfect Aduh on 30/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import Alamofire

let kDefaultNearbySearchRadius:CGFloat = 3218

class NearByViewModel {
    // https://maps.googleapis.com/maps/api/place/details/json?placeid=ChIJN1t_tDeuEmsRUsoyG83frY4&fields=name,photo,rating,user_ratings_total,formatted_phone_number,website,formatted_address,reviews&key=AIzaSyAwu-PH_SOo3ekQC9FV0xcIbYSkah5xEew
    
    let key = Constants.GOOGLEAPIKEY
    var currentPage = 0
    var limit = 1000
    var isLastCount = false
    var reload: (() -> ())?
    var lng = ""
    var lat = ""
    var radius:CGFloat = kDefaultNearbySearchRadius
    var type = ""
    var isSearching = false
    var searchText = ""
    var city = ""
    var places = [CondensedPlace]()
    var nextToken = ""

    func load(isLoadingMore: Bool) {

    }

//    func getInterestingPlacesFromGoogle() {
//        let query = "things to do in \(city)".replacingOccurrences(of: " ", with: "+")
//        var urlString = "https://maps.googleapis.com/maps/api/place/textsearch/json?language=en&key=\(key)&query=\(query)"
//        if !self.nextToken.isEmpty {
//            urlString.append("&pagetoken=\(self.nextToken)")
//        }
//        if let url = URL(string: urlString) {
//            let request = URLRequest(url: url)
//            Alamofire.request(request).responseJSON { (response) in
//                if let val = response.result.value as AnyObject? {
//                    if let results = val["results"] as? [AnyObject] {
//                        let places = results.compactMap{ CondensedPlace.init(data: $0) }
//                        for place in places {
//                            let filtered = self.places.filter({ (plc) -> Bool in
//                                if plc.id == place.id {
//                                    return true
//                                }
//                                return false
//                            })
//                            if filtered.count == 0 {
//                                self.places.append(place)
//                            }
//                        }
//                    }
//                    self.nextToken = ""
//                    if let nextPageToken = val["next_page_token"] as? String {
//                        self.nextToken = nextPageToken
//                    }
//                }
//                self.reload?()
//            }
//        }
//
//    }

    func getInterestingPlacesFromGoogle(new: Bool = false) {
        if new {
            nextToken = ""
            places = []
        }
        var urlString = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?"
        if !self.nextToken.isEmpty {
            urlString.append("pagetoken=\(self.nextToken)")
        } else {
            urlString.append("\(constructQuery())")
        }
        urlString.append("&key=\(key)")
        if let url = URL(string:urlString) {
            print("search -- \(urlString)")
            let request = URLRequest(url: url)
            Alamofire.request(request).responseJSON { (response) in
                if let val = response.result.value as AnyObject? {
                    print(val)
                    if let results = val["results"] as? [AnyObject] {
                        print("....................")
                        print(results)
                        print("....................")
                        let places = results.compactMap{ CondensedPlace.init(data: $0) }
                        for place in places {
                            let filtered = self.places.filter({ (plc) -> Bool in
                                if plc.id == place.id {
                                    return true
                                }
                                return false
                            })
                            if filtered.count == 0 {
                                self.places.append(place)
                            }
                        }
                    }
                    self.nextToken = ""
                    if let nextPageToken = val["next_page_token"] as? String {
                        self.nextToken = nextPageToken
                    }
                }
                self.reload?()
            }
        }
    }

    private func constructQuery() -> String {
        var query = "&radius=\(radius)"
        if !lat.isEmpty {
            query += "&location=\(lat),\(lng)"
        }
        if !type.isEmpty {
            query += "&type=\(type)"
        }
        if !searchText.isEmpty {
            let encoded = searchText.encoded() 
            query += "&keyword=\(encoded))"
        }
        return query
    }
    
//    var placeFilterType: String = ""
//    var distanceFilterValue: String = ""
//
//    var searchByPlaceComplete: ((String?) -> ())?
//
//
//    init() {
//
//        //TODO REMOVED THIS IS FOR TESTING
//        searchNearbyPlaces(lat: 6.578330, long: 3.351810, radius: 1000)
//    }
//
//
//    func searchNearbyPlaces(lat: Double, long: Double, radius: Double) {
//        let param: JSONDictionary = [
//            "location": "\(lat), \(long)",
//            "radius": radius,
//            "key": Constants.GOOGLEAPIKEY
//        ]
//        APIController.makeRequest(request: .searchNearbyPlaces(param: param)) { [weak self] (response) in
//            print("Response \(String(describing: response.value))")
//            switch response {
//            case .failure(let error):
//                self?.searchByPlaceComplete?(error.desc)
//                print("Error \(error.localizedDescription)")
//                break
//            case .success(let value):
//                print("Value \(value.data)")
//                guard let json = try?  value.mapJSON() as? JSONDictionary else { return }
//                print("Places JSON \(String(describing: json))")
//
//                self?.searchByPlaceComplete?(nil)
//            }
//        }
//    }
}
