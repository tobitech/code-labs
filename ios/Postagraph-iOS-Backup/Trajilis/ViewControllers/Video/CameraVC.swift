//
//  CameraVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 14/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation
import SpriteKit
import Photos
import CoreImage

enum kCameraMode:Int {
    case Video = 0
    case Image = 1
}
enum kCameraFlash:Int {
    case flash_off = 0
    case flash_on = 1
    case flash_auto = 2
}


final class CameraVC: BaseVC {
    
    var isNormalMode: Bool = true
    var timeCounter: Int = 0
    var globalTimeCounter: Int = 0
    private var images: [UIImage] = [] {
        didSet {
            collectionView.reloadData()
        }
    }
    
    @IBOutlet weak var modeIndicator: UIView!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet var progressView: CircularLoaderView!
    @IBOutlet var recordButton: UIButton!
    @IBOutlet var timeLabel: UILabel!
    @IBOutlet var progressBar: UIProgressView!
    @IBOutlet var cancelButton: UIButton!
    @IBOutlet weak var circleProgressMiddleView: UIView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var normalModeButton: UIButton!
    @IBOutlet weak var crousalModeButton: UIButton!
    
    @IBOutlet var previewView: CKFPreviewView! {
        didSet {
           
//            let mode = (640, 480, 30)
            let mode = (1280,720,30)
//            let mode = (1920,1080,30)
            switch self.cameraMode {
            case .Image:
                let session = CKFPhotoSession()
                self.previewView.session = session
                session.delegate = self
            default:
                let session = CKFVideoSession()
                self.previewView.session = session
                session.delegate = self
                session.setWidth(mode.0, height: mode.1, frameRate: mode.2)
            }
            
            self.previewView.autorotate = true
            self.previewView.previewLayer?.videoGravity = .resizeAspectFill
        }
    }

    
    @IBOutlet var flipCameraButton: UIButton!
    @IBOutlet var flashButton: UIButton!
    
    //let camera = CameraManager()
    var timer: Timer?

    var close:(() -> Void)?
    var didFinishRecording:((URL?, UIImage?) -> Void)?

    var recordType: VideoRecordType = .feed
    
