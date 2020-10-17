//
//  HashTagFeedVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 23/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

final class HashTagFeedVC: BaseVC {
    
    @IBOutlet var tagLabel: UILabel!
    @IBOutlet var backButton: UIButton!
    
    var container = UIView()
    var hashTag = ""
    var userId = ""
    var tripId:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        tagLabel.layer.shadowColor = UIColor.black.cgColor
        tagLabel.layer.shadowOffset = CGSize(width : 0.0, height : 0.0);
        tagLabel.layer.shadowRadius = 3.0;
        tagLabel.layer.shadowOpacity = 1;
        tagLabel.layer.shouldRasterize = true
        
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width : 0.0, height : 0.0);
        backButton.layer.shadowRadius = 3.0;
        backButton.layer.shadowOpacity = 1;
        backButton.layer.shouldRasterize = true
        
        if !hashTag.isEmpty {
            tagLabel.text = "# " + hashTag
        } else if !self.userId.isEmpty {
            tagLabel.text = "memories"
        }
        
        setContainerFrame()
        setupTableChildView()
        Helpers.setupBackButton(button: backButton)
    }
    
    private func setContainerFrame() {
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.insertSubview(container, belowSubview: backButton)
    }
    
    private func setupTableChildView() {
        if !self.hashTag.isEmpty {
            let controller = FeedVC.instantiate(fromAppStoryboard: .feed)
            let vModel = FeedViewModel(type: .hash(tag: hashTag))
            controller.viewModel = vModel
            addChild(controller)
            container.addSubview(controller.view)
            controller.view.fill()
            controller.didMove(toParent: self)
        } else if !self.userId.isEmpty {
            let controller = FeedVC.instantiate(fromAppStoryboard: .feed)
            let vModel = FeedViewModel(type: .memories(id: self.userId))
            vModel.tripId = self.tripId
            controller.viewModel = vModel
            controller.viewModel.fetchRemoteFeeds()
            addChild(controller)
            container.addSubview(controller.view)
            controller.view.fill()
            controller.didMove(toParent: self)
        }
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
}
