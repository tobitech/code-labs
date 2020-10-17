//
//  PGFareRuleAcknowledgeViewController.swift
//  Trajilis
//
//  Created by bharats802 on 29/05/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PGFareRuleAcknowledgeViewController: BaseVC {

    @IBOutlet weak var btnContinue:UIButton!
    @IBOutlet weak var switchAck:UISwitch!
    
    var fareRules = [PGFareRule]()
    var paymentVC: PaymentVC?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.btnContinue.backgroundColor = .appRed
        self.btnContinue.layer.cornerRadius = 4.0
        self.btnContinue.layer.masksToBounds = true
    }
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.showNavigationBar()
    }
    
    @IBAction func btnTermsNConditionTapped(sender:UIButton) {
        if let url = Bundle.main.url(forResource: "tcondition", withExtension: "pdf") {
            goToWebVC(with: url, title: "Terms & Condition")
        }
    }
    
    private func goToWebVC(with url: URL, title: String) {
        let vc = OnboardingWebVC.instantiate(fromAppStoryboard: .onboarding)
        vc.url = url
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func fullFareRulesTapped(_ sender: UIButton) {
        // do something here...
    }
    /*
    @IBAction func btnFullFareTapped(sender:UIButton) {
        
        guard let pvc = paymentVC else {
            return
        }
        
        var rules: Set<String> = []
        for detail in pvc.outgoing.details {
            if let pen = detail.fareRule?.PEN {
                rules.insert(pen)
            }
        }
        if let incoming = pvc.incoming {
            for detail in incoming.details {
                if let pen = detail.fareRule?.PEN {
                    rules.insert(pen)
                }
            }
        }
        
        let array = Array(rules)
        let string = array.joined(separator: "\n")
        let controller = FareRuleVC.instantiate(fromAppStoryboard: .flight)
        if self.fareRules.count > 0 {
            controller.fareRules = self.fareRules
        } else {
            controller.rules = string
        }
        
        navigationController?.pushViewController(controller, animated: true)
    }
    */
    
    @IBAction func btnContinueTapped(sender:UIButton) {
        guard let paymentVC = self.paymentVC else { return }
        
        if switchAck.isOn {
            navigationController?.pushViewController(paymentVC, animated: true)
        } else {
            self.showAlert(message: "Please agree to terms & conditions to continue booking.")
        }
    }
}
