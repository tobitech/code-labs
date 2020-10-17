//
//  LikedFeedVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

final class LikedFeedVC: UIViewController {
    @IBOutlet var backButton: UIButton!
    
    var container = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.layer.shadowColor = UIColor.black.cgColor
        backButton.layer.shadowOffset = CGSize(width : 0.0, height : 0.0);
        backButton.layer.shadowRadius = 3.0;
        backButton.layer.shadowOpacity = 1;
        backButton.layer.shouldRasterize = true
        
        setContainerFrame()
        setupTableChildView()
        Helpers.setupBackButton(button: backButton)
    }
    
    private func setContainerFrame() {
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        view.insertSubview(container, belowSubview: backButton)
    }
    
    private func setupTableChildView() {
        let controller = FeedVC.instantiate(fromAppStoryboard: .feed)
        let vModel = FeedViewModel(type: .likedFeed)
        controller.viewModel = vModel
        addChild(controller)
        container.addSubview(controller.view)
        controller.view.fill()
        controller.didMove(toParent: self)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}
