//
//  PreviewVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 14/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import AVKit
import CoreLocation

final class PreviewVC: BaseVC {
    
    @IBOutlet var videoView: AVPlayerView!
    @IBOutlet var btnSaveForLater: TrajilisButton!
    @IBOutlet var btnPostMemory: TrajilisButton!
    @IBOutlet weak var muteButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var singleVideoActionStackView: UIStackView!
    @IBOutlet var multipleVideoViews: [UIView]!
    
    fileprivate var player: AVPlayer!
    fileprivate var playerLayer: AVPlayerLayer!
    var videoURLs: [URL] = []
//    private var coverImages: [UIImage]?
    
    var isProfile = false
    var didFinishRecording:((URL?, UIImage?) -> Void)?
    var isViewVisible:Bool = true
    
    var isFromRecordings:Bool = false
    var savedRecord: SavedRecording? {
        didSet {
            if let savedRecordURL = savedRecord?.getVideoURL() {
                videoURLs = [savedRecordURL]
            }
        }
    }

    var observer: NSObjectProtocol?
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Preview"
        kAppDelegate.setupSound(isPrimary: false)
    
        setupPlayer()
        //self.btnSaveForLater.setGradient = true
        //btnSaveForLater.setGradient = true
        btnPostMemory.addTarget(self, action: #selector(continueTapped(_:)), for: .touchUpInside)
        btnSaveForLater.setTitleColor(UIColor.white, for: .normal)
        self.btnSaveForLater.isHidden = true
        //        if self.isFromRecordings {
        if self.savedRecord == nil {
            self.btnSaveForLater.isHidden = false
        }
        //        }
        if !self.isFromRecordings {
            if  let status = Network.reachability?.status, status == .unreachable {
                self.showAlert(message: "Looks like there is no internet access right now. You can still save the recording for later and and try posting later when there’s internet connection.")
            }
        }
        
        if isProfile {
            navigationItem.rightBarButtonItem = nil
            btnSaveForLater.isHidden = true
            btnPostMemory.setTitle("Upload", for: .normal)
        }
        
        collectionView.delegate = self
        collectionView.dataSource = self
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tappedOnCollectionView(_:)))
        videoView.addGestureRecognizer(tapGesture)
        
       setMultiple()
    }
    
    private func setMultiple() {
        let isMultiple = videoURLs.count > 1
        
        multipleVideoViews.forEach({
            $0.isHidden = !isMultiple
        })
        singleVideoActionStackView.isHidden = isMultiple
        deleteButton.isHidden = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.prefersLargeTitles = false
        showNavigationBar()
        player?.play()
        
        let isMuted = player?.isMuted ?? true
        kAppDelegate.setupSound(isPrimary: !isMuted)
        
        self.isViewVisible = true
        
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .done, target: self, action: #selector(self.close))
        barButtonItem.imageInsets = UIEdgeInsets(top: -1.5, left: -8, bottom: 1.5, right: 8)
        navigationItem.leftBarButtonItem = barButtonItem
        
        let cropBarButton = UIBarButtonItem(image: UIImage.init(named: "crop"), style: .plain, target: self, action: #selector(cropTapped))
        navigationItem.rightBarButtonItem = cropBarButton
    }
    
    @objc private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        player.pause()
        self.isViewVisible = false
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        kAppDelegate.setupSound(isPrimary: false)
    }
    
    @IBAction func muteTapped(_ sender: Any) {
        muteButton.isSelected = !muteButton.isSelected
        player.isMuted = muteButton.isSelected
        kAppDelegate.setupSound(isPrimary: !player.isMuted)
    }
    
    @IBAction func btnSaveForLaterTapped(sender:UIButton) {
        self.checkLocation()
    }
    
    func saveVideo(location: CLLocationCoordinate2D) {
        var isMoreRecordings = false
        for videoURL in videoURLs {
            if let obj = SavedRecording.getNewSaving() {
                obj.filepath = videoURL.lastPathComponent
                obj.recordedOn = Date().timeIntervalSince1970
                obj.lat = location.latitude
                obj.lng = location.longitude
                do {
                    try obj.managedObjectContext?.save()
                } catch {
                    print(error)
                }
            }
            if let vcs = self.navigationController?.viewControllers {
                for vc in vcs {
                    if let recVC = vc as? RecordingsViewController {
                        recVC.removeRecording(url: videoURL)
                        isMoreRecordings = (recVC.arrVideos?.count ?? 0) > 0
                        break
                    }
                }
            }
        }
    
        if(isMoreRecordings) {
            self.navigationController?.popViewController(animated: true)
        } else {
            self.navigationController?.dismiss(animated: true, completion: {
                NotificationCenter.default.post(name: Constants.NotificationName.Reload, object: nil)
            })
        }
    }
    
    private func checkLocation() {
        
        if Network.reachability?.status == .unreachable {
            Locator.shared.setAccuracy(isHigh: false)
        }
        Locator.shared.authorize()
        Locator.shared.locate { (result) in
            Locator.shared.setAccuracy()
            switch result {
            case .success(let location):
                if let loc = location.location {
                    UserDefaults.standard.set(loc.coordinate.latitude, forKey: "latitude")
                    UserDefaults.standard.set(loc.coordinate.longitude, forKey: "longitude")
                    self.saveVideo(location: loc.coordinate)
                } else {
                    self.showAlert(message: "Unable to find current location.")
                }
                Locator.shared.reset()
            case .failure(_):
                let alertController = UIAlertController(title: "Error", message: "Enable Location permissions in settings", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (alertAction) in
                    if let appSettings = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                    }
                }
                alertController.addAction(settingsAction)
                // If user cancels, do nothing, next time Pick Video is called, they will be asked again to give permission
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                alertController.addAction(cancelAction)
                // Run GUI stuff on main thread
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
    
    @objc private func continueTapped(_ sender: UIBarButtonItem?) {
        if isProfile {
            self.navigationController?.dismiss(animated: true, completion: {
                self.didFinishRecording?(self.videoURLs[0], self.getVideoThumbnail(url: self.videoURLs[0]))
            })
        } else {
            let controller = ReadyToPostVC.instantiate(fromAppStoryboard: .video)
            controller.coverImages = videoURLs.compactMap(getVideoThumbnail(url:))
            controller.videoURLs = videoURLs
            controller.isFromRecordings = self.isFromRecordings
            controller.savedRecord = self.savedRecord
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @objc private func cropTapped() {
        let cropVC: VideoCropperViewController = Router.get()
             cropVC.videoURL = videoURLs[selectedIndexPath.item]
        cropVC.completion = { [weak self] url in
            self?.videoURLs[self!.selectedIndexPath.item] = url
            self?.collectionView.reloadItems(at: [self!.selectedIndexPath])
            self?.setupPlayer()
        }
        self.navigationController?.pushViewController(cropVC, animated: true)
    }
    
    private func setupPlayer() {
        let playerItem = AVPlayerItem(url: videoURLs[selectedIndexPath.row])
        player = AVPlayer(playerItem: playerItem)
        guard let playerLayer = videoView.layer as? AVPlayerLayer else { return }
        playerLayer.player = player
        playerLayer.frame = view.bounds
        playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.isMuted = true
        player.play()
        observer = NotificationCenter.default
            .addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                         object: player.currentItem, queue: nil, using: {[weak self] (_) in
                            DispatchQueue.main.async {
                                if let strngSelf = self {
                                    if strngSelf.isViewVisible {
                                        strngSelf.player.seek(to: CMTime.zero)
                                        strngSelf.player.play()
                                    } else {
                                        strngSelf.player.pause()
                                    }
                                }
                            }
            })
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        continueTapped(nil)
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        videoURLs.remove(at: selectedIndexPath.item)
        selectedIndexPath = IndexPath(item: 0, section: 0)
        setMultiple()
        collectionView.reloadData()
    }
    
    var selectedIndexPath: IndexPath = IndexPath(item: 0, section: 0)
    @objc private func tappedOnCollectionView(_ gesture: UITapGestureRecognizer) {
        let location = gesture.location(in: collectionView)
        if let indexPath = collectionView.indexPathForItem(at: location) {
            let cell = collectionView.cellForItem(at: indexPath) as? CameraCaptureThumbnailCollectionViewCell
            cell?.selectedRecording = true
            
            let x = collectionView.convert(.zero, from: cell!).x + cell!.frame.width/2
            
            deleteButton.isHidden = false
            deleteButton.alpha = 0
            deleteButton.center.x = x + 25
            UIView.animate(withDuration: 0.2) {
                self.deleteButton.alpha = 1
            }
            if indexPath != selectedIndexPath {
                let oldSelctedCell = collectionView.cellForItem(at: selectedIndexPath) as? CameraCaptureThumbnailCollectionViewCell
                oldSelctedCell?.selectedRecording = false
            }
            selectedIndexPath = indexPath
            setupPlayer()
        }else {
            deleteButton.isHidden = true
        }
    }
    
    private func getVideoThumbnail(url: URL) -> UIImage? {
        let asset = AVURLAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        if let cgImage = try? generator.copyCGImage(at: CMTime(seconds: 0, preferredTimescale: 1), actualTime: nil) {
            return UIImage(cgImage: cgImage)
        }
        return nil
    }
    
}

extension PreviewVC: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return videoURLs.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(CameraCaptureThumbnailCollectionViewCell.self, for: indexPath)
        let url = videoURLs[indexPath.item]
        cell.imageView.image = getVideoThumbnail(url: url)
        cell.selectedRecording = selectedIndexPath == indexPath
        return cell   
    }
    
}
