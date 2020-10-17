//
//  FeedVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import AVKit
import Social
import MobileCoreServices
import AVKit
import SDWebImage

class FeedVC: BaseVC {
    
    private let postCellId = "postCellId"
    
    private let refreshControl = UIRefreshControl()
    
    var collectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.isPagingEnabled = true
        return cv
    }()
    
    var currentlyDisplayingCell: PostCell?
    
    var shouldHidePostContent = false
    
    // MARK: - View Life Cycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCollectionView()
        
        addAssetObservers()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    // MARK: - Setup Methods
    
    fileprivate func setupCollectionView() {
        
        refreshControl.addTarget(self, action: #selector(fetchRecentFeeds), for: .valueChanged)
        refreshControl.tintColor = .white
        
        collectionView.refreshControl = refreshControl
        
        refreshControl.beginRefreshing()
        
        collectionView.isPrefetchingEnabled = false
        
        collectionView.prefetchDataSource = self
        
        collectionView.backgroundColor = .black
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.showsVerticalScrollIndicator = false
        
        collectionView.register(PostCell.self, forCellWithReuseIdentifier: postCellId)
        
        view.addSubview(collectionView)
        collectionView.fillSuperview()
        
        collectionView.contentInset.top = -UIApplication.shared.statusBarFrame.height
    }
    
    @objc private func fetchRecentFeeds() {
        StreamListManager.shared.viewModel.currentPage = 0
        StreamListManager.shared.viewModel.fetchRemoteFeeds()
    }
    
}

extension FeedVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = AssetListManager.sharedManager.numberOfPosts()
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: postCellId, for: indexPath) as! PostCell
        
        cell.delegate = self
        cell.shouldHidePostContent = self.shouldHidePostContent
        
        let post = AssetListManager.sharedManager.post(at: indexPath.item)
        print("Post assets: \(post.assets.count)")
        cell.post = post
        // cell.playMedia()
        
        currentlyDisplayingCell = cell
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.frame.width, height: UIScreen.main.bounds.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("will display cell at \(indexPath.item)")
        // let cell = cell as! PostCell
        // cell.mediaPlayer?.play()
        
//        #if !targetEnvironment(simulator)
//            retryFailedDownloads(forItemAt: indexPath.item)
//        #endif
    }
    
    func collectionView(_ collectionView: UICollectionView, didEndDisplaying cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        print("did end displaying cell at \(indexPath.item)")
//        let cell = cell as! PostCell
//        cell.mediaPlayer?.pause()
    }
}

extension FeedVC {
    
    func downloadStream(asset: Asset) {
        let downloadState = AssetPersistenceManager.sharedManager.downloadState(for: asset)
        print(downloadState.rawValue)
        switch downloadState {
        case .notDownloaded:
            AssetPersistenceManager.sharedManager.downloadStream(for: asset)
        default:
            break
        }
    }
    
    func cacheFeedMediaContent() {
        
        for n in 0..<AssetListManager.sharedManager.numberOfPosts() {
            #if targetEnvironment(simulator)
                print(n)
            #else
                let asset = AssetListManager.sharedManager.asset(at: n)
                downloadStream(asset: asset)
            #endif
        }
    }
    
    fileprivate func addAssetObservers() {
        AssetListManager.sharedManager.delegate = self
        
        let notificationCenter = NotificationCenter.default
        // notificationCenter.addObserver(self, selector: #selector(handleAssetListManagerDidLoad(_:)), name: .AssetListManagerDidLoad, object: nil)
        notificationCenter.addObserver(self,
                                       selector: #selector(handleAssetDownloadStateChanged(_:)),
                                       name: .AssetDownloadStateChanged, object: nil)
    }
    
    @objc
    func handleAssetDownloadStateChanged(_ notification: Notification) {
        
        guard let assetStreamId = notification.userInfo![Asset.Keys.id] as? String,
        let downloadStateRawValue = notification.userInfo![Asset.Keys.downloadState] as? String,
        let downloadState = Asset.DownloadState(rawValue: downloadStateRawValue) else { return }
        
        print("\(assetStreamId) - download state: \(downloadState.rawValue)")
        DispatchQueue.main.async {
            switch downloadState {
            case .downloading:

                if let downloadSelection = notification.userInfo?[Asset.Keys.downloadSelectionDisplayName] as? String {
                    print("\(downloadState): \(downloadSelection)")
                    return
                }
            case .downloaded, .notDownloaded:
                print("")
            }
        }
    }
}

// MARK:  Feed Actions
extension FeedVC {
    private func shareImage(feed: Post) {
        guard let url = feed.singleImageUrl else { return }
        
        MBProgressHUD.showCustomHud(to: view, animated: true,minSize: true)
        
        ImageHelper.getImage(fromUrl: url) { (image) in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                if let instagramURL = URL(string: "instagram://app") {
                    if UIApplication.shared.canOpenURL(instagramURL) {
                        let documentsPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
                        let saveImagePath = (documentsPath as NSString).appendingPathComponent("Image.igo")
                        let imageData = image!.pngData()
                        do {
                            let urlfile = URL(fileURLWithPath: saveImagePath)
                            try imageData?.write(to: urlfile)
                            
                        } catch {
                            print("Instagram sharing error")
                        }
                        let imageURL = URL(fileURLWithPath: saveImagePath)
                        let documentInteractionController = UIDocumentInteractionController(url: imageURL)
                        documentInteractionController.uti = "com.instagram.exclusivegram"
                        let bounds = self.collectionView.bounds
                        if !documentInteractionController.presentOpenInMenu(from: bounds, in: self.view, animated: true) {
                            print("Instagram not found")
                        }
                    } else {
                        print("Instagram not found")
                    }
                }
                else {
                    print("Instagram not found")
                }
            }
        }
    }
    
    private func shareVideo(feed: Post) {
        if UIApplication.shared.canOpenURL(URL(string: "instagram://app")!) {
            MBProgressHUD.showCustomHud(to: view, animated: true,minSize: true)
            
            Helpers.downloadVideo(feed: feed) { assets in
                DispatchQueue.main.async {
                    MBProgressHUD.hide(for: self.view, animated: true)
                }

                if assets.count == 0 {
                    self.showAlert(message: kDefaultError)
                } else {
                    for asset in assets {
                        if let shareUrl = URL(string: "instagram://library?LocalIdentifier=" + asset.localIdentifier),
                            UIApplication.shared.canOpenURL(shareUrl) {
                            UIApplication.shared.open(shareUrl, options: [:], completionHandler:nil)
                        }
                    }
                }
            }
        } else {
            self.showAlert(message: "Please install instagram app to share on instagram.")
        }
    }
}

extension FeedVC: AssetListManagerDelegate {
    func assetManagerListDidLoad(_ hasNewData: Bool) {
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
            if hasNewData {
                self.collectionView.reloadData()
                // self.cacheFeedMediaContent()
            }
        }
    }
}

extension FeedVC: PostCellDelegate {
    func postCell(_ cell: PostCell, downloadStateDidChange newState: Asset.DownloadState) {
        // print("download state for asset:\(cell.asset?.post.title ?? "no title") did change to: \(newState.rawValue)")
    }
    
    @objc
    func didTapCell(_ cell: PostCell, hideContent: Bool) {}
}

extension FeedVC: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        print("prefetch: \(indexPaths)")
    }
    
    func collectionView(_ collectionView: UICollectionView, cancelPrefetchingForItemsAt indexPaths: [IndexPath]) {
        print("canceling prefetching...")
    }
}
