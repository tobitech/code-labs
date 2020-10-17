//
//  OnboardingVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import Pageboy

final class OnboardingVC: PageboyViewController {
    let pageControllers: [PageVC] = {
        
        var viewControllers = [PageVC]()
        for index in 0 ..< 4 {
            let controller = PageVC.instantiate(fromAppStoryboard: .onboarding)
            controller.index = index
            viewControllers.append(controller)
        }
        return viewControllers
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        dataSource = self
        delegate = self
        isInfiniteScrollEnabled = true
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        autoScroller.enable()
        
    }

    @IBAction func guestTapped(_ sender: Any) {
        UserDefaults.standard.set("", forKey: USERID)
        UserDefaults.standard.set("ASd57n4QMrltOHQzXfFqzw==", forKey: APIREQUESTTOKENKEY)
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        self.navigationController?.present(controller!, animated: true, completion: nil)
    }
    
}

extension OnboardingVC: PageboyViewControllerDataSource, PageboyViewControllerDelegate {
    func numberOfViewControllers(in pageboyViewController: PageboyViewController) -> Int {
        return pageControllers.count
    }
    func viewController(for pageboyViewController: PageboyViewController,
                        at index: PageboyViewController.PageIndex) -> UIViewController? {
        return pageControllers[index]
    }
    func defaultPage(for pageboyViewController: PageboyViewController) -> PageboyViewController.Page? {
        return nil
    }
}
