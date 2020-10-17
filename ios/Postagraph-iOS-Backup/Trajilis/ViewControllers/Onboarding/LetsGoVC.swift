//
//  LetsGoVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 30/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class LetsGoVC: UIViewController {

    @IBOutlet var trajilisLabel: UILabel!
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        trajilisLabel.layer.cornerRadius = trajilisLabel.bounds.height/2
        trajilisLabel.clipsToBounds = true
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)

    }
    
    @IBAction func privacyPolicyTapped(_ sender: Any) {
        if let url = Bundle.main.url(forResource: "ppolicy", withExtension: "pdf") {
            goToWebVC(with: url, title: "Privacy Policy")
        }
        
    }
    
    @IBAction func termsAndConditionTapped(_ sender: Any) {
        if let url = Bundle.main.url(forResource: "tcondition", withExtension: "pdf") {
            goToWebVC(with: url, title: "Terms & Condition")
        }
    }

    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func letsGoTapped(_ sender: Any) {
        let vc = EmailAndNameVC.instantiate(fromAppStoryboard: .auth)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    private func goToWebVC(with url: URL, title: String) {
        let vc = OnboardingWebVC.instantiate(fromAppStoryboard: .onboarding)
        vc.url = url
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
}
