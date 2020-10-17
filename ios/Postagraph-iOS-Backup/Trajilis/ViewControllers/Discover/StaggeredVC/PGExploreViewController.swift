
import UIKit
import AVFoundation
import SDWebImage

class PGExploreViewController: BaseVC {
    
    @IBOutlet weak var tblView:UITableView!
    var viewModel: ExploreViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Explore"
        getExploreFeeds()
        
        self.tblView.backgroundColor = UIColor.clear
        self.tblView.tableFooterView = UIView()
        self.tblView.separatorStyle = .none
        
        self.tblView.register(PGStaggeredCell.classForCoder(), forCellReuseIdentifier: PGStaggeredCell.identifier)
        self.tblView.register(UINib(nibName: PGStaggeredCell.identifier, bundle: nil), forCellReuseIdentifier: PGStaggeredCell.identifier)
        
        self.tblView.register(PGStaggeredLeftCell.classForCoder(), forCellReuseIdentifier: PGStaggeredLeftCell.identifier)
        self.tblView.register(UINib(nibName: PGStaggeredLeftCell.identifier, bundle: nil), forCellReuseIdentifier: PGStaggeredLeftCell.identifier)

        self.tblView.register(PGStaggeredRightCell.classForCoder(), forCellReuseIdentifier: PGStaggeredRightCell.identifier)
        self.tblView.register(UINib(nibName: PGStaggeredRightCell.identifier, bundle: nil), forCellReuseIdentifier: PGStaggeredRightCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showNavigationBar()
    }
    
