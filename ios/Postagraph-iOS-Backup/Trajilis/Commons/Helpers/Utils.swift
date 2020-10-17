

import AVKit

class Utils {
    
}

extension UIView {
    func removeAllViews() {
        for sview in self.subviews {
            sview.removeFromSuperview()
        }
    }
    
    func addChildViewConstraints(subView:UIView) {
        
        subView.translatesAutoresizingMaskIntoConstraints = false
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .trailing, relatedBy: .equal, toItem: subView, attribute: .trailing, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .leading, relatedBy: .equal, toItem: subView, attribute: .leading, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .bottom, relatedBy: .equal, toItem: subView, attribute: .bottom, multiplier: 1, constant: 0))
        
        self.addConstraint(NSLayoutConstraint(item: self, attribute: .top, relatedBy: .equal, toItem: subView, attribute: .top, multiplier: 1, constant: 0))
    }
    
}
//@IBDesignable
class PTSeparatorView:UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        configure()
    }
    
    private func configure() {
       self.backgroundColor = .appRed
    }
}


//
//  VideoWatermarker.swift
//  FlappyBirdScream
//
//  Created by Mikita Manko on 5/4/17.
//  Copyright © 2017 Mikita Manko. All rights reserved.
//

import Foundation
import AVKit
import AVFoundation
import SpriteKit

class VideoWatermarker {
    
    let watermarkImg = UIImage(named: "postaLogo")
    private var counter: Int = 0
    
    private func getImageLayer(height: CGFloat) -> CALayer {
        let imglogo = watermarkImg
        
        let imglayer = CALayer()
        imglayer.contents = imglogo?.cgImage
        imglayer.frame = CGRect(
            x: 0, y: height - imglogo!.size.height/2,
            width: imglogo!.size.width/2, height: imglogo!.size.height/2)
        imglayer.opacity = 0.6
        
        return imglayer
    }
    
    private func getFramesAnimation(frames: [UIImage], duration: CFTimeInterval) -> CAAnimation {
        let animation = CAKeyframeAnimation(keyPath:#keyPath(CALayer.contents))
        animation.calculationMode = CAAnimationCalculationMode.discrete
        animation.duration = duration
        animation.values = frames.map {$0.cgImage!}
        animation.repeatCount = Float(frames.count)
        animation.isRemovedOnCompletion = false
        animation.fillMode = CAMediaTimingFillMode.forwards
        animation.beginTime = AVCoreAnimationBeginTimeAtZero
        
        return animation
    }
    
    private func addAudioTrack(composition: AVMutableComposition, videoAsset: AVURLAsset) {
        if let compositionAudioTrack:AVMutableCompositionTrack = composition.addMutableTrack(withMediaType: AVMediaType.audio, preferredTrackID: CMPersistentTrackID()) {
            let audioTracks = videoAsset.tracks(withMediaType: AVMediaType.audio)
            for audioTrack in audioTracks {
                try! compositionAudioTrack.insertTimeRange(audioTrack.timeRange, of: audioTrack, at: CMTime.zero)
            }
        }
        
    }
    
    
    func addWatermark(inputURL: URL,frame:UIImage, outputURL: URL, handler:@escaping (_ exportSession: AVAssetExportSession?)-> Void) {
        let mixComposition = AVMutableComposition()
        let asset = AVAsset(url: inputURL)
        let videoTrack = asset.tracks(withMediaType: AVMediaType.video)[0]
        let timerange = CMTimeRangeMake(start: CMTime.zero, duration: asset.duration)
        
        let compositionVideoTrack:AVMutableCompositionTrack = mixComposition.addMutableTrack(withMediaType: AVMediaType.video, preferredTrackID: CMPersistentTrackID(kCMPersistentTrackID_Invalid))!
        
        do {
            try compositionVideoTrack.insertTimeRange(timerange, of: videoTrack, at: CMTime.zero)
            compositionVideoTrack.preferredTransform = videoTrack.preferredTransform
        } catch {
            print(error)
        }
        
        let watermarkFilter = CIFilter(name: "CISourceOverCompositing")!
        
        let watermarkImage = CIImage(image: frame.imageWithAlpha(alpha: 0.6))!
        
        let videoComposition = AVVideoComposition(asset: asset) { (filteringRequest) in
            let source = filteringRequest.sourceImage.clampedToExtent()
            watermarkFilter.setValue(source, forKey: "inputBackgroundImage")
            let x = filteringRequest.sourceImage.extent.width/2 - watermarkImage.extent.width/2 - 2
            let y = filteringRequest.sourceImage.extent.height/2 - watermarkImage.extent.height/2 - 2
            let transform = CGAffineTransform(translationX: x, y: y)
            watermarkFilter.setValue(watermarkImage.transformed(by: transform), forKey: "inputImage")
            filteringRequest.finish(with: watermarkFilter.outputImage!, context: nil)
        }
        
        guard let exportSession = AVAssetExportSession(asset: asset, presetName: AVAssetExportPreset1920x1080) else {
            handler(nil)
            
            return
        }
        
        exportSession.outputURL = outputURL
        exportSession.outputFileType = AVFileType.mp4
        exportSession.shouldOptimizeForNetworkUse = true
        exportSession.videoComposition = videoComposition
        exportSession.exportAsynchronously { () -> Void in
            handler(exportSession)
        }
    }
    
    
    func addOverlay(url: URL, frames: [UIImage], framesToSkip: Int, complete: @escaping(_:URL?)->()) {
        
        // Clear url.
        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory() + "/watermark.mp4")
        try? FileManager().removeItem(at: outputURL)

        let inputURL = url
        
        addWatermark(inputURL: inputURL,frame:frames.first!, outputURL: outputURL, handler: { (exportSession) in
            guard let session = exportSession else {
                // Error
                return
            }
            switch session.status {
            case AVAssetExportSession.Status.failed:
                print("failed")
                print(session.error ?? "unknown error")
                complete(url)
            case AVAssetExportSession.Status.cancelled:
                print("cancelled")
                print(session.error ?? "unknown error")
                complete(url)
            default:
                print("Movie complete")
                complete(outputURL)
            }
        })
    }
    
}
extension UINavigationController {
    
    func configure() {
        self.navigationBar.tintColor = UIColor.white
        self.navigationBar.barTintColor = UIColor.appRed
        self.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
        
    }
}
extension UIImage {
    func imageWithAlpha(alpha: CGFloat) -> UIImage {
        UIGraphicsBeginImageContextWithOptions(size, false, scale)
        draw(at: CGPoint.zero, blendMode: .normal, alpha: alpha)
        guard let newImage = UIGraphicsGetImageFromCurrentImageContext() else { return self }
        UIGraphicsEndImageContext()
        return newImage
    }
}
extension UISegmentedControl {
    func removeBorders() {
        setBackgroundImage(imageWithColor(color: backgroundColor!), for: .normal, barMetrics: .default)
        setBackgroundImage(UIImage(named:"selectedItem"), for: .selected, barMetrics: .default)
        setDividerImage(imageWithColor(color: UIColor.lightGray), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
    }
    
    // create a 1x1 image with this color
    private func imageWithColor(color: UIColor) -> UIImage {
        let rect = CGRect(x: 0.0, y: 0.0, width:  1.0, height: 1.0)
        UIGraphicsBeginImageContext(rect.size)
        let context = UIGraphicsGetCurrentContext()
        context!.setFillColor(color.cgColor);
        context!.fill(rect);
        let image = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
        return image!
    }
}
