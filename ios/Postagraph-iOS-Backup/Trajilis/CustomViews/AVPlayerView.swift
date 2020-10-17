//
//  AVPlayerView.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 30/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import AVKit

class AVPlayerView: UIView {
    
    override class var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer;
    }
    
    var player: AVPlayer? {
        get {
            return playerLayer.player;
        }
        set {
            playerLayer.player = newValue;
        }
    }
}
