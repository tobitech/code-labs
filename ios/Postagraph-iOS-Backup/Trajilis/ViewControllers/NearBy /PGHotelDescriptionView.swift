//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import Cosmos
import SDWebImage

class PGHotelDescriptionView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var lblTitle:UILabel!
    @IBOutlet weak var lblDesc:UILabel!
    @IBOutlet weak var stackView:UIStackView!
    @IBOutlet weak var btnViewAll:UIButton!
    @IBOutlet weak var heightImagesView:NSLayoutConstraint!
    
    class func getView() -> PGHotelDescriptionView {
        let view  = Bundle.main.loadNibNamed("PGHotelDescriptionView", owner: self, options: nil)!.first as! PGHotelDescriptionView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.btnViewAll.setTitleColor(.appRed, for: .normal)
        return view
    }
    
    func fillValue(hotel:PGHotel) {
        self.lblDesc.text =  nil
        if let texts = hotel.hotelDescription?.texts,texts.count > 0 {
            var desc = ""
            for text in texts {
                desc.append(text)
                desc.append("\n")
            }
            self.lblDesc.text =  desc
        }
        if let images = hotel.hotelDescription?.images,images.count > 0 {
            for img in images {
                if let url = URL(string:img.url) {
                    let imgView = UIImageView()
                    imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    imgView.sd_setImage(with: url, completed: nil)
                    imgView.layer.cornerRadius = 8
                    imgView.layer.masksToBounds = true
                    //self.stackView.addArrangedSubview(imgView)
                    imgView.contentMode = .scaleAspectFill
                    imgView.translatesAutoresizingMaskIntoConstraints = false
                    //center image
                    let heightConstraint = NSLayoutConstraint(item: imgView, attribute: .height, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120)
                    let widthConstraint = NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: nil, attribute: .notAnAttribute, multiplier: 1.0, constant: 120)
                    imgView.addConstraints([heightConstraint, widthConstraint])
                    if self.stackView.subviews.count == 10 {
                        break
                    }
                }
                
            }
        } else {
            self.heightImagesView.constant = 0
        }
    }
    
}