    var cameraMode:kCameraMode = kCameraMode.Video
    var didCaptureImage:((UIImage?,Error?) -> Void)?
    var didRecordVideo:((URL?,Error?) -> Void)?
    private var tempVideoURL: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        if self.cameraMode == .Video {
            let longGestiure = UILongPressGestureRecognizer(target: self, action: #selector(handleBtnLongPressGesture(_:)))
            recordButton.addGestureRecognizer(longGestiure)
            if recordType == .feed {
                scrollView.isHidden = false
                modeIndicator.isHidden = false
            }
        } else {
            let tapGestiure = UITapGestureRecognizer(target: self, action:  #selector(handleBtnTapPressGesture(_:)))
            recordButton.addGestureRecognizer(tapGestiure)
        }
        scrollView.delegate = self
        scrollView.decelerationRate = UIScrollView.DecelerationRate(rawValue: 0)
        collectionView.dataSource = self
        circleProgressMiddleView.rounded()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.previewView.session?.start()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.previewView.session?.stop()
        UIApplication.shared.isStatusBarHidden = false
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        timeLabel.isHidden = true
        progressView.progress = 0
        progressBar.progress = 0
        hideNavigationBar()
        UIApplication.shared.isStatusBarHidden = true
        cancelButton.isHidden = false
    }

    
    private func getSession() -> CKFSession? {
        if let session = self.previewView.session as? CKFVideoSession {
            return session
        } else if let session = self.previewView.session as? CKFPhotoSession {
            return session
        }
        return nil
    }
    private func setupCamera() {
            addCameraToView()
    }


    private func addCameraToView() {

    }


    @IBAction func cancelTapped(_ sender: Any) {
        self.navigationController?.dismiss(animated: true) {}
    }

    @IBAction func flipCamera(_ sender: Any) {
        if let session = self.previewView.session as? CKFVideoSession {
            
            session.cameraPosition = session.cameraPosition == .front ? .back : .front
            
        } else if let session = self.previewView.session as? CKFPhotoSession {
            session.cameraPosition = session.cameraPosition == .front ? .back : .front
        }
    }
    @IBAction func flashTapped(_ sender: Any) {
        
        if let session = self.previewView.session as? CKFVideoSession {
            
            
            if let btn = sender as? UIButton {
                
                btn.tag = btn.tag + 1
                if (btn.tag > 2) {
                    btn.tag = 0
                }
                switch btn.tag {
                    
                case kCameraFlash.flash_off.rawValue:
                    flashButton.setImage(UIImage(named: "flash_off"), for: .normal)
                    session.flashMode = .off
                case kCameraFlash.flash_on.rawValue:
                    flashButton.setImage(UIImage(named: "flash_on"), for: .normal)
                    session.flashMode = .on
                case kCameraFlash.flash_auto.rawValue:
                    flashButton.setImage(UIImage(named: "flash_auto"), for: .normal)
                    session.flashMode = .auto
                default:
                    btn.tag = kCameraFlash.flash_off.rawValue
                    flashButton.setImage(UIImage(named: "flash_off"), for: .normal)
                    session.flashMode = .off
                }
                
                
            }
        } else if let session = self.previewView.session as? CKFPhotoSession {
            if let btn = sender as? UIButton {
                
                btn.tag = btn.tag + 1
                if (btn.tag > 2) {
                    btn.tag = 0
                }
                switch btn.tag {
                    
                case kCameraFlash.flash_off.rawValue:
                    flashButton.setImage(UIImage(named: "flash_off"), for: .normal)
                    session.flashMode = .off
                case kCameraFlash.flash_on.rawValue:
                    flashButton.setImage(UIImage(named: "flash_on"), for: .normal)
                    session.flashMode = .on
                case kCameraFlash.flash_auto.rawValue:
                    flashButton.setImage(UIImage(named: "flash_auto"), for: .normal)
                    session.flashMode = .auto
                default:
                    btn.tag = kCameraFlash.flash_off.rawValue
                    flashButton.setImage(UIImage(named: "flash_off"), for: .normal)
                    session.flashMode = .off
                }
            }
        }
        
        
    }
    @objc private func handleBtnTapPressGesture(_ gesture: UILongPressGestureRecognizer) {
        
        if let session = self.getSession() as? CKFPhotoSession {
            session.capture({ [weak self] (image, _) in
                self?.didCaptureImage?(image,nil)
                self?.dismiss(animated: true, completion: nil)
            }) { [weak self](_) in
                self?.showAlert(message: "Image capture failed. Please try again.")
            }
        }
    }
    
    @objc private func handleBtnLongPressGesture(_ gesture: UILongPressGestureRecognizer) {
        switch gesture.state {
        case .began:
            startRecording()
        case .ended:
            endRecording()
        default:
            break
        }
    }

    private func startRecording() {
        guard let session = getSession() as? CKFVideoSession else {
            return
        }
        timer?.invalidate()
        self.globalTimeCounter = 0
        self.timeCounter = 0
        circleProgressMiddleView.backgroundColor = .appRed
        progressBar.isHidden = false
        cancelButton.isHidden = true
//        progressView.progressInsideFillColor = UIColor.appRed
        //timeLabel.isHidden = false
        
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (_) in
            self.timeCounter += 1
            self.globalTimeCounter  += 1
            //self.progressView.progress = Double(counter)/self.recordType.counter
            let progress = Float(Double(self.timeCounter)/self.recordType.counter)
            if progress > self.progressBar.progress {
                self.progressBar.progress =  progress
                UIView.animate(withDuration: 1, delay: 0.0, options: [.curveLinear], animations: {
                    self.progressBar.layoutIfNeeded()
                }, completion: { finished in
                    //                print("animation completed")
                })
            }else {
                self.progressBar.progress =  progress
            }
            
//            let sting = String(format: "00:%02d",self.timeCounter)
//            self.timeLabel.text = sting
            if Double(self.timeCounter) == self.recordType.counter {
                self.getImageFromVideo()
            }
            if self.isNormalMode {
                if Double(self.timeCounter) == self.recordType.counter {
                    self.endRecording()
                }
            } else {
                if Double(self.globalTimeCounter) == 4 * self.recordType.counter {
                    self.endRecording()
                }
            }
        })
        timer?.fire()
      
