//
//  ProfileVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

final class ProfileVC: BaseVC {
    
    @IBOutlet var backButton: UIButton!
    var container = UIView()
    var viewModel: ProfileViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()        
        setContainerFrame()
        setupTableChildView()
        Helpers.setupBackButton(button: backButton)
        navigationController?.navigationBar.barTintColor = UIColor.appRed
    }
    
    private func setContainerFrame() {
        container.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height)
        container.backgroundColor = .green
        view.insertSubview(container, belowSubview: backButton)
    }
    
    private func setupTableChildView() {
        let controller = FeedVC.instantiate(fromAppStoryboard: .feed)
        let vModel = FeedViewModel(type: .profile(id: viewModel.userId))
        controller.viewModel = vModel
        addChild(controller)
        container.addSubview(controller.view)
        controller.view.fill()
        controller.didMove(toParent: self)
        
        controller.showFullImage = { (url) in
            
            let imgVC = TRImageViewController.getVC(imgURL: url)
            self.present(imgVC, animated: true, completion: nil)
            imgVC.backButton.isHidden = false
            
            
        }
        
        controller.tripsterBlock = { () in
            let controller = TripsterListViewController.instantiate(fromAppStoryboard: .tripster)
            let viewModel = TripListViewModel()
            viewModel.userId = self.viewModel.userId
            viewModel.isOnMainTab = false
            if let user = self.viewModel.user,
                let notTripViewModel = NoTripViewModel(user: user) {
                controller.noTripVC.viewModel = notTripViewModel
            }
            controller.viewModel = viewModel
            self.navigationController?.pushViewController(controller, animated: true)
        }
        
        controller.noTripsBlock = { () in
            let controller: NoTripViewController = Router.get()
            if let user = self.viewModel.user,
                let notTripViewModel = NoTripViewModel(user: user) {
                controller.viewModel = notTripViewModel
            }
            self.navigationController?.pushViewController(controller, animated: true)
        }
        controller.placesBlock = { () in
//            let controller = PlacesVC.instantiate(fromAppStoryboard: .places)
//            controller.location = place.name
//            controller.address = nil
//            controller.rating = place.rating
//            controller.viewModel = FeedViewModel(type: .places(id: place.id))
//            controller.isProfile = false
//            controller.userId = self.viewModel.userId
//            self.navigationController?.pushViewController(controller, animated: true)
        }
        controller.followersBlock = { () in
            let controller = FollowViewController.instantiate(fromAppStoryboard: .follow)
            let model = FollowViewModel(type: .follow(type: .follower),userId:self.viewModel.userId)
            controller.viewModel = model
            self.navigationController?.pushViewController(controller, animated: true)
        }
        controller.followingBlock = { () in
            let controller = FollowViewController.instantiate(fromAppStoryboard: .follow)
            let model = FollowViewModel(type: .follow(type: .following),userId:self.viewModel.userId)
            controller.viewModel = model
            self.navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
   
}

