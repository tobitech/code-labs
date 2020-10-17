//
//  VideoRecordModel.swift
//  Trajilis
//
//  Created by bharats802 on 23/05/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation


class VideoRecordModel {
    var videoURL:URL?
    private var image:UIImage?
    var recordedOn:Double = 0 // timestamp
    
    func getThumbnail() -> UIImage? {
        if let img = self.image {
            return img
        } else {
            if let url1 = videoURL {
                let asset1 = AVURLAsset(url: url1)
                let imageGenerator = AVAssetImageGenerator(asset: asset1)
                imageGenerator.appliesPreferredTrackTransform = true
                do {
                    let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                    image = UIImage.init(cgImage: cgImage)
                } catch {
                    print(error)
                }
                return self.image
            }
        }
        return self.image
    }
    class func getRecords(urls: [URL]?) -> [VideoRecordModel] {
        
        var records = [VideoRecordModel]()
        guard let urls = urls else {
            return records
        }
        for url in urls {
            let record = VideoRecordModel()
            record.videoURL = url
            records.append(record)
        }
        return records
    }
    
}
