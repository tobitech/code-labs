//
//  EmailAndNameVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 31/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

final class EmailAndNameVC: BaseVC {
    
    @IBOutlet var firstnameTextField: SkyFloatingLabelTextField!
    @IBOutlet var lastnameTextField: SkyFloatingLabelTextField!
    @IBOutlet var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet var continueButton: UIButton!
    @IBOutlet var backBtn: UIButton!
    var userInfo: [String: Any] = [:]
    
    let viewModel = SignupViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        //Helpers.setupBackButton(button: backBtn)
        
        firstnameTextField.titleFormatter =  {$0}
        firstnameTextField.selectedTitle = "First Name"
        lastnameTextField.titleFormatter =  {$0}
        lastnameTextField.selectedTitle = "Last Name"
        emailTextField.titleFormatter =  {$0}
        emailTextField.selectedTitle = "Email"
        continueButton.isEnabled = false
        continueButton.makeCornerRadius(cornerRadius: 4)
        
        firstnameTextField.delegate = self
        lastnameTextField.delegate = self
        firstnameTextField.addTarget(self, action: #selector(EmailAndNameVC.textFieldChanged(_:)), for: .editingChanged)
        lastnameTextField.addTarget(self, action: #selector(EmailAndNameVC.textFieldChanged(_:)), for: .editingChanged)
        emailTextField.addTarget(self, action: #selector(EmailAndNameVC.textFieldChanged(_:)), for: .editingChanged)
        viewModel.emailVerificationComplete = { message in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let msg = message {
                self.showAlert(message: msg)
            } else {
                let controller = PasswordVC.instantiate(fromAppStoryboard: .auth)
                controller.viewModel = self.viewModel
                self.navigationController?.pushViewController(controller, animated: true)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstnameTextField.text = viewModel.firstname
        lastnameTextField.text = viewModel.lastname
        emailTextField.text = viewModel.email
        showNavigationBar()
    }
    
    @IBAction func loginBtnTapped(_ sender: Any) {
        guard let controllers = navigationController?.viewControllers else { return }
        for controller in controllers {
            if controller.isKind(of: SignInVC.self) {
                self.navigationController?.popToViewController(controller, animated: true)
                return
            }
        }
        let sigInVC = SignInVC.instantiate(fromAppStoryboard: .auth)
        self.navigationController?.pushViewController(sigInVC, animated: true)
    }
    
    @IBAction func backBtnTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        guard let firstname = firstnameTextField.text,
        let lastname = lastnameTextField.text,
            let email = emailTextField.text else { return }
        if firstname.isEmpty {
            showAlert(message: Texts.emptyFirstName)
            return
        }
        if lastname.isEmpty {
            showAlert(message: Texts.emptyLastName)
            return
        }
        if email.isEmpty {
            showAlert(message: Texts.emptyEmail)
            return
        }
        if !email.isValidEmail {
            showAlert(message: Texts.invalidEmail)
            return
        }
        viewModel.email = email
        viewModel.firstname = firstname
        viewModel.lastname = lastname
        let spinnerActivity = MBProgressHUD.showCustomHud(to: view, animated: true)
        spinnerActivity.label.text = Texts.checkEmailAvailability
        spinnerActivity.isUserInteractionEnabled = false
        
        viewModel.verifyEmail()
        
    }
    
    @objc fileprivate func textFieldChanged(_ textField: UITextField) {
        guard let firstname = firstnameTextField.text,
            let lastname = lastnameTextField.text,
            let email = emailTextField.text else { return }
        if !firstname.isEmpty && !lastname.isEmpty && email.isValidEmail {
            continueButton.isEnabled = true
            continueButton.backgroundColor = UIColor.appRed
        } else {
            continueButton.isEnabled = false
            continueButton.backgroundColor = UIColor.appRed.withAlphaComponent(0.3)
        }
    }
    
}

extension SkyFloatingLabelTextField {
    func setRightIcon(imageName: String) {
        let containerV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 20))
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 4, width: 26, height: 26))
        let image = UIImage(named: imageName)
        button.contentMode = .bottom
        button.setImage(image, for: .normal)
        containerV.addSubview(button)
        rightView = containerV
        rightViewMode = .always
    }
}


extension EmailAndNameVC: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if string.rangeOfCharacter(from: .letters) != nil || string == "" {
            return true
        } else {
            return false
        }
    }
}
