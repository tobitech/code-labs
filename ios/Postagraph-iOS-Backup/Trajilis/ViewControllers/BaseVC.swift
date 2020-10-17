//
//  BaseVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 31/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class BaseVC: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        
//        if(Helpers.isLoggedIn()) {
//            Locator.shared.authorize()
//            
//            Locator.shared.locate { (result) in
//                switch result {
//                case .success(let location):
//                    if let loc = location.location {
//                        UserDefaults.standard.set(loc.coordinate.latitude, forKey: "latitude")
//                        UserDefaults.standard.set(loc.coordinate.longitude, forKey: "longitude")
//                    }
//                    Locator.shared.reset()
//                case .failure(_):
//                    break
//                }
//            }
//        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(statusManager), name: .flagsChanged, object: Network.reachability)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    func unauthenticatedBlock(canDismiss: Bool) {
        let controller = AnonymousSignupVC.instantiate(fromAppStoryboard: .main)
        controller.didDismiss = { [weak self] in
            self?.dim(.out, speed: 0)
        }
        controller.canDismiss = canDismiss
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = .overCurrentContext
        controller.providesPresentationContextTransitionStyle = true
        self.dim(.in, color: UIColor.black, alpha: 0.3, speed: 0.5)
        present(controller, animated: true, completion: nil)
    }

    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        if status == .unreachable {
            showAlert(message: "You are offline.")
        }
    }
    
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func hideSpinner() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func goHome() {
        
        kAppDelegate.askForPushNotification()
        
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        controller?.modalPresentationStyle = .overFullScreen
        navigationController?.present(controller!, animated: true, completion: nil)
    }
    
    func spinner(with text: String? = nil,blockInteraction:Bool = false) {
        self.hideSpinner()

        let spinnerActivity = MBProgressHUD.showCustomHud(to: self.view, animated: true)
        if let txt = text {
            spinnerActivity.label.text = txt
        }
        spinnerActivity.isUserInteractionEnabled = blockInteraction
    }
    func spinnerWithProgress(with text: String? = nil,blockInteraction:Bool = false) -> MBProgressHUD {
        let spinnerActivity = MBProgressHUD.showCustomHud(to: self.view, animated: true)
        if let txt = text {
            spinnerActivity.label.text = txt
        }
        spinnerActivity.isUserInteractionEnabled = blockInteraction
        return spinnerActivity
    }
    func spinnerWithProgress(with text: String? = nil, minSize:Bool) -> MBProgressHUD {
        let spinnerActivity = MBProgressHUD.showCustomHud(to: self.view, animated: true,minSize: true)
        if let txt = text {
            spinnerActivity.label.text = txt
        }
        spinnerActivity.isUserInteractionEnabled = true
        return spinnerActivity
    }
    
}

extension BaseVC: UINavigationControllerDelegate {
    func navigationController(_ navigationController: UINavigationController, willShow viewController: UIViewController, animated: Bool) {
        viewController.navigationItem.backBarButtonItem = UIBarButtonItem(title: " ", style: .plain, target: nil, action: nil)
    }
}