    func numberOfCells() -> Int {
        let count = viewModel.feeds.count
        let num = count/3
        let numOfCell = (count%3 == 0) ? num : num + 1
        return numOfCell
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
                self?.tblView.reloadData()
            }
        }
    }
    
}
extension PGExploreViewController : UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.numberOfCells()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let itemIndex = indexPath.row * 3
        if indexPath.row % 4 == 0 {
            if indexPath.row % 8 == 0 {
                let cell = tableView.dequeueReusableCell(withIdentifier: PGStaggeredLeftCell.identifier, for: indexPath) as! PGStaggeredLeftCell
                self.fillCell(cell: cell, index: itemIndex)
                return cell
            } else {
                let cell = tableView.dequeueReusableCell(withIdentifier: PGStaggeredRightCell.identifier, for: indexPath) as! PGStaggeredRightCell
                self.fillCell(cell: cell, index: itemIndex)
                return cell
            }
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: PGStaggeredCell.identifier, for: indexPath) as! PGStaggeredCell

            self.fillCell(cell: cell, index: itemIndex)

            return cell
        }
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if indexPath.row % 4 == 0 {
            return (view.bounds.width-1)/2
        } else {
            return (view.bounds.width-2)/3
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath.row == viewModel.feeds.count - 1 {
            getExploreFeeds()
        }
    }
    
    func fillCell(cell: PGStaggeredBaseCell, index:Int) {

        cell.imgView1.image = nil
        cell.imgView2.image = nil
        cell.imgView3.image = nil
        
        cell.imgView1.isHidden = false
        cell.imgView2.isHidden = false
        cell.imgView3.isHidden = false
        cell.videoView?.isUserInteractionEnabled = false

        var videoIndex = 0
        if cell.isKind(of: PGStaggeredLeftCell.classForCoder()) {
            videoIndex = 2
        } else if cell.isKind(of: PGStaggeredRightCell.classForCoder()) {
            videoIndex = 1
        }
        
        var itemIndex = index
        cell.contentView.backgroundColor = .white
        if self.viewModel.feeds.count > itemIndex {
            let feed = self.viewModel.feeds[itemIndex]
            if let url = URL(string: feed.imageURL) {
                cell.imgView1.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgView1.sd_setImage(with: url, completed: nil)

 
                cell.imgView1.tag = itemIndex
            }
            if videoIndex == 1 {
                setupVideoFor(cell:cell, urlString: feed.cdnUrl)
            }
        }
        itemIndex = itemIndex + 1
        if self.viewModel.feeds.count > itemIndex {
            let feed = self.viewModel.feeds[itemIndex]
            if let url = URL(string: feed.imageURL) {
                cell.imgView2.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgView2.sd_setImage(with: url, completed: nil)

                
                cell.imgView2.tag = itemIndex
            }
            if videoIndex == 2 {
                setupVideoFor(cell:cell,urlString: feed.cdnUrl)
            }
            
        }
        
        itemIndex = itemIndex + 1
        if self.viewModel.feeds.count > itemIndex {
            let feed = self.viewModel.feeds[itemIndex]
            if let url = URL(string: feed.imageURL) {
                cell.imgView3.sd_imageIndicator = SDWebImageActivityIndicator.gray
                cell.imgView3.sd_setImage(with: url, completed: nil)
                cell.imgView3.tag = itemIndex
            }
        }
        
        if let gestures = cell.imgView1.gestureRecognizers {
            for recog in gestures{
                cell.imgView1.removeGestureRecognizer(recog)
            }
        }
        if let gestures = cell.imgView2.gestureRecognizers {
            for recog in gestures{
                cell.imgView2.removeGestureRecognizer(recog)
            }
        }
        if let gestures = cell.imgView3.gestureRecognizers {
            for recog in gestures{
                cell.imgView3.removeGestureRecognizer(recog)
            }
        }
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        cell.imgView1.isUserInteractionEnabled = true
        cell.imgView1.addGestureRecognizer(tapGestureRecognizer)
        
        let tapGestureRecognizer2 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        cell.imgView2.isUserInteractionEnabled = true
        cell.imgView2.addGestureRecognizer(tapGestureRecognizer2)
        
        let tapGestureRecognizer3 = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
        cell.imgView3.isUserInteractionEnabled = true
        cell.imgView3.addGestureRecognizer(tapGestureRecognizer3)
    }
    func tableView(_ tableView: UITableView, didEndDisplaying cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if let cll = cell as? PGStaggeredBaseCell {
            cll.videoView?.player?.pause()
            cll.videoView?.player = nil
            if let observer = cll.observer {
                NotificationCenter.default.removeObserver(observer)
            }
        }
    }
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        if !Helpers.isLoggedIn() {
            unauthenticatedBlock(canDismiss: true)
            return
        }
        
        if let tappedImage = tapGestureRecognizer.view as? UIImageView {
            if viewModel.feeds.count > tappedImage.tag {
                let controller = FeedDetailVC.instantiate(fromAppStoryboard: .feed)
                controller.feeds = viewModel.feeds
                controller.selectedFeedIndex = tappedImage.tag
                controller.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
  
    
    func setupVideoFor(cell: PGStaggeredBaseCell, urlString: String) {
        guard let videoView = cell.videoView, let url = URL.init(string: urlString) else { return }
        videoView.playerLayer.player?.pause()
        videoView.playerLayer.player = nil
        let player = AVPlayer(url: url)
        player.automaticallyWaitsToMinimizeStalling = false
        videoView.alpha = 1
        videoView.playerLayer.player = player
        videoView.playerLayer.videoGravity = AVLayerVideoGravity.resizeAspectFill
        player.isMuted = true
        player.play()

        cell.observer = NotificationCenter.default
            .addObserver(forName: .AVPlayerItemDidPlayToEndTime,
                         object: videoView.player?.currentItem, queue: nil, using: { (_) in
                            DispatchQueue.main.async {
                                videoView.player?.seek(to: CMTime.zero)
                                videoView.player?.play()
                            }
            })
    }
}

extension Array {
    func randomItem() -> Element? {
        if isEmpty { return nil }
        let index = Int(arc4random_uniform(UInt32(self.count)))
        return self[index]
    }
}
