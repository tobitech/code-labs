//
//  TripListMemoryCollectionViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/16/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class TripListMemoryCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var deleteButton: UIButton?
    
    var onDeleteTapped: (() -> ())?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
    @IBAction func deleteTapped(_ sender: Any) {
        onDeleteTapped?()
    }
    
}
