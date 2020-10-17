//
//  FeedTableViewCell.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import Cosmos
//import ActiveLabel

class FeedTableViewCell: UITableViewCell {

    weak var videoView: AVPlayerView? {
        didSet {
            oldValue?.jp_stopPlay()
        }
    }
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var likesCountButton: UIButton!
    @IBOutlet private weak var pinButton: UIButton!
    @IBOutlet private weak var pinCountButton: UIButton!
    
    @IBOutlet private weak var commentCountButton: UIButton!
    @IBOutlet private weak var profileImageButton: UIButton!
    @IBOutlet private weak var nameButton: UIButton!
    @IBOutlet private weak var captionLabel: ActiveLabel!
    @IBOutlet private weak var isFeatured: UIImageView!
    @IBOutlet private weak var addStackView: UIStackView!
    
    @IBOutlet private weak var place1Label: UILabel!
    @IBOutlet private weak var place2Label: UILabel!
//    @IBOutlet private weak var fullThumbnailView: UIView!
    @IBOutlet private weak var viewCountLabel: UILabel!
    @IBOutlet private weak var ratingView: CosmosView!
    @IBOutlet private weak var placeStackView: UIStackView!
    @IBOutlet private weak var viewCountStackView: UIStackView!
    @IBOutlet private weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var pageControl: UIPageControl!
    
    @IBOutlet var hidingViews: [UIView]!
    
    private var playCount = 0
    var feedId: String?
    
    var addFeaturedBlock: (() -> ())?
    var pinBlock: (() -> ())?
    var optionBlock:(() -> ())?
    var starBlock:(() -> ())?
    var likeBlock:(() -> ())?
    var commentBlock:(() -> ())?
    var viewCountBlock:(() -> ())?
    var likeCountBlock:(() -> ())?
    var pinCountBlock:(() -> ())?
    var profileBlock:(() -> ())?
    var placeBlock:(() -> ())?
    var hashtagBlock:((String,FeedTableViewCell) -> ())?
    var mentionBlock:((String) -> ())?
    var loadVideo: (()->())?
//    var showFullImage:((URL?) -> ())?
    
    private let customTypeHash = ActiveType.custom(pattern: "\\s#\\b") //Regex that looks for "with"
    private let customTypeMention = ActiveType.custom(pattern: "\\s@\\b") //Regex that looks for "with"
    var videoURLString = ""
    private var videos: [String] = []
    private var images: [String] = []
    
    static var identifier: String {
        return String(describing: self)
    }

    static var Nib: UINib {
        return UINib(nibName: identifier, bundle: Bundle.init(for: FeedTableViewCell.self))
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()

        captionLabel.enabledTypes = [.mention, .hashtag, .url, customTypeHash, customTypeMention]

        profileImageButton.rounded()

        let placesTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.placeTapped))
        placeStackView.addGestureRecognizer(placesTapGesture)
        
        let viewCountTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.viewCountTapped))
        viewCountStackView.addGestureRecognizer(viewCountTapGesture)

        let ratingTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.ratingTapped))
        ratingView.addGestureRecognizer(ratingTapGesture)

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(self.optionsTapped(_:)))
        collectionView.addGestureRecognizer(longPressGesture)
        
