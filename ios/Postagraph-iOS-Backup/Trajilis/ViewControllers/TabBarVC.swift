//
//  TabBarVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

enum kTabIndex: Int {
    case Terminal = 0
    case Book = 4
    case Post = 2
    case Tripster = 3
    case Explore = 1
}

class TabBarVC: UITabBarController, UITabBarControllerDelegate {

    var previousViewController: UIViewController?

    override func viewDidLoad() {
        super.viewDidLoad()
        self.delegate = self
        kAppDelegate.mainTabbar = self
        // Do any additional setup after loading the view.
        self.setupTabBar()
    }
    
    func setupTabBar() {
        let tabBar = self.tabBar
        
        tabBar.unselectedItemTintColor = UIColor(hexString: "#C7C6C6")
        tabBar.tintColor = .white
        
        tabBar.items?.forEach {
            $0.setTitleTextAttributes([.font: UIFont(name: "PTSans-Bold", size: 9)!], for: .normal)
            $0.titlePositionAdjustment = UIOffset(horizontal: 0, vertical: -4)
        }
        
        let terminalItem = tabBar.items?[kTabIndex.Terminal.rawValue]
        terminalItem?.selectedImage = UIImage(named:"homeTab")
        terminalItem?.image = UIImage(named:"homeTab")
        terminalItem?.title = "Home"
        
        let tripsterItem = tabBar.items?[kTabIndex.Tripster.rawValue]
        tripsterItem?.selectedImage = UIImage(named:"briefcaseTab")
        tripsterItem?.image = UIImage(named:"briefcaseTab")
        tripsterItem?.title = "Tripster"
        
        let bookItem = tabBar.items?[kTabIndex.Book.rawValue]
        bookItem?.selectedImage = UIImage(named:"travelBeach")
        bookItem?.image = UIImage(named:"travelBeach")
        bookItem?.title = "Book"

        let exploreItem = tabBar.items?[kTabIndex.Explore.rawValue]
        exploreItem?.selectedImage = UIImage(named:"searchTab")
        exploreItem?.image = UIImage(named:"searchTab")
        exploreItem?.title = "Discover"
    }

    func tabBarController(_ tabBarController: UITabBarController, shouldSelect viewController: UIViewController) -> Bool {
        if let messageVC = viewControllers?[kTabIndex.Tripster.rawValue] {
            if messageVC == viewController {
                if !Helpers.isLoggedIn() {
                    unauthenticatedBlock(canDismiss: true)
                    return false
                }
            }
        }

//        if let searchVC = viewControllers?[kTabIndex.Explore.rawValue] {
//            if searchVC == viewController {
//                if !Helpers.isLoggedIn() {
//                    unauthenticatedBlock(canDismiss: true)
//                    return false
//                }
//            }
//        }

        if let centerVC = viewControllers?[kTabIndex.Post.rawValue] {
            if viewController == centerVC {
                if !Helpers.isLoggedIn() {
                    unauthenticatedBlock(canDismiss: true)
                    return false
                }
                openCamera()
                return false
            }
        }
        
        let index = viewControllers?.firstIndex(of: viewController) ?? 0
        if index == 0 {
            tabBar.tintColor = .white
        }else {
            tabBar.tintColor = UIColor(hexString: "#D63D41")
        }
        
        return true
    }

    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        let tabBarIndex = tabBarController.selectedIndex
        let rootVC = (viewController as? UINavigationController)?.viewControllers.first
        if tabBarIndex == 0 && (previousViewController == rootVC || previousViewController == nil){
            (rootVC as? TerminalVC)?.scrolToTop()
        }
        previousViewController = rootVC
    }

//    func unauthenticatedBlock(canDismiss: Bool) {
//        let controller = AnonymousSignupVC.instantiate(fromAppStoryboard: .main)
//        controller.didDismiss = { [weak self] in
//            self?.dim(.out, speed: 0)
//        }
//        controller.canDismiss = canDismiss
//        controller.definesPresentationContext = true
//        controller.modalPresentationStyle = .overFullScreen
//        controller.providesPresentationContextTransitionStyle = true
//        self.dim(.in, color: UIColor.black, alpha: 0.3, speed: 0.5)
//        present(controller, animated: true, completion: nil)
//    }

}
