//
//  ChatCell.swift
//  Trajilis
//
//  Created by bharats802 on 20/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class MediaChatCell: ChatBaseCell {
    static let identifier = "MediaChatCell"    
    @IBOutlet weak var imgViewMedia:UIImageView!
    @IBOutlet weak var btnPlay:TRCellButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.centerControl = self.viewBG
        self.imgViewMedia.layer.cornerRadius = 8
        self.imgViewMedia.layer.borderWidth = 0
        self.imgViewMedia.layer.masksToBounds = true
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
