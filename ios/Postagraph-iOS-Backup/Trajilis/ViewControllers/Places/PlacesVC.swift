//
//  PlacesVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 22/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SDWebImage

final class PlacesVC: BaseVC {
    
//    var isUsersPlaces: Bool = true
//    var placeId: String = ""
//    var place = ""
//    var isProfile = false
//    var userId = ""
    
    var viewModel: FeedViewModel!
    var location: String?
    var address: String?
    var rating: Double = 0
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        viewModel.reload = { [weak self] in
            self?.collectionView.reloadData()
        }
        collectionView.delegate = self
        collectionView.dataSource = self
        title = "Ratings"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
//    private func setupTableChildView() {
//        let controller = FeedVC.instantiate(fromAppStoryboard: .feed)
//        controller.loadedPlace = {[weak self] place in
//            self?.ratingView.alpha = 1
//            self?.ratingView.rating = place.rating
//            self?.cityLabel.alpha = 1
//        }
//
//        if !userId.isEmpty {
//            let vModel = FeedViewModel(type: .othersPlaces(id: userId))
//            controller.viewModel = vModel
//        } else {
//            let vModel = isProfile ? FeedViewModel(type: .profile(id: userId)) : FeedViewModel(type: .places(id: placeId))
//            controller.viewModel = vModel
//        }
//        addChild(controller)
//        container.addSubview(controller.view)
//        controller.view.fill()
//        controller.didMove(toParent: self)
//    }

}

extension PlacesVC : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        let reusableView = collectionView.dequeue(PlacesHeaderCollectionReusableView.self, for: indexPath, forSupplementaryViewOfKind: kind)
        reusableView.placeNameLabel.text = location
        reusableView.placeName2Label.text = address
        reusableView.ratingView.rating = rating
        return reusableView
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.feeds.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(TripListMemoryCollectionViewCell.self, for: indexPath)
        
        let memory = viewModel.feeds[indexPath.row]
        cell.imageView.image = nil
        cell.viewCountLabel.text = "\(memory.viewcount)"
        if let url = URL(string: memory.imageURL) {
            cell.imageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            cell.imageView.sd_setImage(with: url, completed: nil)
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feed = viewModel.feeds[indexPath.row]
        let controller = FullscreenVideoVC.instantiate(fromAppStoryboard: .feed)
        controller.urlString = feed.cdnUrl
        controller.isMultipleVideo = false
        controller.imageURL = feed.imageURL
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 4)/3
        let height = width*163/124
        return CGSize(width: width, height: height)
    }
    
}