        self.animateProgress()
        
        tempVideoURL = session.record({ (url) in
            self.completeVideoRecording(url: url)
            //self.performSegue(withIdentifier: "Preview", sender: url)
        }) { (_) in
            //
        }
    }
    func animateProgress() {
        self.progressView.animate(toAngle: 360, duration: self.recordType.counter) { (complete) in
            print("got it")
            self.progressView.stopAnimation()
            guard let session =  self.getSession() as? CKFVideoSession else {
                return
            }
            if session.isRecording {
                self.timeCounter = 0
                self.animateProgress()
            }
            
        }
    }
    func completeVideoRecording(url:URL?) {
        if self.recordType == .simpleCamera {
            DispatchQueue.main.async {
                self.hideSpinner()
                self.didRecordVideo?(url,nil)
                self.dismiss(animated: true, completion: nil)
            }
        } else {
            if let url1 = url {
                let asset1 = AVURLAsset(url: url1)
                //if asset1.duration.seconds > self.recordType.counter { //
                var videoURLs = [URL]()
                var startPoint:Double = 0
                let group = DispatchGroup()
                while startPoint < asset1.duration.seconds {
                    group.enter()
                    var vidDuration = self.recordType.counter
                    let tDuration = startPoint + vidDuration
                    if tDuration > asset1.duration.seconds {
                        vidDuration = asset1.duration.seconds - startPoint
                    }
                    let timestamp = Date().timeIntervalSince1970
                    self.cropVideo(atURL: url1, startTime: startPoint, vidDuration: vidDuration, outputFile: "\(timestamp).mov") { (outputURL, error) in
                        if let vdeo = outputURL {
                            videoURLs.append(vdeo)
                            self.savetoLibrary(vdeo: vdeo)                         
                        }
                        group.leave()
                    }
                    startPoint = startPoint + vidDuration
                }
                group.notify(queue: .main) {
                    DispatchQueue.main.async {
                        self.hideSpinner()
                        let controller = PreviewVC.instantiate(fromAppStoryboard: .video)
                        controller.isProfile = self.recordType == .profile
                        controller.videoURLs = videoURLs
                        controller.didFinishRecording = self.didFinishRecording
                        self.navigationController?.pushViewController(controller, animated: true)
                    }
                }
            } else {
                DispatchQueue.main.async {
                    self.hideSpinner()
                    self.showAlert(message: "Video recording failed. Please try again.")
                }
            }
        }
    }
    func savetoLibrary(vdeo:URL?) {
        if let vdeo = vdeo {
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: vdeo)
            }, completionHandler: { (completed, error) in                
            })
        }        
    }
    private func endRecording() {
        guard let session =  getSession() as? CKFVideoSession else {
            return
        }
        progressBar.isHidden = true
        circleProgressMiddleView.backgroundColor = .white
        timer?.invalidate()
        self.spinnerWithProgress(with: "Processing...", blockInteraction: true)
        session.stopRecording()
    
    }
    func cropVideo(atURL url:URL,startTime:Float64,vidDuration:Float64,outputFile:String,onCompletion:((_ url:URL?,_ error:String?)->Void)?) {
        let asset = AVURLAsset(url: url)
        let exportSession = AVAssetExportSession.init(asset: asset, presetName: AVAssetExportPresetHighestQuality)!
        
        let path = Helpers.getRecordingsPath() + "/\(outputFile)"
        let outputURL = URL(fileURLWithPath: path)
        let fileManager = FileManager.default
        do {
            if(fileManager.fileExists(atPath: path)) {
                try fileManager.removeItem(at: outputURL)
            }
        }
        catch {
            print(error)
        }
        
        exportSession.outputURL = outputURL
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.outputFileType = AVFileType.mov
        
        let start = CMTimeMakeWithSeconds(startTime, preferredTimescale: 600) // you will modify time range here
        let duration = CMTimeMakeWithSeconds(vidDuration, preferredTimescale: 600)
        let range = CMTimeRangeMake(start: start, duration: duration)
        exportSession.timeRange = range
        exportSession.exportAsynchronously {
            switch(exportSession.status) {
            case .completed:
                
                onCompletion?(outputURL,nil)
            default:
                onCompletion?(nil,"failed")
            }
        }
    }
    
    private func getImageFromVideo() {
        guard let url = tempVideoURL else {return}
        let asset = AVURLAsset(url: url, options: nil)
        let assetImageGenerator = AVAssetImageGenerator(asset: asset)
        assetImageGenerator.appliesPreferredTrackTransform = true
        assetImageGenerator.apertureMode = .encodedPixels
        let time = CMTime(seconds: Double(globalTimeCounter) - recordType.counter, preferredTimescale: 1)
        assetImageGenerator.generateCGImagesAsynchronously(forTimes: [NSValue(time: time)]) { (time, image, time2, result, error) in
            if let image = image {
                DispatchQueue.main.async {
                    self.images.append(UIImage(cgImage: image))
                }
            }else {
                print("error : ", error)
            }
        }
    }
    
