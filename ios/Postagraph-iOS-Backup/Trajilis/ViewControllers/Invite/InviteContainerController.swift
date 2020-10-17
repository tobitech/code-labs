//
//  InviteContainerController.swift
//  Trajilis
//
//  Created by Moses on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class InviteContainerController: UIViewController {

    @IBOutlet weak var inviteByEmail: UIView!
    @IBOutlet weak var inviteByPhone: UIView!
    
    @IBOutlet weak var phoneButton: UIButton!
    @IBOutlet weak var emailButton: UIButton!
    @IBOutlet weak var sendButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        valid(isValid: false)
        title = "Invite Your Friends"
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        children.forEach { (child) in
            if let inviteByEmail = child as? InviteByEmailController {
                inviteByEmail.selectionIsValid = valid
            }else if let inviteByPhone = child as? InviteByPhoneController {
                inviteByPhone.selectionIsValid = valid
            }
        }
    }
    
    @IBAction fileprivate func send() {
        
        for childViewController in children {
            
            if childViewController is InviteByEmailController && inviteByEmail.isHidden == false {
                let byEmail = childViewController as! InviteByEmailController
                byEmail.send()
            }
            else if childViewController is InviteByPhoneController && inviteByPhone.isHidden == false {
                let byPhone = childViewController as! InviteByPhoneController
                byPhone.send()
            }
        }
    }
    
    @IBAction func selected(_ sender: UIButton) {
        switch sender.tag{
        case 0:
            inviteByEmail.isHidden = false
            inviteByPhone.isHidden = true
            
            emailButton.tintColor = UIColor(hexString: "#D63D41")
            phoneButton.tintColor = UIColor(hexString: "#3F3F3F", alpha: 0.5)
        default:
            inviteByEmail.isHidden = true
            inviteByPhone.isHidden = false
            
            phoneButton.tintColor = UIColor(hexString: "#D63D41")
            emailButton.tintColor = UIColor(hexString: "#3F3F3F", alpha: 0.5)
        }
        children.forEach { (child) in
            if let inviteByEmailViewController = child as? InviteByEmailController, !inviteByEmail.isHidden {
                self.valid(isValid: inviteByEmailViewController.validate())
            }else if let inviteByPhoneController = child as? InviteByPhoneController, !inviteByPhone.isHidden {
                self.valid(isValid: inviteByPhoneController.validate())
            }
        }
    }
    
    @IBAction fileprivate func back() {
        self.navigationController?.popViewController(animated: true)
    }
    
    private func valid(isValid: Bool) {
        sendButton.isEnabled = isValid
        sendButton.alpha = isValid ? 1 : 0.6
    }
}