//        let thumbnailTapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapped))
//        fullThumbnailView.addGestureRecognizer(thumbnailTapGesture)
        
        if Helpers.hasTopNotch {
            bottomConstraint.constant = 85
        }
        
        addStackView.isHidden = kAppDelegate.user?.registrationType != "admin"
        
        collectionView.register(FeedCollectionViewCell.self, reuseIdentifier: "FeedCollectionViewCell")
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
    }
    
    @objc private func placeTapped() {
        placeBlock?()
    }
    
    @objc func ratingTapped() {
        starBlock?()
    }
    
    @objc func tapped() {
        print("tapped")
    }
    
    @objc func optionsTapped(_ gesture: UILongPressGestureRecognizer) {
        print("gesture")
        if gesture.state == .began {
            optionBlock?()
        }
    }
    
    @objc private func viewCountTapped() {
        viewCountBlock?()
    }
    
    @IBAction private func profileTapped() {
        profileBlock?()
    }
    
    @IBAction private func commentCountTapped() {
        commentBlock?()
    }
    
    @IBAction private func commentTapped() {
        commentBlock?()
    }
    
    @IBAction private func likeCountTapped() {
        likeCountBlock?()
    }
    
    @IBAction private func pinCountTapped() {
        pinCountBlock?()
    }
    
    @IBAction private func likeTapped() {
        likeBlock?()
    }
    
    @IBAction private func pinTapped() {
        pinBlock?()
    }
    
    @IBAction func addTapped(_ sender: Any) {
        addFeaturedBlock?()
    }
    
    func changeMode(hideViews: Bool) {
        hidingViews.forEach{$0.isHidden = hideViews}
    }
    
    func configure(with feed: Feed, hideViews: Bool) {
        
        feedId = feed.id
        
        commentCountButton.isHidden = feed.commentCount == "0"
        likesCountButton.isHidden = feed.likeCount == "0"
        pinCountButton.isHidden = feed.pinCount == "0"
        viewCountStackView.isUserInteractionEnabled = feed.viewcount > 0
        
        commentCountButton.setTitle(feed.commentCount, for: .normal)
        likesCountButton.setTitle(feed.likeCount == "0" ? "" : feed.likeCount, for: .normal)
        pinCountButton.setTitle(feed.pinCount == "0" ? "" : feed.pinCount, for: .normal)
        ratingView.rating = Double(feed.rating) ?? 0
        viewCountLabel.text = "\(feed.viewcount)"
        
        nameButton.setTitle("@" + feed.username, for: .normal)
        place1Label.text = feed.feedLocation
        
        let timeInterval = Helpers.timeStampToTimeAbbreviatedStringType(timeStamp: feed.createdOn, unitStyle: .short)
        let components = timeInterval.components(separatedBy: " ")
        let time = components.first ?? ""
        let unit = components.last ?? ""
        
        let attributedString = NSMutableAttributedString(string: time, attributes: [.font: UIFont(name: "PTSans-Bold", size: 15)!, .foregroundColor: UIColor(hexString: "#ffffff")])
        attributedString.append(NSAttributedString(string: " \(unit) ago", attributes: [.font: UIFont(name: "PTSans-Regular", size: 15)!, .foregroundColor: UIColor(hexString: "#ffffff")]))
        
        place2Label.attributedText = attributedString

        let str = feed.component
        let escapedString = str.replacingOccurrences(of: "\n", with: " ")
        if escapedString.count > 0 {
            self.customizeCaption(text:String(format:" %@",escapedString))
        }
        
        if feed.likeStatus == "false" {
            likeButton.setImage(UIImage(named: "heart-shadow"), for: .normal)
        } else {
            likeButton.setImage(UIImage(named: "heart-shadow-red"), for: .normal)
        }
        if feed.pinStatus == "false" {
            pinButton.tintColor = .white
//            pinButton.setImage(UIImage(named: "pinIconShadow"), for: .normal)
        } else {
            pinButton.tintColor = .appRed
//            pinButton.setImage(UIImage(named: "pinIcon"), for: .normal)
        }

        
        profileImageButton.sd_setImage(with: URL(string: feed.userImage), for: .normal, placeholderImage: UIImage(named: "userAvatar"))
        
//        if let url = URL.init(string: feed.imageURL) {
//            feedImageView.sd_setImage(with: url, completed: nil)
//        }
//        let cdnUrl = "https://file-examples.com/wp-content/uploads/2017/04/file_example_MP4_1280_10MG.mp4, https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4, https://s3-us-west-2.amazonaws.com/trajilis/5ce39466719b6100010c2b6c-video-592162890182991.mp4"
        videos = feed.cdnUrl.components(separatedBy: ", ")
        images = feed.imageURL.components(separatedBy: ", ")
        collectionView.reloadData()
        isFeatured.isHidden = feed.parentId.isEmpty
        
        changeMode(hideViews: hideViews)
        
        let index = getVisibleIndexPath()?.item ?? 0
        videoURLString = videos.item(at: index) ?? ""
        
    }
    
    private func customizeCaption(text:String) {
        captionLabel.customize { label in
            if text.count > 200 {
                let sstring = text.prefix(200)
                label.text = String(sstring)
            } else {
                label.text = text
            }
            label.textColor = UIColor.white
            label.customColor[customTypeHash] = .appRed
            label.customColor[customTypeMention] = .appRed
            label.handleHashtagTap { [weak self](tag) in
                if let strngSelf = self {
                    self?.hashtagBlock?(tag,strngSelf)
                }
            }
            label.handleMentionTap { [weak self](tag) in
                self?.mentionBlock?(tag)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        playCount = 0
        captionLabel.text = ""
        profileImageButton.setImage(nil, for: .normal)
        collectionView.contentOffset.x = 0
        pageControl.numberOfPages = 1
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        collectionView.reloadData()
    }
}

extension FeedTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        pageControl.numberOfPages = videos.count
        return videos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(FeedCollectionViewCell.self, for: indexPath)
        cell.feedImageView.image = nil
        if let imageURLString = images.item(at: indexPath.item),
            let url = URL.init(string: imageURLString) {
            cell.feedImageView.sd_setImage(with: url, completed: nil)
        }
        cell.layoutIfNeeded()
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return collectionView.bounds.size
    }
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let cell = cell as! FeedCollectionViewCell
        self.videoView = cell.videoView
        videoURLString = videos.item(at: indexPath.item) ?? ""
        loadVideo?()
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let visibleIndexPath = getVisibleIndexPath(),
            let cell = collectionView.cellForItem(at: visibleIndexPath) as? FeedCollectionViewCell {
            self.videoView = cell.videoView
            videoURLString = videos.item(at: visibleIndexPath.item) ?? ""
            loadVideo?()
            pageControl.currentPage = visibleIndexPath.item
        }
    }
    
    private func getVisibleIndexPath() -> IndexPath? {
        let visibleRect = CGRect(origin: collectionView.contentOffset, size: collectionView.bounds.size)
        let visiblePoint = CGPoint(x: visibleRect.midX, y: visibleRect.midY)
        return collectionView.indexPathForItem(at: visiblePoint)
    }
    
}
//"url" : "https:\/\/s3-us-west-2.amazonaws.com\/trajilis\/5ce39466719b6100010c2b6c-video-592162890182991.mp4, https:\/\/s3-us-west-2.amazonaws.com\/trajilis\/5ce39466719b6100010c2b6c-video-592162929216931.mp4",
//"place_id" : "52c2898c498e894a0599df12",
//"createdon" : "1570470150",
//"image_url" : "https:\/\/s3-us-west-2.amazonaws.com\/trajilis\/5ce39466719b6100010c2b6c-image-592162946205423.png, https:\/\/s3-us-west-2.amazonaws.com\/trajilis\/5ce39466719b6100010c2b6c-image-592162947921575.png",
//"like_count" : "0",
//"f_name" : "Bharat",
