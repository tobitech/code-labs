//
//  VideoViewModel.swift
//  Trajilis
//
//  Created by Perfect Aduh on 28/08/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation
import AWSS3
import Hakawai
import CoreLocation

final class VideoViewModel {
    
    var uploadContentComplete:((String?) -> ())?
    
    var videoURLs: [URL]!
    var coverImages: [UIImage]?
    var postType = "PUBLIC"
    var plugin: HKWMentionsPlugin?
    var coordinates: CLLocationCoordinate2D?
    var trip: Trip?
    var taggedUsers: String?
    var tags: String?
    var rating: Int?
    var selectedVenue: Venue?
    var description: String?
    
    init() {
        
    }
    
    func saveVideo() {
        let location = coordinates!
        for videoURL in videoURLs {
            if let obj = SavedRecording.getNewSaving() {
                obj.filepath = videoURL.lastPathComponent
                obj.recordedOn = Date().timeIntervalSince1970
                obj.lat = location.latitude
                obj.lng = location.longitude
                do {
                    try obj.managedObjectContext?.save()
                } catch {
                    print(error)
                }
            }
        }
    }
    
    func uploadVideo(videoUrls: [URL], progressView: UIProgressView, completion: @escaping ((_ fileName: String?, _ fileExtension: String?, _ url: String?) ->())) {
        var fileNames: [String] = []
        var fileExtensions: [String] = []
        var urls: [String] = []
        
        func complete() {
            completion(fileNames.joined(separator: ", "), fileExtensions.joined(separator: ", "), urls.joined(separator: ", "))
        }
        
        func failed() {
            saveVideo()
            completion(nil, nil, nil)
        }
        
        func upload(url: URL, counter: Int = 0) {
            do {
                let progressBlock: AWSS3TransferUtilityProgressBlock?  = {(task, progress) in
                    DispatchQueue.main.async(execute: {
                        NSLog("status -- \(progress.fractionCompleted)")
                        progressView.progress = Float(counter) * 1/Float(videoUrls.count) + Float(progress.fractionCompleted/Double(videoUrls.count))
                    })
                }
                
                let data = try Data.init(contentsOf: url)
                Helpers.uploadPostToS3(data: data, progressBlock: progressBlock, completion: { (fileName, fileExtension, s3URL, error) in
                    DispatchQueue.main.async {
                        if let url = s3URL {
                            fileNames.append(fileName)
                            fileExtensions.append(fileExtension)
                            urls.append(url)
                            let newCounter = counter + 1
                            if newCounter < videoUrls.count {
                                upload(url: videoUrls[newCounter], counter: newCounter)
                            }else {
                                complete()
                            }
                        } else {
                            failed()
                        }
                    }
                })
                
            } catch {
                print(error)
                completion(nil, nil, nil)
            }
        }
        
        upload(url: videoUrls[0])
    }
    
    func uploadCoverImage(completion: @escaping ((String?) ->())) {
        guard let imgs = coverImages, !imgs.isEmpty else {
            completion(nil)
            return
        }
        var images: [String] = []
        
        func complete() {
            completion(images.joined(separator: ", "))
        }
        
        func upload(img: UIImage, counter: Int = 0) {
            Helpers.uploadToS3(image: img) { (s3URL, error) in
                DispatchQueue.main.async {
                    images.append(s3URL ?? "")
                    let newCounter = counter + 1
                    if newCounter < imgs.count {
                        upload(img: imgs[newCounter], counter: newCounter)
                    }else {
                        complete()
                    }
                }
            }
        }
        upload(img: imgs[0])
    }
    
    func postContent(venue: Venue, videoName: String, videoExtension: String, videoURL: String, coverImageURL: String, desc: String) {
        
        let timestamp = Date().timeIntervalSince1970
        let c : String = String(format:"%.0f", timestamp)
        
        let components = desc.components(separatedBy: " ")
        var hashTags:[String] = []
        for word in components {
            if word.hasPrefix("#") {
                let tag = word.replacingOccurrences(of: "#", with: "")
                hashTags.append(tag)
            }
        }
        var lat: NSNumber = 0
        if let latString = venue.location?.lat, let l = Double(latString) {
            lat = NSNumber(value: l)
        } else if let l = coordinates?.latitude {
            lat = NSNumber(value: l)
        }
        
        var lng: NSNumber = 0
        if let latString = venue.location?.lng, let l = Double(latString) {
            lng = NSNumber(value: l)
        } else if let l = coordinates?.longitude {
            lng = NSNumber(value: l)
        }
        
        let parameters: JSONDictionary = [
            "content": original(text: desc),
            "createdon": c,
            "feed_location": venue.name,
            "feed_type": "video",
            "address": venue.location?.address ?? "",
            "lat": lat,
            "lon": lng,
            "search_place_name": venue.name,
            "search_place_id": venue.id,
            "search_place_icon": venue.searchPlaceIcon,
            "rating": "\(rating ?? 0)",
            "thumbnail": coverImageURL,
            "feed_visibility": postType,
            "trip_id": trip?.tripId ?? "",
            "trip_name": trip?.tripName ?? "",
            "title": "",
            "url": videoURL,
            "taged_user": taggedUsers,
            "hash_tag": tags,
            "user_id": UserDefaults.standard.string(forKey: USERID)!,
            "filename": videoName,
            "fileextension": videoExtension
        ]
        
        APIController.makeRequest(request: .createFeed(param: parameters)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .success(_):
                    self.uploadContentComplete?(nil)
                    kAppDelegate.rateUS()
                case .failure(let error):
                    self.saveVideo()
                    self.uploadContentComplete?("Video upload failed. But, videos are saved locally, you can upload them at your convinience.")
                }
            }
        }
    }
    
    private func original(text: String) -> String {
        guard let mentions = plugin?.mentions() as? [HKWMentionsAttribute] else { return text }
        var components = text.components(separatedBy: " ")
        for mention in mentions {
            guard let count = mention.entityId()?.count else {
                continue
            }
            if count > 10 {
                if let index = components.firstIndex(of: mention.entityName()) {
                    components[index] = "@" + components[index]
                }
            } else {
                if let index = components.firstIndex(of: mention.entityName()) {
                    //components[index] = "#" + components[index]
                    components[index] = components[index]
                }
            }
        }
        return components.joined(separator: " ")
    }
}
