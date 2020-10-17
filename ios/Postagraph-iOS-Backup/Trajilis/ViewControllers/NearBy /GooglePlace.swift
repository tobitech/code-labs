//
//  GooglePlace.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import CoreLocation

class GooglePlace: NSObject {

    var name:String?
    var address:String?
    var phone:String?
    var isOpenNow:Bool = false
    var weekday_text:[String]?
    var photos:[String] = [String]()
    var rating:Double = 0
    var id:String?
    var location:CLLocation?
    var website:String?
    var reviews:[GoogleReview] = [GoogleReview]()
    init(data: AnyObject) {
        print(data)
        name = data["name"] as? String ?? ""
        rating = data["rating"] as? Double ?? 0.0
        id = data["place_id"] as? String ?? ""
        address = data["formatted_address"] as? String ?? ""
        phone = data["formatted_phone_number"] as? String ?? ""
        website = data["website"] as? String ?? ""
        
        
        if let photos = data["photos"] as? [AnyObject] {
            self.photos = [String]()
            for  photo in photos {
                if let photoreference = photo["photo_reference"] as? String {
                    let  lastPlaceFeedImage =  "https://maps.googleapis.com/maps/api/place/photo?photoreference=\(photoreference)&sensor=false&maxheight=300&maxwidth=300&key=\(Constants.GOOGLEAPIKEY)"
                    self.photos.append(lastPlaceFeedImage)
                }
            }
        }
        if let opening_hours = data["opening_hours"] as? [String:AnyObject] {
            if let weekday_text = opening_hours["weekday_text"] as? [String] {
                self.weekday_text = weekday_text
            }
            if let openNow = opening_hours["open_now"] as? Bool {
                self.isOpenNow = openNow
            }
        }
        
        if let geo = data["geometry"] as AnyObject?,let loc = geo["location"] as? [String:AnyObject] {
            if let lat = loc["lat"] as? Double,let lng = loc["lng"]  as? Double {
                self.location =  CLLocation(latitude: lat, longitude: lng)
            }
        }
        if let reviews = data["reviews"] as? [AnyObject],reviews.count > 0 {
            
            for review in reviews {
                let gReview = GoogleReview()
                if let value = review["author_name"] as? String {
                    gReview.author_name = value
                }
                if let value = review["profile_photo_url"] as? String {
                    gReview.profile_photo_url = value
                }
                if let value = review["rating"] as? Double {
                    gReview.rating = value
                }
                if let value = review["relative_time_description"] as? String {
                    gReview.relative_time_description = value
                }
                if let value = review["text"] as? String {
                    gReview.text = value
                }
                if let value = review["time"] as? Double {
                    gReview.reviewTimeStamp = value
                }
                self.reviews.append(gReview)
            }
        }
        
        
    }
}
class GoogleReview:NSObject {
    var  author_name:String?
    var profile_photo_url:String?
    var rating:Double = 0
    var relative_time_description:String?
    var text:String?
    var reviewTimeStamp:Double = 0.0
}