//    func removeAudioFromVideo(videoURL: NSURL, completion: (NSURL?, NSError?) -> Void) -> Void {
//        
//        let fileManager = FileManager.defaultManager
//        
//        let composition = AVMutableComposition()
//        
//        let sourceAsset = AVURLAsset(url: videoURL as URL)
//        
//        let compositionVideoTrack = composition.addMutableTrack(withMediaType: AVMediaTypeVideo, preferredTrackID: kCMPersistentTrackID_Invalid)
//        
//        let sourceVideoTrack: AVAssetTrack = sourceAsset.tracksWithMediaType(AVMediaType.video)[0]
//        
//        let x = CMTimeRangeMake(start: kCMTimeZero, duration: sourceAsset.duration)
//        
//        try! compositionVideoTrack.insertTimeRange(x, ofTrack: sourceVideoTrack, atTime: kCMTimeZero)
//        
//        let exportPath : NSString = NSString(format: "%@%@", NSTemporaryDirectory(), "removeAudio.mov")
//        
//        let exportUrl: NSURL = NSURL.fileURLWithPath(exportPath as String) as NSURL
//        
//        if(fileManager.fileExistsAtPath(exportPath as String)) {
//            
//            try! fileManager.removeItemAtURL(exportUrl)
//        }
//        
//        let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetHighestQuality)
//        exporter!.outputURL = exportUrl as URL;
//        exporter!.outputFileType = AVFileType.mov
//        
//        exporter?.exportAsynchronouslyWithCompletionHandler({
//
//            completion(exporter?.outputURL, nil)
//        })
//    }

}

extension CameraVC: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CameraCaptureThumbnailCollectionViewCell.self, for: indexPath)
        cell.imageView.image = images[indexPath.item]
        return cell
    }
    
}

extension CameraVC: UIScrollViewDelegate {
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        scrollViewWillBeginDecelerating(scrollView)
    }
    
    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        let x = scrollView.contentOffset.x
        isNormalMode = x < normalModeButton.frame.width/2
        normalModeButton.alpha = isNormalMode ? 1 : 0.6
        crousalModeButton.alpha = isNormalMode ? 0.6 : 1
        let offsetX = isNormalMode ? 0 : normalModeButton.frame.width
        scrollView.setContentOffset(CGPoint(x: offsetX, y: 0), animated: false)
    }
}

//extension CameraVC: UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
//    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
//        return CGSize(width: 40, height: 65)
//    }
//}

enum VideoRecordType {
    case feed
    case profile
    case simpleCamera
    var counter: Double {
        switch self {
        case .feed:
            return 20
        case .profile:
            return 6.0
        default:
            return 20.0
        }
    }
}
extension CameraVC :  CKFSessionDelegate {
    func didChangeValue(session: CKFSession, value: Any, key: String) {
//        if key == "zoom" {
//            self.zoomLabel.text = String(format: "%.1fx", value as! Double)
//        }
    }
    
    
}
