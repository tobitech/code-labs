//
//  FullscreenVideoVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 10/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import JPVideoPlayer
import AVKit

final class FullscreenVideoVC: UIViewController {
    
    @IBOutlet var videoView: AVPlayerView!
    @IBOutlet var feedImageView: UIImageView!
    @IBOutlet var btnPlayPause: UIButton!
    
    var urlString: String!
    var imageURL: String?
    var observer: NSObjectProtocol?
    var playCount = 0
    var feedId: String?
    var playlistURLs = [String]()
    
    var isMultipleVideo = false
    var didViewCompleted:(() -> Void)?
    
    var player: AVPlayer?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let img = imageURL, img.count > 0, let url = URL.init(string: img) {
            feedImageView.sd_setImage(with: url, completed: nil)
        }
        hideNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kAppDelegate.setupSound(isPrimary: true)
        if isMultipleVideo {
            setupMultipleVideo()
        } else {
            setupVideo()
        }
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        feedImageView.jp_stopPlay()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        kAppDelegate.setupSound(isPrimary: false)
    }
    
    @IBAction func playPauseTapped(_ sender: UIButton) {
        if feedImageView.jp_rate == 0 {
            feedImageView.jp_resume()
            sender.setImage(UIImage(named: "an_pause"), for: .normal)
        } else {
            feedImageView.jp_pause()
            sender.setImage(UIImage(named: "enabledButton"), for: .normal)
        }
    }
    
    func spinner(with text: String? = nil,blockInteraction:Bool = false) {
        self.hideSpinner()
        let spinnerActivity = MBProgressHUD.showCustomHud(to: self.view, animated: true)
        if let txt = text {
            spinnerActivity.label.text = txt
        }
        spinnerActivity.isUserInteractionEnabled = blockInteraction
    }
    
    func hideSpinner() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    func markFeedViewed(feedId:String?) {
        guard let feedId = feedId else {
            return
        }
        let param = [
            "user_id": Helpers.userId,
            "entity_id": feedId
        ]
        APIController.makeRequest(request: .addFeedViewCount(param: param)) { [weak self] (_) in
            self?.didViewCompleted?()
        }
    }
    
    private func setupVideo() {
        if let url = URL.init(string: urlString) {
            feedImageView.jp_videoPlayerDelegate = self
            feedImageView.jp_playVideo(with: url, bufferingIndicator: JPVideoPlayerBufferingIndicator(), controlView: nil, progressView: nil) { (v, model) in
                model.playerLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            }
        }
    }
    
    
    func setupMultipleVideo() {
        var playerItems = [AVPlayerItem]()
        for urlString in playlistURLs {
            if let url = URL.init(string: urlString) {
                playerItems.append(AVPlayerItem(url: url))
            }
        }
        player = AVQueuePlayer(items: playerItems)
        player?.automaticallyWaitsToMinimizeStalling = false
        self.videoView.alpha = 1
        self.videoView.playerLayer.player = player
        self.videoView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        kAppDelegate.setupSound(isPrimary: true)
        player?.play()
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    deinit {
        print("deinit")
    }
}

extension FullscreenVideoVC: JPVideoPlayerDelegate {
    func shouldShowDefaultControlAndIndicatorViews() -> Bool {
        return false
    }
    func shouldShowBlackBackgroundWhenPlaybackStart() -> Bool {
        return false
    }
}
