//
//  TripsterCollectionViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 16/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class TripsterCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet var imgView: UIImageView!
    static var identifier: String {
        return String(describing: self)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        self.imgView.layer.cornerRadius = 8
        self.imgView.layer.borderColor = UIColor.appRed.cgColor
        self.imgView.layer.borderWidth = 0.3
        self.imgView.layer.masksToBounds = true        
    }

}
