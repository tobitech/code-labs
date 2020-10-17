//
//  AnonymousSignupVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/03/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class AnonymousSignupVC: UIViewController {

    @IBOutlet var cardView: UIView!
    @IBOutlet var notNowButton: UIButton!

    var canDismiss = false

    var didDismiss: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        if !canDismiss {
            notNowButton.isHidden = true
        }
        cardView.set(cornerRadius: 8)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didDismiss?()
    }

    @IBAction func notNowTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func signupTapped(_ sender: Any) {
        guard let controller = UIStoryboard(name: "Initial", bundle: nil).instantiateInitialViewController() as? UINavigationController else {return}
        let splashVC = SplashVC.instantiate(fromAppStoryboard: .onboarding)
        let emailAndNameVC = EmailAndNameVC.instantiate(fromAppStoryboard: .auth)
        controller.viewControllers.append(contentsOf: [splashVC, emailAndNameVC])
        UIApplication.shared.keyWindow?.rootViewController = controller
    }
    
    @IBAction func singinTapped() {
        guard let controller = UIStoryboard(name: "Initial", bundle: nil).instantiateInitialViewController() as? UINavigationController else {return}
        let splashVC = SplashVC.instantiate(fromAppStoryboard: .onboarding)
        let signInVC = SignInVC.instantiate(fromAppStoryboard: .auth)
        controller.viewControllers.append(contentsOf: [splashVC, signInVC])
        UIApplication.shared.keyWindow?.rootViewController = controller
    }
    
}
