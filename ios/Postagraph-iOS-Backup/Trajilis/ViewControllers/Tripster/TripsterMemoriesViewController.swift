//
//  TripsterMemoriesViewController.swift
//  Trajilis
//
//  Created by bibek timalsina on 7/17/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class TripsterMemoriesViewController: UIViewController {
    
    var viewModel: TripsterMemoriesViewModel!
    
    @IBOutlet weak var usernameLbl: UILabel!
    @IBOutlet weak var fullnameLbl: UILabel!
    @IBOutlet weak var userImgView: UIImageView!
    @IBOutlet weak var playAllBtn: UIButton!
    @IBOutlet weak var descLbl: UILabel!
    @IBOutlet weak var collectionView: UICollectionView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCollectionView()
        viewModel.reload = { [weak self] in
            self?.collectionView.reloadData()
            self?.setData()
        }
        setData()
        userImgView.rounded()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    private func setupCollectionView() {
        collectionView.register(TripMemoryCollectionViewCell.Nib, forCellWithReuseIdentifier: TripMemoryCollectionViewCell.identifier)
        collectionView.collectionViewLayout = TripsterMemoriesCollectionViewLayout()
        collectionView.delegate             = self
        collectionView.dataSource           = self
    }
    
    private func setData() {
        descLbl.text        = "\(viewModel.memories.count) memories"
        playAllBtn.isHidden = viewModel.memories.isEmpty
        
        let feed = viewModel.memories.first
        fullnameLbl.text = feed?.getUserName()
        usernameLbl.text = feed?.username
        if let userImage = feed?.userImage,
            let url = URL.init(string: userImage) {
            userImgView.sd_setImage(with: url, completed: nil)
        }
    }
    
    @IBAction private func backTapped() {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction private func playAllTapped() {
        let urls = viewModel.memories.map({$0.cdnUrl})
        let controller = FullscreenVideoVC.instantiate(fromAppStoryboard: .feed)
        controller.playlistURLs = urls
        controller.isMultipleVideo = true
        controller.imageURL = viewModel.memories.first?.imageURL ?? ""
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension TripsterMemoriesViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.memories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TripMemoryCollectionViewCell.identifier, for: indexPath) as! TripMemoryCollectionViewCell
        cell.configure(feed: viewModel.memories[indexPath.row])
        return cell
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        let visibleIndexPath = collectionView.indexPathsForVisibleItems
        if let indexPath = visibleIndexPath.first {
            if (viewModel.memories.count - indexPath.row) == 5 && !viewModel.isLastContent {
                viewModel.getTripMemmories(isLoadingMore: true)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let feed = viewModel.memories[indexPath.row]
        let controller = FullscreenVideoVC.instantiate(fromAppStoryboard: .feed)
        controller.urlString = feed.cdnUrl
        controller.isMultipleVideo = false
        controller.imageURL = feed.imageURL
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
}
