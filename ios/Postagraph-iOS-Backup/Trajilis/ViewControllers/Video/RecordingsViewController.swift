//
//  RecordingsViewController.swift
//  Trajilis
//
//  Created by bharats802 on 23/05/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class RecordingsViewController: BaseVC {

    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var noDataLabel: UILabel!
    
    var arrVideos:[VideoRecordModel]?
    var isShowingSavedRecordings = false
    var savedVideos:[SavedRecording]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Saved For Later"
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
        if isShowingSavedRecordings {
            self.savedVideos = SavedRecording.getSavedRecordings()
        }
        self.collectionView.reloadData()
    }
    func removeRecording(url:URL) {
        guard let array = self.arrVideos else {
            return
        }
        var index = 0
        for rec in array {
            if rec.videoURL == url {
                break
            }
            index = index + 1
        }
        self.arrVideos?.remove(at: index)
    }
    
    @objc private func btnDeleteRecordingTapped(sender:UIButton) {
        
        if isShowingSavedRecordings {
            guard  let videos = self.savedVideos, videos.count > sender.tag else {
                return
            }
            let video = videos[sender.tag]
            let moc = video.managedObjectContext
            moc?.performAndWait {
                do {
                    if let vid = video.getVideoURL() {
                        Helpers.removeFile(url: vid)
                    }
                    moc?.delete(video)
                    try moc?.save()
                } catch {
                    print(error)
                }
            }
            self.savedVideos = SavedRecording.getSavedRecordings()
        } else {
            guard  let videos = self.arrVideos, videos.count > sender.tag else {
                return
            }
            let video = videos[sender.tag]
            if let vid = video.videoURL {
                self.removeRecording(url: vid)
            }
        }
        self.collectionView.reloadData()
    }
}

extension RecordingsViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let rows = self.getNumberOfRows()
        noDataLabel.isHidden = rows > 0
        return rows
    }
    
    func getNumberOfRows() -> Int {
        if isShowingSavedRecordings {
            guard  let videos = self.savedVideos, !videos.isEmpty else {
                return 0
            }
            return videos.count
        } else {
            guard  let videos = self.arrVideos, !videos.isEmpty else {
                return 0
            }
            return videos.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(RecordingsCollectionViewCell.self, for: indexPath)
        if isShowingSavedRecordings {
            guard  let videos = self.savedVideos, videos.count > indexPath.item else {
                return cell
            }
            let video = videos[indexPath.item]
            cell.imageView.image = video.getThumbnail()
        } else {
            guard  let videos = self.arrVideos, videos.count > indexPath.row else {
                return cell
            }
            let video = videos[indexPath.item]
            cell.imageView.image = video.getThumbnail()
        }
        cell.deleteButton.tag = indexPath.item
        cell.deleteButton.addTarget(self, action: #selector(btnDeleteRecordingTapped(sender:)), for: .touchUpInside)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if isShowingSavedRecordings {
            guard  let videos = self.savedVideos, videos.count > indexPath.row else {
                return
            }
            let video = videos[indexPath.item]
            
            let controller = PreviewVC.instantiate(fromAppStoryboard: .video)
//            controller.coverImage = video.getThumbnail()
            controller.isProfile = false
            controller.videoURLs = [video.getVideoURL()!]
            controller.isFromRecordings = true
            controller.savedRecord = video
            self.navigationController?.pushViewController(controller, animated: true)
            
        } else {
//            guard  let videos = self.arrVideos, videos.count > indexPath.row else {
//                return
//            }
//            let video = videos[indexPath.item]
//            let controller = PreviewVC.instantiate(fromAppStoryboard: .video)
////            controller.coverImage = video.getThumbnail()
//            controller.isProfile = false
//            controller.videoURL = video.videoURL
//            controller.isFromRecordings = true
//            self.navigationController?.pushViewController(controller, animated: true)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.width - 4)/3
        let height = width*163/124
        return CGSize(width: width, height: height)
    }
    
}

class RecordingsCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var playImageView: UIImageView!
    @IBOutlet weak var deleteButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        contentView.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        contentView.layer.shadowOpacity = 1
        contentView.layer.shadowRadius = 3
        contentView.layer.shadowOffset = CGSize(width: 0, height: 0)
    }
    
}
