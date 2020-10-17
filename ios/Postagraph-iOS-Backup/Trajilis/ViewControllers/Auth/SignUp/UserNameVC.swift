//
//  UserNameVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 02/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

final class UserNameVC: BaseVC, UITextFieldDelegate {
    var viewModel: SignupViewModel!
    
    @IBOutlet var usernametextField: SkyFloatingLabelTextField!
    @IBOutlet var nextButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        usernametextField.delegate = self
        usernametextField.titleFormatter = { $0 }
        usernametextField.selectedTitle = "Set your username"
        
        nextButton.makeCornerRadius(cornerRadius: 4)
        
        viewModel.signupComplete = { message in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let msg = message {
                self.showAlert(message: msg)
            } else {
                let controller = CompleteProfileVC.instantiate(fromAppStoryboard: .auth)
                controller.countryId = self.viewModel.country!.id
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
        
        viewModel.usernameVerificationComplete = { message in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let msg = message {
                self.showAlert(message: msg)
            } else {
                self.spinner(with: "Signing up...")
                self.viewModel.signup()
            }
        }
        
       
    }
    
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if  sender.text!.isEmpty {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.appRed.withAlphaComponent(0.3)
        } else {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.appRed.withAlphaComponent(1.0)
        }
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        guard var username = usernametextField.text else { return }
        username = username.trimmingCharacters(in: .whitespacesAndNewlines)
        if username.isEmpty {
            showAlert(message: Texts.enterUsername)
            return
        }
        viewModel.username = username
        spinner(with: "One moment...")
        viewModel.checkUsername()
        
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentString: NSString = (textField.text ?? "") as NSString
        let newString = currentString.replacingCharacters(in: range, with: string)
        if string.last == " " {
            return false
        } else {
             return ((textField.text!.count <= 50) || newString.removeWhiteSpace() )
        }
    }
}
