//
//  ChatViewControllerVC+VoiceRecording.swift
//  Trajilis
//
//  Created by bharats802 on 22/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import AVFoundation

extension ChatViewController: AVAudioRecorderDelegate {
    
    @IBAction func longPressed(sender: UILongPressGestureRecognizer)
    {
        print("longed..")
        
        if sender.state == .ended {
            print("UIGestureRecognizerStateEnded")
            //Do Whatever You want on End of Gesture
            self.stopRecording()
            
        }
        else if sender.state == .began {
            self.startRecording()
            
            print("UIGestureRecognizerStateBegan.")
            //Do Whatever You want on Began of Gesture
        }
        //Different code
    }
    func removeRecordingView() {
        self.voiceViewWidthConstraint.constant = 50
        self.imgMic.isHidden = true
        self.imgMic.stopAnimating()


    }
    func stopRecording() {
        self.imgMic.stopAnimating()
        self.imgMic.isHidden = true
        self.finishRecording(success: true)
    }
    func haveRecordPermission() -> Bool {
        
       
        return false
    }
    func startRecording() {
        recordingSession = AVAudioSession.sharedInstance()
        do {
            try recordingSession?.setCategory(.playAndRecord, mode: .spokenAudio)
            try recordingSession?.setActive(true)
            
            switch AVAudioSession.sharedInstance().recordPermission {
            case AVAudioSession.RecordPermission.granted:
                self.voiceViewWidthConstraint.constant = UIScreen.main.bounds.width
                self.imgMic.isHidden = false
                self.imgMic.startAnimating()
                self.recordVoice()
                
            case AVAudioSession.RecordPermission.denied:
                self.showAlert(message: "Please allow recording permissions to the app from your phone settings.")
            case AVAudioSession.RecordPermission.undetermined:
                recordingSession?.requestRecordPermission() { allowed in
                }
            }
            
            
            
        } catch {
            // failed to record!
        }
    }
    
    func recordVoice() {
        let fileName = self.getNewMsgFileName()
        self.audioFilename = Helpers.getDocumentsDirectory().appendingPathComponent("\(fileName).m4a")
        
        if let filename = self.audioFilename {
            let settings = [
                AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                AVSampleRateKey: 12000,
                AVNumberOfChannelsKey: 1,
                AVEncoderAudioQualityKey: AVAudioQuality.max.rawValue
            ]
            
            do {
                audioRecorder = try AVAudioRecorder(url: filename, settings: settings)
                audioRecorder?.delegate = self
                audioRecorder?.record()
                if let timer = self.audioTimer {
                    timer.invalidate()
                    self.audioTimer = nil
                }
                self.audioTimer = Timer.scheduledTimer(timeInterval: 0.1, target:self, selector:#selector(self.updateAudioMeter(timer:)), userInfo:nil, repeats:true)
                
            } catch {
                finishRecording(success: false)
            }
        }
        
    }
    @objc func updateAudioMeter(timer: Timer)
    {
        if let recorder = self.audioRecorder {
            if recorder.isRecording {
                let hr = Int((recorder.currentTime / 60) / 60)
                let min = Int(recorder.currentTime / 60)
                let sec = Int(recorder.currentTime.truncatingRemainder(dividingBy: 60))
                let totalTimeString = String(format: "%02d:%02d:%02d", hr, min, sec)
                self.lblAudioTime.text = totalTimeString
                recorder.updateMeters()
            } else {
                if let timer = self.audioTimer {
                    timer.invalidate()
                    self.audioTimer = nil
                }
            }
        } else {
            if let timer = self.audioTimer {
                timer.invalidate()
                self.audioTimer = nil
            }
        }
    }
    func finishRecording(success: Bool) {
        
        guard let audioRecorder = self.audioRecorder else {
            return
        }
        audioRecorder.stop()
        self.audioRecorder = nil
        if let timer = self.audioTimer {
            timer.invalidate()
            self.audioTimer = nil
        }
        self.lblAudioTime.text = nil
        self.removeRecordingView()
        if success,let audioFile = self.audioFilename {
            let alertController = UIAlertController(title: "Voice Recorded", message: nil, preferredStyle: Helpers.actionSheetStyle())
            alertController.view.tintColor = UIColor.black
            let cameraPhotoAction = UIAlertAction(title: "Send Audio", style: .default) { (action:UIAlertAction) in
                
                let fileName = audioFile.lastPathComponent
                let msgData = Helpers.getFileURL(fileName: fileName)
                self.sendMessage(data: msgData, msgType: .audio)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
            
            alertController.addAction(cameraPhotoAction)
            alertController.addAction(cancel)
            self.present(alertController, animated: true, completion: nil)
        } else {
            self.showAlert(message: "App faced error while recording audio. Please try again later.")
        }
        kAppDelegate.setupSound(isPrimary: false)
    }
    
    
    // AVAudioSession Delegate
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if !flag {
            finishRecording(success: false)
        }
    }
}






class TRAudioPlayer:AVAudioPlayer,AVAudioPlayerDelegate {
    var msgId:String?
    weak var cell:AudioChatCell?
    
    var displayLink:CADisplayLink?
    class func getPlayerFor(fileURL:URL, msg:Message,cell:AudioChatCell) -> TRAudioPlayer? {
        do {            
            let audioPlayer = try TRAudioPlayer(contentsOf: fileURL)
            
            let recordingSession = AVAudioSession.sharedInstance()
            do {
                try recordingSession.setCategory(.playback, mode: .spokenAudio)
            } catch {
                print(error)
            }
            
            
            audioPlayer.prepareToPlay()
            audioPlayer.msgId = msg.messageId
            audioPlayer.numberOfLoops = 0
            audioPlayer.play()
            cell.btnPlay.setImage(UIImage(named:"an_pause"), for: .normal)
            audioPlayer.cell = cell
            cell.slider.value = 0
            audioPlayer.displayLink = CADisplayLink(target: audioPlayer, selector: #selector(updateSliderProgress))
            audioPlayer.displayLink?.add(to: RunLoop.current, forMode: RunLoop.Mode.default)
            audioPlayer.delegate = audioPlayer
            audioPlayer.currentTime =  TimeInterval((cell.slider.value * Float(audioPlayer.duration)) / 100.0)
            cell.slider.addTarget(audioPlayer, action: #selector(sliderValueChanged(sender:)), for: .valueChanged)
            cell.slider.minimumValue = 0
            cell.slider.maximumValue = 100
            
            return audioPlayer
        } catch {
            print(error)
        }
        return nil
    }
    @objc func sliderValueChanged(sender:UISlider) {
        if let slider = self.cell?.slider,!slider.isTracking {
            self.currentTime =  TimeInterval((slider.value * Float(self.duration)) / 100.0)
        }
        
    }
    @objc func updateSliderProgress() {
        if let slider = self.cell?.slider,!slider.isTracking {
            let progress = self.currentTime * 100.0  / self.duration
            self.cell?.slider.setValue(Float(progress), animated: false)

        }
    }
    
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) {
        self.cell?.btnPlay.setImage(UIImage(named:"enabledButton"), for: .normal)
        
    }
    
}
