//
//  Helpers.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import Photos
import AWSS3
import Kingfisher
import AVKit
import Cosmos
import FirebaseDynamicLinks
let USERID = "userId"

let kDate_yyyy_MM_dd = "yyyy-MM-dd"

struct Helpers {
    
    static var hasTopNotch: Bool {
        if #available(iOS 11.0,  *) {
            return UIApplication.shared.delegate?.window??.safeAreaInsets.top ?? 0 > 20
        }
        return false
    }
    
    public static func daysBetween(start: Date, end: Date) -> Int {
        return Calendar.current.dateComponents([.day], from: start, to: end).day!
    }
    static func meterToMile(mtr:CGFloat) -> CGFloat {
        return mtr/1609.344
    }
    static func mileToMtr(mile:CGFloat) -> CGFloat {
        return mile*1609.344
    }
    
    static func setupBackButton(button:UIButton) {
        button.backgroundColor = UIColor.appRed
        button.layer.cornerRadius = 35/2
        button.setImage(UIImage(named: "back-white"), for: .normal)
        button.imageEdgeInsets = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 5)
    }
    static func isPad() -> Bool {
        return UIDevice.current.model.hasPrefix("iPad")
    }
    
    static func thumbnailImageFor(fileUrl:URL) -> UIImage? {
        
        let video = AVURLAsset(url: fileUrl, options: [:])
        let assetImgGenerate = AVAssetImageGenerator(asset: video)
        assetImgGenerate.appliesPreferredTrackTransform = true
        
        let videoDuration:CMTime = video.duration
        
        let numerator = Int64(1)
        let denominator = videoDuration.timescale
        let time = CMTimeMake(value: numerator, timescale: denominator)
        
        do {
            let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
            let thumbnail = UIImage(cgImage: img)
            return thumbnail
        } catch {
            print(error)
            return nil
        }
    }
    
    static func convertTimeFrom24hrsTo12hrs(date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    
    static func durationBetween(latestDate: Date, previousDate: Date) -> String {
        let diff = latestDate.timeIntervalSince(previousDate)
        let hours = Int(diff) / 3600
        let minutes = (Int(diff) / 60) % 60
        return "\(hours)h \(minutes)m"
    }
    
    static func formattedDateFromString(dateString: String, withFormat format: String,inputDateFormat:String = "yyyy-MM-dd") -> String {
        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputDateFormat        
        if let date = inputFormatter.date(from: dateString) {
            
            let outputFormatter = DateFormatter()
            outputFormatter.dateFormat = format
            
            return outputFormatter.string(from: date)
        }
        
        return ""
    }
    
    static func dateFromString(dateString: String,inputDateFormat:String = "yyyy-MM-dd") -> Date? {        
        let inputFormatter = DateFormatter()
        inputFormatter.dateFormat = inputDateFormat
        if let date = inputFormatter.date(from: dateString) {
            return date
        }
        return nil
    }
    
    static var userId: String {
        return UserDefaults.standard.string(forKey: USERID) ?? ""
    }
    
    static func retrieveImage(imageURL: URL, completion: @escaping ((UIImage?) -> ())) {
        ImageCache.default.retrieveImage(forKey: imageURL.absoluteString, options: nil, completionHandler: { (image, cacheType) in
            if let img = image {
                DispatchQueue.main.async {
                    completion(img)
                }
            } else {
                ImageDownloader.default.downloadImage(with: imageURL, options: [], progressBlock: nil) {
                    
                    (image, error, url, data) in
                    if let img = image {
                        ImageCache.default.store(img, forKey: imageURL.absoluteString)
                    }
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }
            }
        })
    }
    
    static func addImage(initialText: String, afterText: String, image: UIImage) -> NSMutableAttributedString {
        let attachment: NSTextAttachment = NSTextAttachment()
        attachment.image = image
        let attachmentString: NSAttributedString = NSAttributedString(attachment: attachment)
        let space: NSAttributedString = NSAttributedString(string: " ")
        let text: NSMutableAttributedString = NSMutableAttributedString(string: initialText)
        text.append(space)
        text.append(attachmentString)
        text.append(space)
        text.append(NSAttributedString(string: afterText))
        return text
    }
    
    static func circleAroundDigit(_ num: Int, circleColor: UIColor,
                                  digitColor: UIColor, diameter: CGFloat,
                                  font: UIFont) -> UIImage {
        let height = String(num).heightOfString(usingFont: font) + 5
        let width = String(num).widthOfString(usingFont: font) + 8
        let p = NSMutableParagraphStyle()
        p.alignment = .center
        let s = NSAttributedString(string: String(num), attributes:
            [.font:font, .foregroundColor:digitColor, .paragraphStyle:p])
        let r = UIGraphicsImageRenderer(size: CGSize(width: width, height: height))
        return r.image {con in
            circleColor.setFill()
            con.cgContext.fillEllipse(in:
                CGRect(x: 0, y: 0, width: width, height: height))
            s.draw(in: CGRect(x: 0, y: height / 2 - font.lineHeight / 2,
                              width: width, height: height))
        }
    }
    static func actionSheetStyle() -> UIAlertController.Style {
        if Helpers.isPad() {
            return .alert
        } else {
            return .actionSheet
        }
    }
    static func isLoggedIn() -> Bool {
        guard let userId = UserDefaults.standard.string(forKey: USERID) else {
            return false
        }
        return userId != ""
    }
    
    static func downloadVideoForUser(feed: Feed, completion: @escaping ((Bool) -> ())) {
        guard let url = URL.init(string: feed.url), feed.feedType == "video" else {
            completion(false)
            return
        }
        
        guard FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil else {
            completion(false)
            return
        }
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        
        let destinationURL = URL(fileURLWithPath: String(format: "%@/%@", documentsPath, "\(feed.id).mp4"))
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try? FileManager.default.removeItem(at: destinationURL)
        }
        
        URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let loc = location else {
                completion(false)
                return
            }
            do {
                try FileManager.default.moveItem(at: loc, to: destinationURL)
            } catch {
                print(error)
            }
            
            
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    PHPhotoLibrary.shared().performChanges({
                        PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: destinationURL)
                    }, completionHandler: { (completed, error) in
                        if completed {
                            completion(true)
                        } else {
                            completion(false)
                        }
                    })
                }
            })            
            }.resume()
    }
    static func downloadVideo(feed: Feed, completion: @escaping ((PHAsset?) -> ())) {
        guard let url = URL.init(string: feed.url), feed.feedType == "video" else {
            completion(nil)
            return
        }
        
        guard FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first != nil else {
            completion(nil)
            return
        }
        
        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        
        
        let destinationURL = URL(fileURLWithPath: String(format: "%@/%@", documentsPath, "\(feed.id).mp4"))
        
        if FileManager.default.fileExists(atPath: destinationURL.path) {
            try? FileManager.default.removeItem(at: destinationURL)
        }
        
        URLSession.shared.downloadTask(with: url) { (location, response, error) in
            guard let loc = location else {
                completion(nil)
                return
            }
            do {
                try FileManager.default.moveItem(at: loc, to: destinationURL)
                
                var frames = [UIImage]()
                frames.append(UIImage(named:"watermark")!)
                
                VideoWatermarker().addOverlay(url: destinationURL, frames: frames, framesToSkip: 0, complete: { (url) in
                    
                    if let resultURL = url {
                        PHPhotoLibrary.requestAuthorization({ (status) in
                            if status == .authorized {
                                PHPhotoLibrary.shared().performChanges({
                                    PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: resultURL)
                                }, completionHandler: { (completed, error) in
                                    if completed {
                                        let fetchOptions = PHFetchOptions()
                                        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: true)]
                                        let fetchResult = PHAsset.fetchAssets(with: .video, options: fetchOptions)
                                        completion(fetchResult.lastObject)
                                    }
                                })
                                
                            }
                            
                        })
                    } else {
                        completion(nil)
                    }
                })
                
                
            } catch {
                completion(nil)
            }
            }.resume()
    }
    
    static func timeStampToTimeAbbreviatedStringType(timeStamp: String?, unitStyle: DateComponentsFormatter.UnitsStyle = .abbreviated) -> String {
        guard let tStamp = timeStamp, let dbl = Double(tStamp) else {
            return ""
        }
        
        let date = NSDate(timeIntervalSince1970 : dbl)
        let now = Date()
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = unitStyle
        formatter.maximumUnitCount = 1
        formatter.allowedUnits = [.year, .month, .day, .hour, .minute, .second]
       return formatter.string(from: date as Date, to: now) ?? ""
        
//        if let index = string.range(of: " ")?.lowerBound{
//            string = String(string.prefix(upTo: index))
//            return string
//        }
//        return string
    }
    
    static func timeStampToTimeStringType(timeStamp: String?) -> String {
        
        guard let tStamp = timeStamp,let dbl = Double(tStamp) else {
            return ""
        }
        
        let date = NSDate(timeIntervalSince1970 : dbl)
        let now = Date()
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 2
        formatter.allowedUnits = [.month, .day, .hour, .minute, .second]
        var string = formatter.string(from: date as Date, to: now)
        
        let str : String!
        if let index = string?.range(of: ",")?.lowerBound{
            str = string?.substring(to: index)
            string = str
        }
        if let stringVal = string,!stringVal.isEmpty {
            let finalStr : String! = String(format : "%@ ago",stringVal)
            return finalStr
        }
        return ""
    }
    
    static func timeStampToDateString(timeStamp: String, format: String) -> String {
        let date = Date(timeIntervalSince1970: Double(timeStamp)!)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format //Specify your format that you want
        let strDate = dateFormatter.string(from: date)
        return strDate
    }
    
    static func getCurrentUser(completion: ((Bool) -> Void)? = nil) {
        guard let userId = UserDefaults.standard.string(forKey: USERID) else { return }
        APIController.makeRequest(request: .getUser(userId: userId, otherUserId: userId)) { (response) in
            switch response {
            case .failure(_):
                completion?(false)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? JSONDictionary else { return }
                let user = User.init(json: data)
                try? DataStorage.shared.dataStorage.setObject(result.data, forKey: USERDETAILKEY)
                UserDefaults.standard.set(user.id, forKey: USERID)
                (UIApplication.shared.delegate as? AppDelegate)?.user = user
                completion?(true)
            }
        }
    }
    
    static func uploadProfileImage(image: UIImage, completion: (() -> ())? = nil) {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
        Helpers.uploadToS3(image: image) { (link, _) in
            if let url = link {
                let parameters = [
                    "image_url": url,
                    "user_id": user.id
                ]
                APIController.makeRequest(request: .updateProfileImage(param: parameters), completion: { (response) in
                    Helpers.getCurrentUser()
                    completion?()
                })
            }else {
                completion?()
            }
        }
    }
    
    static func uploadToS3(image: UIImage, completion: @escaping (_ photoURL: String?, _ error: Swift.Error?) -> Void) {
        
        //        let expression = AWSS3TransferUtilityExpression()
        //        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        
        let date = Date()
        let hashableString = String(format: "%f", date.timeIntervalSinceReferenceDate).replacingOccurrences(of: ".", with: "")
        let user = kAppDelegate.user?.id ?? ""
        let fileName = "\(user)-image-\(hashableString)"
        let key = fileName + ".png"
        
        guard let data = image.pngData() else {
            completion(nil, nil)
            return
        }
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    completion(nil, error)
                }else if task.status == .completed {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(task.bucket).appendingPathComponent(key)
                    completion(publicURL?.absoluteString, nil)
                }else {
                    completion(nil, nil)
                }
            })
        }
        
        let expression = AWSS3TransferUtilityUploadExpression()
        //        expression.progressBlock = nil
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        expression.setValue(fileName, forRequestParameter: "filename")
        expression.setValue(".png", forRequestParameter: "fileextension")
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadData(data, bucket: S3BucketName, key: fileName + ".png", contentType: "image/png", expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
            
            return nil
            
        }
        
        //        let transferManager = AWSS3TransferManager.default()
        //        guard let uploadRequest = AWSS3TransferManagerUploadRequest() else { return }
        //        uploadRequest.body = fileURL
        //        uploadRequest.key = fileName + ".png"
        //        uploadRequest.bucket = S3BucketName
        //        uploadRequest.contentType = "image/png"
        //
        //        transferManager.upload(uploadRequest).continueWith { (task) -> Any? in
        //            if let error = task.error {
        //                completion(nil, error)
        //            }
        //            if let _ = task.result {
        //                let url = AWSS3.default().configuration.endpoint.url
        //                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
        //                completion(publicURL?.absoluteString, nil)
        //            } else {
        //                completion(nil, nil)
        //            }
        //
        //            return nil
        //        }
    }
    
    static func uploadVideoToS3(data: Data, completion: @escaping (_ photoURL: String?, _ error: Swift.Error?) -> Void) {
        
        let expression = AWSS3TransferUtilityExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        
        let date = Date()
        let hashableString = String(format: "%f", date.timeIntervalSinceReferenceDate).replacingOccurrences(of: ".", with: "")
        let user = kAppDelegate.user?.id ?? ""
        let fileName = "\(user)-video-\(hashableString)"
        let fileURL = Helpers.generateUrl(fileName: fileName, data: data)
        
        let transferManager = AWSS3TransferManager.default()
        guard let uploadRequest = AWSS3TransferManagerUploadRequest() else { return }
        uploadRequest.body = fileURL
        uploadRequest.key = fileName + ".mp4"
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType = "video/mp4"
        
        transferManager.upload(uploadRequest).continueWith { (task) -> Any? in
            if let error = task.error {
                completion(nil, error)
            }
            if let _ = task.result {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                completion(publicURL?.absoluteString, nil)
            } else {
                completion(nil, nil)
            }
            
            return nil
        }
    }
    
    static func uploadPostToS3(data: Data,progressBlock:AWSS3TransferUtilityProgressBlock?, completion: @escaping (_ fileName: String, _ extension: String, _ url: String?, _ error: Swift.Error?) -> Void) {
        var completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock?
        let date = Date()
        let hashableString = String(format: "%f", date.timeIntervalSinceReferenceDate).replacingOccurrences(of: ".", with: "")
        let user = kAppDelegate.user?.id ?? ""
        let fileName = "\(user)-video-\(hashableString)"
        let fileExtension = ".mp4"
        let key = fileName + fileExtension
        
        completionHandler = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    completion(fileName, fileExtension, nil, error)
                }else if task.status == .completed {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(task.bucket).appendingPathComponent(key)
                    completion(fileName, fileExtension, publicURL?.absoluteString, nil)
                }else {
                    completion(fileName, fileExtension, nil, nil)
                }
            })
        }
        
        
        let expression = AWSS3TransferUtilityUploadExpression()
        expression.progressBlock = progressBlock
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        expression.setValue(fileName, forRequestParameter: "filename")
        expression.setValue(fileExtension, forRequestParameter: "fileextension")
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadData(data, bucket: S3BucketName, key: key, contentType: "video/mp4", expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
            
            return nil
            
        }
    }
    
    static func generateUrl(fileName: String, data: Data) -> URL {
        let fileURL = URL(fileURLWithPath: NSTemporaryDirectory().appending(fileName))
        do {
            try? data.write(to: fileURL, options: .atomic)
        }
        return fileURL
    }
    
    static func uploadAudioToS3(data: Data, completion: @escaping (_ photoURL: String?, _ error: Swift.Error?) -> Void) {
        
        let expression = AWSS3TransferUtilityExpression()
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        
        let date = Date()
        let hashableString = String(format: "%f", date.timeIntervalSinceReferenceDate).replacingOccurrences(of: ".", with: "")
        let user = kAppDelegate.user?.username ?? ""
        let fileName = "\(user)-video-\(hashableString)"
        let fileURL = Helpers.generateUrl(fileName: fileName, data: data)
        
        let transferManager = AWSS3TransferManager.default()
        guard let uploadRequest = AWSS3TransferManagerUploadRequest() else { return }
        uploadRequest.body = fileURL
        uploadRequest.key = fileName + ".m4a"
        uploadRequest.bucket = S3BucketName
        uploadRequest.contentType =  "audio/mp4a-latm"
        
        transferManager.upload(uploadRequest).continueWith { (task) -> Any? in
            if let error = task.error {
                completion(nil, error)
            }
            if let _ = task.result {
                let url = AWSS3.default().configuration.endpoint.url
                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
                completion(publicURL?.absoluteString, nil)
            } else {
                completion(nil, nil)
            }
            
            return nil
        }
    }
    
    static func uploadFileForMsgToS3(data:Data,fileName:String,msgType:String,prgressBlock:@escaping AWSNetworkingUploadProgressBlock, completion: @escaping (_ photoURL: String?, _ error: Swift.Error?) -> Void) {
        
        //let date = Date()
        let hashableString = fileName//String(format: "%f", date.timeIntervalSinceReferenceDate)
        let fileURL = Helpers.generateUrl(fileName: hashableString, data: data)
        
        var uploadKey = hashableString + ".png"
        var fileExtension = ".png"
        var contentType =  "image/png"
        
        switch msgType {
        case ChatType.audio.rawValue:
            uploadKey = hashableString + ".m4a"
            fileExtension = ".m4a"
            contentType =  "audio/mp4a-latm"
        case ChatType.video.rawValue:
            uploadKey = hashableString + ".mp4"
            fileExtension = ".mp4"
            contentType = "video/mp4"
        default:
            break
        }
        
        //        let transferManager = AWSS3TransferManager.default()
        //        guard let uploadRequest = AWSS3TransferManagerUploadRequest() else { return }
        //        uploadRequest.body = fileURL
        //        uploadRequest.key = uploadKey
        //        uploadRequest.bucket = S3BucketName
        //        uploadRequest.contentType =  contentType
        //        uploadRequest.uploadProgress =  prgressBlock
        //
        //
        //        transferManager.upload(uploadRequest).continueWith { (task) -> Any? in
        //            if let error = task.error {
        //                completion(nil, error)
        //            } else if let _ = task.result {
        //                let url = AWSS3.default().configuration.endpoint.url
        //                let publicURL = url?.appendingPathComponent(uploadRequest.bucket!).appendingPathComponent(uploadRequest.key!)
        //                completion(publicURL?.absoluteString, nil)
        //            } else {
        //                completion(nil, nil)
        //            }
        //
        //            return nil
        //        }
        
        
        //        let date = Date()
        //        let hashableString = String(format: "%f", date.timeIntervalSinceReferenceDate).replacingOccurrences(of: ".", with: "")
        //        let user = kAppDelegate.user?.id ?? ""
        //        let fileName = "\(user)-image-\(hashableString)"
        //        let key = fileName + ".png"
        //
        //        guard let data = image.pngData() else {
        //            completion(nil, nil)
        //            return
        //        }
        
        let completionHandler: AWSS3TransferUtilityUploadCompletionHandlerBlock = { (task, error) -> Void in
            DispatchQueue.main.async(execute: {
                if let error = error {
                    completion(nil, error)
                }else if task.status == .completed {
                    let url = AWSS3.default().configuration.endpoint.url
                    let publicURL = url?.appendingPathComponent(task.bucket).appendingPathComponent(uploadKey)
                    completion(publicURL?.absoluteString, nil)
                }else {
                    completion(nil, nil)
                }
            })
        }
        
        let expression = AWSS3TransferUtilityUploadExpression()
        //        expression.progressBlock = nil
        expression.setValue("public-read", forRequestHeader: "x-amz-acl")
        expression.setValue(fileName, forRequestParameter: "filename")
        expression.setValue(fileExtension, forRequestParameter: "fileextension")
        expression.progressBlock = { (task, progress) in
            //            (int64_t bytesSent, int64_t totalBytesSent, int64_t totalBytesExpectedToSend)
            let totalCompleted = progress.completedUnitCount
            let totalExpected = progress.totalUnitCount
            
            prgressBlock(1, totalCompleted, totalExpected)
        }
        let transferUtility = AWSS3TransferUtility.default()
        transferUtility.uploadData(data, bucket: S3BucketName, key: fileName + fileExtension, contentType: contentType, expression: expression, completionHandler: completionHandler).continueWith { (task) -> Any? in
            
            return nil
            
        }
    }
    static func getFileURL(fileName:String) -> String {
        return  "https://s3-us-east-1.amazonaws.com/trajilis/" + fileName
    }
    static func getDocumentsDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    static func setupRatingView(view:CosmosView) {
        view.settings.filledColor = .appRed
        view.settings.emptyBorderColor = .appRed
    }
    static func getMockJSON(fileName:String) -> Any? {
        if let path = Bundle.main.path(forResource: fileName, ofType: "json") {
            do {
                let data = try Data(contentsOf: URL(fileURLWithPath: path), options: .mappedIfSafe)
                let jsonResult = try JSONSerialization.jsonObject(with: data, options: .mutableLeaves)
                return jsonResult
            } catch {
                // handle error
                print(error)
            }
        }
        return nil
    }
    static func getRecordingsPath() -> String {
        let tempDirectoryTemplate = NSTemporaryDirectory() + "Saved"
        let fileManager = FileManager.default
        do {
            try fileManager.createDirectory(atPath: tempDirectoryTemplate, withIntermediateDirectories: true, attributes: nil)
        } catch {
            return NSTemporaryDirectory()
        }
        return tempDirectoryTemplate
    }
    
    static func removeFile(url:URL) {
        let fileManager = FileManager.default
        if fileManager.fileExists(atPath: url.absoluteString) {
            do {
                try fileManager.removeItem(at: url)
            } catch {
                print(error)
            }
        }
    }
    
    static func createDynamicLink(user: User, mode: DynamicLinkMode, completion: @escaping (URL?) -> ()) {
        let modeParam: String
        let image: String
        switch mode {
        case .invite:
            modeParam = "\(mode.rawValue)=\(user.username)"
            image = "https://images.squarespace-cdn.com/content/v1/5c61c86aaadd34057567e497/1549914732441-A4AV1ZA3GHZLIF97LZ4Q/ke17ZwdGBToddI8pDm48kKirrQBMV7BsaOS4YyKHKkRZw-zPPgdn4jUwVcJE1ZvWQUxwkmyExglNqGp0IvTJZUJFbgE-7XRK3dMEBRBhUpzC3eH0ks38PugH36kmZqMXIm-QzUX0Ue5wnAKuGYjuYQD-mvb7zBDzwZkk18I0eZs/image-asset.png?format=500w"
        case .profile:
            modeParam = "\(mode.rawValue)=\(user.id)"
            image = user.profileImage
        }
        guard
            let link = URL(string: "https://www.postagraph.com?\(modeParam)") else { return completion(nil) }
        
        let dynamicLinksDomainURIPrefix = "https://postagraphmarketing.page.link"
        
        let linkBuilder = DynamicLinkComponents(link: link, domainURIPrefix: dynamicLinksDomainURIPrefix)
        
        linkBuilder?.iOSParameters = DynamicLinkIOSParameters(bundleID: Bundle.main.bundleIdentifier!)
        linkBuilder?.iOSParameters?.appStoreID = "1246769768"
        
        linkBuilder?.socialMetaTagParameters = DynamicLinkSocialMetaTagParameters()
        linkBuilder?.socialMetaTagParameters?.title = "Hey! check this awesome app."
        linkBuilder?.socialMetaTagParameters?.descriptionText = "Share your experiences and create your experiences with this app."
        linkBuilder?.socialMetaTagParameters?.imageURL = URL(string: image)
        
        guard let longDynamicLink = linkBuilder?.url else { return completion(nil) }
        DynamicLinkComponents.shortenURL(longDynamicLink, options: nil) { url, warnings, error in
            print(error, warnings, url)
            completion(url)
        }
    }
    
}

enum DynamicLinkMode: String {
    case profile = "profile"
    case invite = "invite"
}

