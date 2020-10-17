//
//  VideoCropperViewController.swift
//  Trajilis
//
//  Created by bibek timalsina on 10/7/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import AVKit
import MobileCoreServices

class VideoCropperViewController: BaseVC {
    
    var videoURL: URL!
    var maxDuration: Int = 0
    var completion: ((URL) -> ())?
    
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var cropButton: UIButton!
    @IBOutlet weak var videoView: AVPlayerView!
    @IBOutlet weak var sliderView: UIView!
    @IBOutlet weak var sliderLeftHandleImageView: UIImageView!
    @IBOutlet weak var sliderRightHandleImageView: UIImageView!
    @IBOutlet weak var startWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var endWidthConstraint: NSLayoutConstraint!
    @IBOutlet weak var startLabel: UILabel!
    @IBOutlet weak var endLabel: UILabel!
    @IBOutlet weak var maxDurationLabel: UILabel!
    @IBOutlet weak var totalSelectedTimeLabel: UILabel!
    
    private var observer: NSObjectProtocol?
    private var player: AVPlayer!
    private var asset: AVAsset!
    private var videoLength: CGFloat = 30
    private var startTime: CGFloat = 0 {
        didSet {
            startLabel.text = "\(startTime.rounded(toPlaces: 1))s"
            totalSelectedTimeLabel.text = "\((endTime-startTime).rounded(toPlaces: 1))s"
            setCropEnable()
            player?.seek(to: CMTime(seconds: Double(startTime), preferredTimescale: 1))
        }
    }
    private var endTime: CGFloat = 0 {
        didSet {
            endLabel.text = "\(endTime.rounded(toPlaces: 1))s"
            totalSelectedTimeLabel.text = "\((endTime-startTime).rounded(toPlaces: 1))s"
            setCropEnable()
            player?.seek(to: CMTime(seconds: Double(endTime), preferredTimescale: 1))
        }
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        play(nil)
        asset = AVURLAsset(url: videoURL)
        videoLength = CGFloat(asset.duration.seconds)
        endTime = videoLength
        startTime = 0
        
        let leftPanGestureRecognizer  = UIPanGestureRecognizer(target: self, action: #selector(self.leftPanned(_:)))
        sliderLeftHandleImageView.addGestureRecognizer(leftPanGestureRecognizer)
        let rightPanGestureRecognizer  = UIPanGestureRecognizer(target: self, action: #selector(self.rightPanned(_:)))
        sliderRightHandleImageView.addGestureRecognizer(rightPanGestureRecognizer)
        sliderView.set(cornerRadius: 4)
        maxDurationLabel.text = "\(maxDuration) seconds max video length"
        maxDurationLabel.isHidden = maxDuration == 0
        
        setCropEnable()
        createImageFrames()
        showNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
    }
    
    private func setCropEnable() {
        let enabled = (maxDuration == 0 && (endTime - startTime < videoLength)) || (maxDuration > 0 && (endTime - startTime <= CGFloat(maxDuration)))
        cropButton.isEnabled = enabled
        cropButton.alpha = enabled ? 1 : 0.6
    }
    
    func cropVideo() {
        
        let manager = FileManager.default
        
        guard let documentDirectory = try? manager.url(for: .documentDirectory,
                                                       in: .userDomainMask,
                                                       appropriateFor: nil,
                                                       create: true) else {return}
        
        let length = Float(asset.duration.value) / Float(asset.duration.timescale)
        print("video length: \(length) seconds")
        
        let start = startTime
        let end = endTime
        print(documentDirectory)
        var outputURL = documentDirectory.appendingPathComponent("output")
        do {
            try manager.createDirectory(at: outputURL, withIntermediateDirectories: true, attributes: nil)
            //let name = hostent.newName()
            outputURL = outputURL.appendingPathComponent("croppedVideo.mp4")
        }catch let error {
            print(error)
        }
        
        //Remove existing file
        _ = try? manager.removeItem(at: outputURL)
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPresetHighestQuality) else {return}
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        
        let startTime = CMTime(seconds: Double(start ), preferredTimescale: 1000)
        let endTime = CMTime(seconds: Double(end ), preferredTimescale: 1000)
        let timeRange = CMTimeRange(start: startTime, end: endTime)
        
        exportSession.timeRange = timeRange
        spinner(with: "Processing...", blockInteraction: true)
        exportSession.exportAsynchronously {
            DispatchQueue.main.async {
                self.hideSpinner()
                switch exportSession.status {
                case .completed:
                    print("exported at \(outputURL)")
                    self.completion?(outputURL)
                    self.navigationController?.popViewController(animated: true)
                    return
                case .failed:
                    print("failed \(String(describing: exportSession.error))")
                case .cancelled:
                    print("cancelled \(String(describing: exportSession.error))")
                    
                default: break
                }
                self.showAlert(message: kDefaultError)
            }
        }
    }
    
    private func createImageFrames() {
        let totalFrames = 6
        //creating assets
        let assetImgGenerate : AVAssetImageGenerator    = AVAssetImageGenerator(asset: asset)
        assetImgGenerate.appliesPreferredTrackTransform = true
        assetImgGenerate.requestedTimeToleranceAfter    = CMTime.zero;
        assetImgGenerate.requestedTimeToleranceBefore   = CMTime.zero;
        
        
        assetImgGenerate.appliesPreferredTrackTransform = true
        let thumbTime: CMTime = asset.duration
        let thumbtimeSeconds  = Int(CMTimeGetSeconds(thumbTime))
        let maxLength         = "\(thumbtimeSeconds)" as NSString
        
        let thumbAvg  = thumbtimeSeconds/totalFrames
        var startTime = 1
        var startXPosition:CGFloat = 0.0
        
        //loop for 6 number of frames
        for _ in 0..<totalFrames {
            
            let frameImageView = UIImageView()
            frameImageView.contentMode = .scaleAspectFill
            frameImageView.clipsToBounds = true
            
            let xPositionForEach = self.sliderView.frame.width/CGFloat(totalFrames)
            frameImageView.frame = CGRect(x: CGFloat(startXPosition), y: CGFloat(0), width: xPositionForEach, height: CGFloat(self.sliderView.frame.height))
            do {
                let time:CMTime = CMTimeMakeWithSeconds(Float64(startTime),preferredTimescale: Int32(maxLength.length))
                let img = try assetImgGenerate.copyCGImage(at: time, actualTime: nil)
                let image = UIImage(cgImage: img)
                frameImageView.image = image
            }
            catch {
                print("Image generation failed with error (error)")
            }
            
            startXPosition = startXPosition + xPositionForEach
            startTime = startTime + thumbAvg
            sliderView.insertSubview(frameImageView, at: 0)
        }
        
    }
    
    private var initialStartWidth: CGFloat = 0
    @objc private func leftPanned(_ gesture: UIPanGestureRecognizer) {
        let maxConstraint = sliderView.frame.width - 20.5*2 - endWidthConstraint.constant
        switch gesture.state {
        case .began:
            initialStartWidth = startWidthConstraint.constant
        case .changed:
            let translationX = gesture.translation(in: sliderView).x
            let new = max(min(initialStartWidth + translationX, maxConstraint), 0)
            startWidthConstraint.constant = new
            
            let total = sliderView.frame.width
            let currentValue = startWidthConstraint.constant
            let percent =  currentValue/total
            startTime = percent * videoLength
        default: break
        }
    }
    
    private var initialEndWidth: CGFloat = 0
    @objc private func rightPanned(_ gesture: UIPanGestureRecognizer) {
        let maxConstraint = sliderView.frame.width - 20.5*2 - startWidthConstraint.constant
        switch gesture.state {
        case .began:
            initialEndWidth = endWidthConstraint.constant
        case .changed:
            let translationX = -gesture.translation(in: sliderView).x
            print(translationX)
            let new = max(min(initialEndWidth + translationX, maxConstraint) , 0)
            endWidthConstraint.constant = new
            
            let total = sliderView.frame.width
            let currentValue = endWidthConstraint.constant
            let percent =  currentValue/total
            endTime = videoLength - (percent * videoLength)
        default: break
        }
    }
    
    @IBAction func mute(_ sender: Any) {
        muteButton.isSelected = !muteButton.isSelected
        player.isMuted = muteButton.isSelected
        kAppDelegate.setupSound(isPrimary: !player.isMuted)
    }
    
    @IBAction func crop(_ sender: Any) {
        cropVideo()
    }
    
    private var isPlaying: Bool = true
    @IBAction func play(_ sender: UIButton?) {
        isPlaying = !isPlaying
        sender?.setTitle(isPlaying ? "Pause" : "Play", for: .normal)
        
        if player == nil {
            let playerItem = AVPlayerItem(url: videoURL)
            player = AVPlayer(playerItem: playerItem)
            guard let playerLayer = videoView.layer as? AVPlayerLayer else { return }
            playerLayer.player = player
            playerLayer.frame = view.bounds
            playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
            player.isMuted = true
        }
        
        if isPlaying {
            player.seek(to: CMTime(seconds: Double(startTime), preferredTimescale: 1))
            player.play()
            observer = NotificationCenter.default
                .addObserver(
                    forName: .AVPlayerItemDidPlayToEndTime,
                    object: player.currentItem,
                    queue: nil,
                    using: {[weak sender, weak self] (_) in
                        DispatchQueue.main.async {
                            self?.isPlaying = false
                            sender?.setTitle("Play", for: .normal)
                        }
                })
        }else {
            player.pause()
        }
    }
    
}
