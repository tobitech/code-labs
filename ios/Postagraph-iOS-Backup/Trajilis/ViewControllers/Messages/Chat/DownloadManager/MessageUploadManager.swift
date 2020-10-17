//
//  MessageUploadManager.swift
//  Trajilis
//
//  Created by bharats802 on 24/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Foundation

protocol MessageUploadManagerDelegate:class {
    func didFinishUploading(message:Message?)
    func didFailUploading(message:Message?,error:Error)
    func updateUploadDisplay(message:Message?, progress: Int64, totalSize : Int64)
}

class MessageUploadManager: NSObject {
    
    static let shared = MessageUploadManager()
    
    weak var delegate:MessageUploadManagerDelegate?
    var activeUploads:[String:MessageUpload] = [String:MessageUpload]()
    
    func uploadMedia(message:Message) {
        let upload = MessageUpload(message: message)
        upload.uploadCompletionBlock = { (message,filePath,error) in
            self.activeUploads[message.messageId] = nil
            if let err = error {
                self.delegate?.didFailUploading(message: message, error: err)
            } else {
                self.delegate?.didFinishUploading(message: message)
            }
        }
        upload.updateProgressBlock = {  (message,byteSent,totalBytes) in
            self.delegate?.updateUploadDisplay(message: message, progress:byteSent , totalSize: totalBytes)
        }
        activeUploads[message.messageId] = upload
        upload.upload()
    }
    
}


