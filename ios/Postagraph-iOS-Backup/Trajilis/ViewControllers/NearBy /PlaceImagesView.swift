//
//  PlaceImagesView.swift
//  Trajilis
//
//  Created by bharats802 on 02/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import SDWebImage

class PlaceImagesView: UIView {

    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    @IBOutlet weak var scrollView:UIScrollView!
    @IBOutlet weak var stackView:UIStackView!
    @IBOutlet weak var pageController:UIPageControl!
    
    class func getView() -> PlaceImagesView {        
        let view  = Bundle.main.loadNibNamed("PlaceImagesView", owner: self, options: nil)!.first as! PlaceImagesView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.pageController.tintColor = UIColor.appRed
        view.stackView.removeAllViews()
         view.pageController.pageIndicatorTintColor = UIColor.appRed
        view.pageController.isUserInteractionEnabled = false
        return view
        
    }
    func setImages(images:[String]?) {
        if let imgs = images,imgs.count > 0 {
            for img in imgs {
                let imgView = UIImageView()
                if let url = URL(string: img) {
                    imgView.sd_imageIndicator = SDWebImageActivityIndicator.gray
                    imgView.sd_setImage(with: url, completed: nil)
                    self.stackView.addArrangedSubview(imgView)
                    imgView.translatesAutoresizingMaskIntoConstraints = false
                    let height = NSLayoutConstraint(item: imgView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
                    let width = NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
                    self.addConstraints([height,width])
                }
            }
        }
        self.pageController.numberOfPages = self.stackView.arrangedSubviews.count
        self.pageController.currentPage = 0
        
    }
    func setDummyImage() {
        
        let imgView = UIImageView()
        imgView.image = UIImage(named:"mapsmall")
        self.stackView.addArrangedSubview(imgView)
        imgView.translatesAutoresizingMaskIntoConstraints = false
        let height = NSLayoutConstraint(item: imgView, attribute: .height, relatedBy: .equal, toItem: self, attribute: .height, multiplier: 1, constant: 0)
        let width = NSLayoutConstraint(item: imgView, attribute: .width, relatedBy: .equal, toItem: self, attribute: .width, multiplier: 1, constant: 0)
        self.addConstraints([height,width])
        
        self.pageController.numberOfPages = self.stackView.arrangedSubviews.count
        self.pageController.currentPage = 0
    }
    
    
}
extension PlaceImagesView:UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let width = scrollView.frame.size.width
        let page = (scrollView.contentOffset.x + (0.5 * width)) / width
        self.pageController.currentPage = Int(page)
        
        
    }
}
