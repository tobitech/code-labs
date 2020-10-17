//
//  SignInVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import Flurry_iOS_SDK

final class SignInVC: BaseVC {
    @IBOutlet var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet var loginBtn: UIButton!
    @IBOutlet var passwordTextField: SkyFloatingLabelTextField!
    
    let viewModel = SigninViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loginBtn.makeCornerRadius(cornerRadius: 4)
        emailTextField.titleFormatter = {$0}
        passwordTextField.titleFormatter = {$0}
        emailTextField.selectedTitle = "Email"
        passwordTextField.selectedTitle = "Password"
        
        viewModel.signinComplete = {[weak self] msg, user in
            guard let `self` = self else { return }
            self.hideSpinner()
            if let msg = msg {
                self.showAlert(message: msg)
                return
            }
            
            if let _ = user {
                self.goHome()
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
    }
    
    func setRightIcon(imageName: String) {
        let containerV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 20))
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 4, width: 26, height: 26))
        let image = UIImage(named: imageName)
        button.contentMode = .bottom
        button.setImage(image, for: .normal)
        button.addTarget(self, action: #selector(hideOrShow), for: .touchUpInside)
        containerV.addSubview(button)
        passwordTextField.rightView = containerV
        passwordTextField.rightViewMode = .always
    }
    
    @objc func hideOrShow() {
        if passwordTextField.text!.isEmpty { return }
        passwordTextField.isSecureTextEntry = !passwordTextField.isSecureTextEntry
        let image = passwordTextField.isSecureTextEntry ? "visibilityOn" : "visibilityOff"
        setRightIcon(imageName: image)
    }
    @IBAction func btnBackTapped(_ sender: Any) {
        self.navigationController?.popViewController(animated: true)
    }
    @IBAction func textFieldDidChange(_ sender: UITextField) {
        if sender == passwordTextField {
            if passwordTextField.text!.isEmpty {
                setRightIcon(imageName: "password")
            } else {
                let image = passwordTextField.isSecureTextEntry ? "visibilityOn" : "visibilityOff"
                setRightIcon(imageName: image)
            }
        }
        
        if !emailTextField.text!.isEmpty && !passwordTextField.text!.isEmpty {
            loginBtn.isEnabled = true
            loginBtn.backgroundColor = UIColor.appRed.withAlphaComponent(1.0)
        } else {
            loginBtn.isEnabled = false
            loginBtn.backgroundColor = UIColor.appRed.withAlphaComponent(0.3)
        }
    }
    
    @IBAction func forgotPassword(_ sender: Any) {
        let vModel = SignupViewModel()
        let controller = PhoneVC.instantiate(fromAppStoryboard: .auth)
        controller.isPasswordReset = true
        controller.viewModel = vModel
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func signupTapped(_ sender: Any) {
        guard let controllers = navigationController?.viewControllers else { return }
        for controller in controllers {
            if controller.isKind(of: EmailAndNameVC.self) {
                self.navigationController?.popToViewController(controller, animated: true)
                return
            }
        }
        let controller = EmailAndNameVC.instantiate(fromAppStoryboard: .auth)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func loginTapped(_ sender: Any) {
        
        guard let email = emailTextField.text,
        let password = passwordTextField.text else {
            return
        }
        
        if !email.isValidEmail {
            showAlert(message: Texts.emptyEmail)
            return
        }
        
        if password.isEmpty {
            showAlert(message: "Please enter your password")
            return
        }
        self.view.endEditing(true)
        self.spinner(with: "One moment", blockInteraction: true)
        viewModel.signin(email: email, password: password)
    }
}
