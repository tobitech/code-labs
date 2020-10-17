//
//  ChatViewControllerVC+VoiceRecording.swift
//  Trajilis
//
//  Created by bharats802 on 22/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import AVFoundation

extension ChatViewController: MessageDownloadManagerDelegate {
    func didFinishDownloading(message: Message?) {
        if let msg = message {
            if let indexPath = self.getIndexPathForMsg(msg: msg) {
                self.tblView.reloadRows(at: [indexPath], with: .none)
            }
        }
    }
    
    func didFailDownloading(message: Message?, error: Error) {
        print("fail downloading for \(message)")
    }
    
    func updateDisplay(message: Message?, progress: Float, totalSize: String) {
        if let msg = message {
            if let indexPath = self.getIndexPathForMsg(msg: msg) {
                if let cell = self.tblView.cellForRow(at: indexPath) as? ChatBaseCell {
                    cell.updateDisplay(progress: progress, totalSize: totalSize)
                }
            }
        }
    }
}

extension ChatViewController: MessageUploadManagerDelegate {
    
    func didFinishUploading(message: Message?) {
        DispatchQueue.main.async {
            if let msg = message {
                if var msgData = msg.jsonData {
                    msgData["_id"] = nil
                    
                    let jsonData = try? JSONSerialization.data(withJSONObject: msgData, options: [])
                    let jsonString = String(data: jsonData!, encoding: .utf8)
                    print(jsonString)
                    SocketIOManager.shared.socket.emit("sendMessage", msgData)
                }
                if let indexPath = self.getIndexPathForMsg(msg: msg) {
                    self.tblView.reloadRows(at: [indexPath], with: .none)
                }
            }
        }
    }
    
    func didFailUploading(message: Message?, error: Error) {
        print("fail downloading for \(message)")
    }
    
    func updateUploadDisplay(message: Message?, progress: Int64, totalSize: Int64) {
        print("got updateUploadDisplay")
        DispatchQueue.main.async {
            if let msg = message {
                if let indexPath = self.getIndexPathForMsg(msg: msg) {
                    if let cell = self.tblView.cellForRow(at: indexPath) as? ChatBaseCell {
                        cell.updateDisplay(progress: Float(progress) / Float(totalSize), totalSize: "")
                    }
                }
            }
        }
    }

}







