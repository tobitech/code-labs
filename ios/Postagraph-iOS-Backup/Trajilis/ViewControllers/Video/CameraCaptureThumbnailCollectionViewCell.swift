//
//  CameraCaptureThumbnailCollectionViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 10/6/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class CameraCaptureThumbnailCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    
    var selectedRecording: Bool = false {
        didSet {
            imageView.set(borderWidth: selectedRecording ? 2 : 0, of: .white)
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView.set(cornerRadius: 8)
        contentView.elevate(2)
    }
}
