//
//  ChatCell.swift
//  Trajilis
//
//  Created by bharats802 on 20/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class AudioChatCell: ChatBaseCell {
    static let identifier = "AudioChatCell"
    
    @IBOutlet weak var btnPlay:TRCellButton!
    @IBOutlet weak var slider:UISlider!
    override func awakeFromNib() {
        super.awakeFromNib()
        self.centerControl = self.viewBG
        self.slider.tintColor = .appRed
        self.slider.setThumbImage(UIImage(), for: .normal)
        self.slider.isUserInteractionEnabled = false
        self.slider.value = 0
    }
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    override func set(isCurrentSender: Bool) {
        super.set(isCurrentSender: isCurrentSender)
        if isCurrentSender {
            self.slider.tintColor = .appRed
        } else {
            self.slider.tintColor = .white
        }
        
    }
}
