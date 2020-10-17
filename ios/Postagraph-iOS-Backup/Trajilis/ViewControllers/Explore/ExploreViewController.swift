//
//  ExploreViewController.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/27/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SDWebImage

class ExploreViewController: BaseVC {
    
    var viewModel: ExploreViewModel!
    
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        collectionView.delegate = self
        collectionView.dataSource = self
        title = "Explore"
        getExploreFeeds()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    private func getExploreFeeds() {
        if viewModel.feeds.count == 0 {
            spinner(with: "Preparing to explore...", blockInteraction: true)
        }
        viewModel.fetchExploreFeeds {[weak self] (error) in
            self?.hideSpinner()
            if let error = error {
                self?.showAlert(message: error)
            }else {
                self?.collectionView.reloadData()
            }
        }
    }
    
}

extension ExploreViewController : UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
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
        
        if indexPath.item == viewModel.feeds.count - 1 {
            getExploreFeeds()
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
