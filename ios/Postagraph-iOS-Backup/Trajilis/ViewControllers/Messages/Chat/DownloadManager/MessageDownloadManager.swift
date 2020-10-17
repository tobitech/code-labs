//
//  MessageManager.swift
//  Trajilis
//
//  Created by bharats802 on 24/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

protocol MessageDownloadManagerDelegate:class {
    func didFinishDownloading(message:Message?)
    func didFailDownloading(message:Message?,error:Error)
    func updateDisplay(message:Message?, progress: Float, totalSize : String)
}


class MessageDownloadManager: NSObject {
    
    static let shared = MessageDownloadManager()
    let downloadService = DownloadService()
    
    weak var delegate:MessageDownloadManagerDelegate?
    
    // Create downloadsSession here, to set self as delegate
    lazy var downloadsSession: URLSession = {
        //    let configuration = URLSessionConfiguration.default
        let configuration = URLSessionConfiguration.background(withIdentifier: "bgSessionConfiguration")
        return URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
    }()
    
    override init() {
        super.init()
        self.downloadService.downloadsSession = self.downloadsSession
    }
    
    
}
extension MessageDownloadManager: URLSessionDownloadDelegate {
    
    // Stores downloaded file
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        // 1
        guard let sourceURL = downloadTask.originalRequest?.url else { return }
        let download = downloadService.activeDownloads[sourceURL]
        downloadService.activeDownloads[sourceURL] = nil
        // 2
        guard let destinationURL = download?.message.localFilePath() else {
            return
        }
        print(destinationURL)
        // 3
        let fileManager = FileManager.default
        try? fileManager.removeItem(at: destinationURL)
        do {
            try fileManager.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Could not copy file to disk: \(error.localizedDescription)")
        }
        // 4
        if let message = download?.message {
            DispatchQueue.main.async {
                self.delegate?.didFinishDownloading(message: message)
                //self.tblView.reloadRows(at: [index], with: .none)
            }
        }
    }
    
    // Updates progress info
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64, totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        // 1
        guard let url = downloadTask.originalRequest?.url,
            let download = downloadService.activeDownloads[url]  else { return }
        // 2
        download.progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        // 3
        let totalSize = ByteCountFormatter.string(fromByteCount: totalBytesExpectedToWrite,
                                                  countStyle: .file)
        // 4
        DispatchQueue.main.async {
            self.delegate?.updateDisplay(message: download.message, progress: download.progress, totalSize: totalSize)
        }
    }
    
}

// MARK: - URLSessionDelegate

extension MessageDownloadManager: URLSessionDelegate {
    
    // Standard background session handler
    func urlSessionDidFinishEvents(forBackgroundURLSession session: URLSession) {
        DispatchQueue.main.async {
            if let appDelegate = UIApplication.shared.delegate as? AppDelegate,
                let completionHandler = appDelegate.backgroundSessionCompletionHandler {
                appDelegate.backgroundSessionCompletionHandler = nil
                completionHandler()
            }
        }
    }
    
}
