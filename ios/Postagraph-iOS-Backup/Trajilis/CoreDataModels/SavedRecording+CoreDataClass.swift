//
//  SavedRecording+CoreDataClass.swift
//  Trajilis
//
//  Created by bharats802 on 23/05/19.
//  Copyright © 2019 Johnson. All rights reserved.
//
//

import Foundation
import CoreData
import AVKit
import AVFoundation

@objc(SavedRecording)
public class SavedRecording: NSManagedObject {

    func  getVideoURL() -> URL? {
        if let file = filepath {
            let path = Helpers.getRecordingsPath() + "/\(file)"
            let outputURL = URL(fileURLWithPath: path)
            return outputURL
        }
        return nil
    }
    
    class func getNewSaving() -> SavedRecording? {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.getContext() {
            let entity = NSEntityDescription.entity(forEntityName: "SavedRecording", in: context)
            let newUser = NSManagedObject(entity: entity!, insertInto: context)
            return newUser as? SavedRecording
        }
        return nil
    }
    class func getSavedRecordings() -> [SavedRecording]? {
        if let context = (UIApplication.shared.delegate as? AppDelegate)?.getContext() {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedRecording")
            //request.predicate = NSPredicate(format: "age = %@", "12")
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                return result as? [SavedRecording]
            } catch {
                print("Failed")
            }
            
        }
        return nil
    }
    
    func getThumbnail() -> UIImage? {        
        if let url1 = self.getVideoURL() {
            let asset1 = AVURLAsset(url: url1)
            let imageGenerator = AVAssetImageGenerator(asset: asset1)
            imageGenerator.appliesPreferredTrackTransform = true
            do {
                let cgImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 0, timescale: 1), actualTime: nil)
                return UIImage.init(cgImage: cgImage)
            } catch {
                print(error)
            }
        }
        return nil
    }
    class func removeOldRecordings() {
        
        return

        if let context = (UIApplication.shared.delegate as? AppDelegate)?.getContext() {
            let request = NSFetchRequest<NSFetchRequestResult>(entityName: "SavedRecording")
            let today = Date()//.timeIntervalSince1970
            let beforeDays = today.dateByAddingDays(days: -1)
            if let dblValue = beforeDays?.timeIntervalSince1970 {
                request.predicate = NSPredicate(format: "recordedOn < %f", dblValue)
            }
            request.returnsObjectsAsFaults = false
            do {
                let result = try context.fetch(request)
                if let recordings =  result as? [SavedRecording] {
                    for reco in recordings {
                        if let vid = reco.getVideoURL() {
                            Helpers.removeFile(url: vid)
                        }
                        context.delete(reco)
                    }
                    try context.save()
                }
            } catch {
                print("Failed")
            }
        }
    }
}
