//
//  SearchViewmodel.swift
//  Trajilis
//
//  Created by Perfect Aduh on 26/11/2018.
//  Copyright © 2018 Perfect Aduh. All rights reserved.
//

import Foundation
import CoreLocation


class SearchViewModel {
    var isSearching = false
    var users = [User]()
    var userSuggestionResponse = [User]()
    var userSearchResponse = [User]()
    var currentPage = 0
    var limit = 1000
    var isLastCount = false
    var lng = "0"
    var lat = "0"
    var cityFares: PGCityFares?
    var searchComplete: ((String?) -> ())?
    var reload: (() -> ())?

    //var friends = [Followers]()
    var trendings = [CondensedPlace]()
//    var nearby:
    var exploreFeed:Feed?
    
    var people = [Followers]()
    var hashTags = [Hashtag]()
    var feeds = [CondensedFeed]()
    var places = [CondensedPlace]()
    
    private var searchWork: DispatchWorkItem?
    
    func searchTrending(searchParam: String)  {
        searchWork?.cancel()
        if !Helpers.isLoggedIn() { return }
        searchWork = DispatchWorkItem(block: {
            APIController.makeRequest(request: .trending(text: searchParam, lng: self.lng, lat: self.lat, count: self.currentPage, limit: self.limit)) { [weak self] (response) in
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        self?.searchComplete?(error.desc)
                    case .success(let result):
                        guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                        let hashtags = json?["hash_tags"] as? [JSONDictionary] ?? []
                        let users = json?["users"] as? [JSONDictionary] ?? []
                        let posts = json?["feeds"] as? [JSONDictionary] ?? []
                        let locations = json?["locations"] as? [JSONDictionary] ?? []
                        self?.hashTags = hashtags.compactMap{ Hashtag.init(json: $0) }
                        self?.people = users.compactMap{ Followers.init(json: $0) }
                        self?.feeds = posts.compactMap{ CondensedFeed.init(json: $0) }
                        self?.places = locations.compactMap{ CondensedPlace.init(json: $0) }
                        self?.searchComplete?(nil)
                    }
                }
            }
        })
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: searchWork!)
    }
    
    func getOfflineTrendingLocation() {
        if storedFare() {
            self.reload?()
        }
    }

    func getTrendingLocations() {
        
//        if !Helpers.isLoggedIn() {
//            return
//        }
        
//        var ack = 2 {
//            didSet {
//                if ack == 0 {
//                    self.reload?()
//                }
//            }
//        }
        
//        APIController.makeRequest(request: .trendingLocation(text: "all", lng: self.lng, lat: self.lat, count: self.currentPage, limit: self.limit)) { (response) in
//            DispatchQueue.main.async {
//                switch response {
//                case .failure(_): break
//                case .success(let result):
//                    guard let json = try? result.mapJSON() as? JSONDictionary,
//                        let data = json?["locations"] as? [JSONDictionary] else { return }
//                    print(data)
//                    let places = data.compactMap{ CondensedPlace.init(json: $0) }
//                    self.trendings = places
//                }
//                ack -= 1
//            }
//        }
        
        self.getCityFares(completion: {
//            ack -= 1
            self.reload?()
        })
    }

    func fetchExploreFeeds() {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        APIController.makeRequest(request: .feedsExplore(userId: id, count: currentPage, limit: limit)) { [weak self] (response) in
            switch response {
            case .failure(_):
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let feedDictArray = json?["feeds"] as? [JSONDictionary] else { return }
                let feeds = feedDictArray.map{ Feed.init(json: $0) }
                if feeds.count > 5 {
                    try? DataStorage.shared.dataStorage.setObject(result.data, forKey: EXPLORE_FEED_CACHE_KEY)
                }
                var shuoldReload = true
                if self?.exploreFeed != nil {
                    shuoldReload = false
                }
                self?.exploreFeed = feeds.randomItem()
                if shuoldReload {
                    self?.reload?()
                }                
            }
        }
    }
    
    /*
    func getSuggestedFriends(isLoadingMore: Bool = false) {
        if !Helpers.isLoggedIn() { return }
        APIController.makeRequest(request: .getSuggestion(count: currentPage, limit: limit)) { (response) in
            switch response {
            case .failure(_):
                self.reload?()
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                if let data = json?["suggetion"] as? [JSONDictionary] {
                    let followers = data.compactMap({ Followers.init(json: $0) })
                    self.friends = followers
                    if !self.trendings.isEmpty {
                        self.reload?()
                    }
                }

            }
        }
    }
 */
    private func storedFare() -> Bool {
        if let data = Helpers.getMockJSON(fileName: "cityfares") as? JSONDictionary {
            self.cityFares = PGCityFares(json: data)
            let fare = self.getCityFareLocally()
            if let airport = fare?["nearestAirport"] as? JSONDictionary {
                cityFares?.nearestAirport = [Airport(json: airport)]
            }
            self.cityFares?.exploreCities.forEach({
                guard let code = $0.code else {return}
                
                let cities = fare?["exploreCities"] as? [String: Any]
                let cityFare = cities?[code] as? [String: String]
                
                guard let fareAmount = Double(cityFare?["amount"] ?? "") else {return}
                $0.flightDetails = FlightSearchResult(json: [:], index: 0)
                $0.flightDetails?.totalAggAmount = fareAmount
            })
            return true
        }
        return false
    }
    
    func getCityFares(completion: @escaping () -> ()) {
        
        if let lastSaved = UserDefaults.standard.object(forKey: "PG-CITY-FARES-SAVED_ON") as? Date, Calendar.current.isDateInToday(lastSaved) {
            return
        }

        let param: JSONDictionary = ["longitude": lng,"latitude": lat,
                                    "cities": ["ZAD",
                                               "LAS",
                                               "PVR",
                                               "RAK",
                                               "LYS",
                                               "DOH",
                                               "DKR",
                                               "LAX",
                                               "PDL",
                                               "BJL"]]
        
        APIController.makeRequest(request: .getCityFaresFromNearestLocation(param: param)) { (response) in
            
            DispatchQueue.main.async {
                switch response {
                case .success(let result):
                    guard let json =  try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? JSONDictionary, let statusCode = json?["statusCode"] as? Int else {
                            if self.storedFare() {
                                completion()
                            }
                            return
                    }
                    if statusCode == 200 {
                        if data.count > 0 {
                            self.saveCityFareLocally(data: data)
                        }
//                        self.cityFares = PGCityFares(json: data)
//                        if let fares = self.cityFares, fares.exploreCities.count > 0 {
//                            self.saveCityFareLocally(data: data)
//                        }
                    }
                default:
                    break
                }
                if self.storedFare() {
                    completion()
                }
            }
        }
    }
    
    func saveCityFareLocally(data: JSONDictionary?) {
        if let data = data {
            do {
                let jsond = try JSONSerialization.data(withJSONObject:data, options: [])
                try DataStorage.shared.dataStorage.setObject(jsond, forKey:"PG-CITY-FARES")
                UserDefaults.standard.set(Date(), forKey:"PG-CITY-FARES-SAVED_ON")
                UserDefaults.standard.synchronize()
            } catch {
                print(error)
            }
        }
    }
    func getCityFareLocally() -> JSONDictionary? {
        do {
            let data = try DataStorage.shared.dataStorage.object(forKey: "PG-CITY-FARES")
            if let dataObj = try JSONSerialization.jsonObject(with: data, options : .allowFragments) as? JSONDictionary
            {
                return dataObj
            } else {
                print("bad json")
            }
        } catch {
            print(error)
        }
        return nil
    }
}


