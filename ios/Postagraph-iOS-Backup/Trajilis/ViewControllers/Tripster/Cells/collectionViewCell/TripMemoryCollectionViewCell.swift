//
//  TripMemoryCollectionViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 7/16/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class TripMemoryCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    
    static var identifier: String {
        return String(describing: self)
    }
    
    static var Nib: UINib {
        return UINib(nibName: identifier, bundle: nil)
    }
    
    func configure(feed: Feed) {
        if let url = URL.init(string: feed.imageURL) {
            imageView.sd_setImage(with: url, completed: nil)
        }
    }
    
}
