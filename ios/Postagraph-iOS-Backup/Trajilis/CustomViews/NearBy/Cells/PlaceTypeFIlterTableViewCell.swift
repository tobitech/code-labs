//
//  PlaceTypeFIlterTableViewCell.swift
//  Trajilis
//
//  Created by Perfect Aduh on 29/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit


class PlaceTypeFIlterTableViewCell: UITableViewCell {
    
    @IBOutlet weak var placeTypeLbl: UILabel!
    @IBOutlet weak var placeImg: UIImageView!
    @IBOutlet weak var radioSelectionImg: UIImageView!
    
    var placeSelected: (() -> ())?
    var isPlaceSelected: Bool = false
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }


    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    
    func configureCell(title: String, placeImgName: String ) {
        placeTypeLbl.text = title
        placeImg.image = UIImage(named: placeImgName)
        radioSelectionImg.image = isPlaceSelected ? UIImage(named: "select_icon") : UIImage(named: "unselect-icon")
    }
}
