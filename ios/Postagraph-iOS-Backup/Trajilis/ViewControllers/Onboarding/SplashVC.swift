//
//  SplashVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import AVKit

final class SplashVC: UIViewController {
    
    @IBOutlet var videoView: AVPlayerView!
    
    fileprivate var player: AVPlayer?
    
    
    fileprivate var latestTime = CMTimeMake(value: 0, timescale: 1000000000)
    var observer: NSObjectProtocol?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupPlayer()
        title = ""
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    private func setupPlayer() {
        let filepath = Bundle.main.path(forResource: "splashScreenVideo", ofType: "mp4")
        let playerItem = AVPlayerItem(url: URL(fileURLWithPath: filepath! ))
        player = AVPlayer(playerItem: playerItem)
        guard let playerLayer = videoView.layer as? AVPlayerLayer else { return }
        playerLayer.player = player
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player!.isMuted = true
        player!.play()
        observer = NotificationCenter.default
        .addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                     object: player!.currentItem, queue: nil, using: { [weak self] (_) in
            DispatchQueue.main.async {
                self?.player?.seek(to: CMTime.zero)
                self?.player?.play()
            }
        })
    }
    @IBAction func guestTapped(_ sender: Any) {
        UserDefaults.standard.set("", forKey: USERID)
        UserDefaults.standard.set("ASd57n4QMrltOHQzXfFqzw==", forKey: APIREQUESTTOKENKEY)
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        self.navigationController?.present(controller!, animated: true, completion: nil)
        
        self.videoView.player = nil
        player = nil
    }

}
