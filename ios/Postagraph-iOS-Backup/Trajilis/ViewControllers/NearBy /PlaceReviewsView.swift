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

class PlaceReviewsView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBOutlet weak var stackView:UIStackView!
   
    
    class func getView() -> PlaceReviewsView {
        let view  = Bundle.main.loadNibNamed("PlaceReviewsView", owner: self, options: nil)!.first as! PlaceReviewsView
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }
    
    func setReviews(reviews:[GoogleReview]) {
        self.stackView.removeAllViews()
        let sorted = reviews.sorted { (place1, place2) -> Bool in
            if place1.reviewTimeStamp > place2.reviewTimeStamp {
                return true
            }
            return false
        }
        for review in sorted {
            let reviewView = ReviewView.getView()
            if let value = review.author_name {
                reviewView.lblName.text = value
            }
            if let value = review.text {
                reviewView.lblReview.text = value
            }
            if let value = review.profile_photo_url,let url = URL(string: value) {
                reviewView.imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                reviewView.imgView.sd_setImage(with: url, completed: nil)
            }
            reviewView.ratingView.rating = review.rating
            reviewView.lblTime.text = review.relative_time_description
            self.stackView.addArrangedSubview(reviewView)
        }
        
        
    }
    
}
