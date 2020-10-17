//
//  ResetPasswordVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

final class ResetPasswordVC: BaseVC {
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var confirmPasswordTextField: SkyFloatingLabelTextField!
    @IBOutlet var newPasswordTextField: SkyFloatingLabelTextField!
    
    var viewModel: SignupViewModel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        newPasswordTextField.tag = 1
        confirmPasswordTextField.tag = 2
        newPasswordTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        confirmPasswordTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        setRightIcon(imageName: "password", textField: newPasswordTextField)
        setRightIcon(imageName: "password", textField: confirmPasswordTextField)
    }
    
    func setRightIcon(imageName: String, textField: SkyFloatingLabelTextField) {
        let containerV = UIView.init(frame: CGRect.init(x: 0, y: 0, width: 30, height: 20))
        let button = UIButton.init(frame: CGRect.init(x: 0, y: 4, width: 26, height: 26))
        let image = UIImage(named: imageName)
        button.contentMode = .bottom
        button.setImage(image, for: .normal)
        button.tag = textField.tag
        button.addTarget(self, action: #selector(hideOrShow), for: .touchUpInside)
        containerV.addSubview(button)
        textField.rightView = containerV
        textField.rightViewMode = .always
    }
    
    @objc func hideOrShow(sender: UIButton) {
        if sender.tag == 1 {
            if newPasswordTextField.text!.isEmpty { return }
            newPasswordTextField.isSecureTextEntry = !newPasswordTextField.isSecureTextEntry
            let image = newPasswordTextField.isSecureTextEntry ? "visibilityOn" : "visibilityOff"
            setRightIcon(imageName: image, textField: newPasswordTextField)
        } else {
            if confirmPasswordTextField.text!.isEmpty { return }
            confirmPasswordTextField.isSecureTextEntry = !confirmPasswordTextField.isSecureTextEntry
            let image = confirmPasswordTextField.isSecureTextEntry ? "visibilityOn" : "visibilityOff"
            setRightIcon(imageName: image, textField: confirmPasswordTextField)
        }
        
    }
    
    @objc fileprivate func textFieldChanged(_ textField: SkyFloatingLabelTextField) {
        guard let text = textField.text else { return }
        if text.isEmpty {
            setRightIcon(imageName: "password", textField: textField)
        } else {
            let image = textField.isSecureTextEntry ? "visibilityOn" : "visibilityOff"
            setRightIcon(imageName: image, textField: textField)
        }

        if newPasswordTextField.text!.count > 7 && confirmPasswordTextField.text!.count > 7 {
            nextButton.isEnabled = true
            nextButton.setImage(UIImage.init(named: "enabledButton"), for: .normal)
        } else {
            nextButton.isEnabled = false
            nextButton.setImage(UIImage.init(named: "disabledButton"), for: .normal)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        guard let newPass = newPasswordTextField.text,
        let confirmPass = confirmPasswordTextField.text else { return }
        if newPass != confirmPass {
            showAlert(message: "Password doesn't match.")
            return
        }
        let param = [
            "password": newPass,
            "phone": viewModel.phone,
            "phone_verified": "true",
            "tele_code": viewModel.country!.dialCode
        ]
        
        MBProgressHUD.showCustomHud(to: view, animated: true).label.text = "One moment..."
        APIController.makeRequest(request: .resetPassword(param: param)) { [weak self](response) in
            guard let self  = self else { return }
            self.hideSpinner()
            switch response {
            case .failure(_):
                self.showAlert(message: kDefaultError)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else {
                        self.showAlert(message: kDefaultError)
                        return
                }
                if let status = meta["status"] as? String, status == "200" {
                    if let message = meta["message"] as? String, message == "failed" {
                        self.showAlert(message: kDefaultError)
                    } else {
                        self.performSegue(withIdentifier: "segueToCongratView", sender: nil)
                    }
                }
            }
        }
    }
    
}