struct Hashtag {
    let tag: String
    let image: String
}

extension Hashtag {
    init(json: JSONDictionary) {
        tag = json["hash_tag"] as? String ?? ""
        image = json["hash_image"] as? String ?? ""
    }
}

struct CondensedPlace {
    let name: String
    let distance: String
    let rating: Double
    let id: String
    let icon: String
    let count: Int
    var lastPlaceFeedImage: String
    
    // for google place
    var location:CLLocation?
    var type:String?
}

extension CondensedPlace {
    init(json: JSONDictionary) {
        name = json["place_name"] as? String ?? ""
        distance = json["place_distance"] as? String ?? ""
        rating = json["place_rating"] as? Double ?? 0.0
        id = json["place_id"] as? String ?? ""
        icon = json["place_icon"] as? String ?? ""
        count = json["place_feed_count"] as? Int ?? 0
        lastPlaceFeedImage = json["last_place_feed_image"] as? String ?? ""
        
    }
    init(data: AnyObject) {        
        print(data)
        name = data["name"] as? String ?? data["description"] as? String ?? ""
        rating = data["rating"] as? Double ?? 0.0
        id = data["place_id"] as? String ?? ""
        icon = data["icon"] as? String ?? ""
        
        distance = data["place_distance"] as? String ?? ""
        count = data["place_feed_count"] as? Int ?? 0
        lastPlaceFeedImage = data["last_place_feed_image"] as? String ?? ""
        
        if lastPlaceFeedImage.isEmpty {
            if let photos = data["photos"] as? [AnyObject],let photo = photos.first {
                if let photoreference = photo["photo_reference"] as? String {
                   lastPlaceFeedImage =  "https://maps.googleapis.com/maps/api/place/photo?photoreference=\(photoreference)&sensor=false&maxheight=300&maxwidth=300&key=\(Constants.GOOGLEAPIKEY)"
                }
            }
        }
        if let geo = data["geometry"] as AnyObject?,let loc = geo["location"] as? [String:AnyObject] {
            if let lat = loc["lat"] as? Double,let lng = loc["lng"]  as? Double {
               self.location =  CLLocation(latitude: lat, longitude: lng)
            }
        }
        if let types = data["types"] as? [String],let ptype = types.first {
            self.type = ptype.replacingOccurrences(of: "_", with: " ")
            
        }
    }
}
