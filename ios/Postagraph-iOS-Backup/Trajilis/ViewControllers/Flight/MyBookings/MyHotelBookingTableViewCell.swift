//
//  MyHotelBookingTableViewCell.swift
//  Trajilis
//
//  Created by bibek timalsina on 9/23/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class MyHotelBookingTableViewCell: UITableViewCell {
    
    @IBOutlet weak var tripNameLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var hotelName: UILabel!
    @IBOutlet weak var hotelImagesCollectionView: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    
    private var images: [PGHotelImage] = []

    override func awakeFromNib() {
        super.awakeFromNib()
        hotelImagesCollectionView.dataSource = self
        hotelImagesCollectionView.delegate = self
        hotelImagesCollectionView.superview?.set(borderWidth: 1, of: UIColor(hexString: "#E5E5E5"))
        hotelImagesCollectionView.superview?.set(cornerRadius: 4)
    }
    
    func set(booking: PGHotelBookingDetail?) {
        hotelName.text = booking?.hotel_city
        tripNameLabel.text = booking?.hotel_name
        images = booking?.hotel?.hotelDescription?.images ?? []
        pageControl.currentPage = 0
        hotelImagesCollectionView.contentOffset.x = 0
        hotelImagesCollectionView.reloadData()
        
        let startDate = Helpers.formattedDateFromString(dateString: booking?.start_date ?? "", withFormat: "EEE, MMM d")
        let endDate = Helpers.formattedDateFromString(dateString: booking?.end_date ?? "", withFormat: "EEE, MMM d")
        
        dateLabel.text = startDate + " - " + endDate
//        if let img = booking.hotel?.hotelDescription?.images,!img.isEmpty,let url = URL(string:img) {
//            self.imgViewHotel.sd_setImage(with: url, placeholderImage: UIImage(named: "mapsmall"))
//        }
    }
    
    @IBAction func shareToTripTapped(_ sender: Any) {
    }
    
}

extension MyHotelBookingTableViewCell: UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = images.count
        return max(images.count, 1)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        let imageView = cell.viewWithTag(1) as? UIImageView
        imageView?.image = UIImage(named: "mapsmall")
        if let imageStringURL = images.item(at:indexPath.item)?.url,
            let url = URL(string: imageStringURL) {
            imageView?.sd_setImage(with: url, placeholderImage: UIImage(named: "mapsmall"))
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.frame.size
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let indexPath = hotelImagesCollectionView.indexPathForItem(at: scrollView.center)
        pageControl.currentPage = indexPath?.item ?? 0
    }
    
}
