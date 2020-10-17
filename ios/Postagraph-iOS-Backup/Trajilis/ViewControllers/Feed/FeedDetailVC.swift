//
//  FeedDetailVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 08/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class FeedDetailVC: BaseVC {

    @IBOutlet var backButton: UIButton!
    
    var feedId: String!
    var container = UIView()
    var feeds: [Feed]?
    var selectedFeedIndex: Int = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setContainerFrame()
        setupTableChildView()
//        Helpers.setupBackButton(button: backButton)
    }

    private func setContainerFrame() {
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.insertSubview(container, belowSubview: backButton)
    }

    private func setupTableChildView() {
        let controller = FeedVC.instantiate(fromAppStoryboard: .feed)
        
        if let feeds = self.feeds {
            let vModel = FeedViewModel(type: .withFeeds(feeds: feeds))
            vModel.selectedFeedIndex = selectedFeedIndex
            controller.viewModel = vModel
            controller.showHud = false
        } else {
            let vModel = FeedViewModel(type: .singleFeed(feedId: feedId))
            controller.viewModel = vModel
        }
        addChild(controller)
        container.addSubview(controller.view)
        controller.view.fill()
        controller.didMove(toParent: self)
    }

    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

}
