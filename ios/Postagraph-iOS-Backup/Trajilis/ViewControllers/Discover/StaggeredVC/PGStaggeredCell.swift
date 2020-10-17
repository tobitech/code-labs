//
//  PGStaggeredCell.swift
//  Trajilis
//
//  Created by bharats802 on 02/06/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import AVKit


class PGStaggeredCell: PGStaggeredBaseCell {

    static let identifier = "PGStaggeredCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class PGStaggeredBaseCell: UITableViewCell {
    
    @IBOutlet weak var imgView1:UIImageView!
    @IBOutlet weak var imgView2:UIImageView!
    @IBOutlet weak var imgView3:UIImageView!
    var observer: NSObjectProtocol?
    @IBOutlet weak var videoView: AVPlayerView?
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
}
