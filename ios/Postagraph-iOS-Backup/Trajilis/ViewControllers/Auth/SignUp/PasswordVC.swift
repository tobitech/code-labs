//
//  PasswordVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 31/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

final class PasswordVC: BaseVC, UITextFieldDelegate {
    
    @IBOutlet var firstIndicatorView: UIView!
    @IBOutlet var secondIndicatorView: UIView!
    @IBOutlet var thirdIndicatorView: UIView!
    @IBOutlet var strengthIndicatorContainerView: UIView!
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var passwordStrenghtLabel: UILabel!
    @IBOutlet var passwordTextField: SkyFloatingLabelTextField!
    @IBOutlet var headerView: HeaderWithLineView!
    var viewModel: SignupViewModel!
    var isPasswordChange: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setRightIcon(imageName: "")
        passwordTextField.addTarget(self, action: #selector(PasswordVC.textFieldChanged(_:)), for: .editingChanged)
        passwordTextField.delegate = self
        passwordTextField.titleFormatter = { $0 }
        passwordTextField.selectedTitle = "Password"
        nextButton.makeCornerRadius(cornerRadius: 5)
                
        viewModel.passwordResetComplete = { [weak self] msg, isSuccess in
            guard let `self` = self else { return }
            self.hideSpinner()
            if let msg = msg {
                self.showAlert(message: msg)
                return
            }
            if isSuccess && msg == nil {
                DispatchQueue.main.async {
                   self.performSegue(withIdentifier: "segueToCongratView", sender: nil)
                }
            }
        }
        
        if isPasswordChange {
            nextButton.setTitle("Change password", for: .normal)
        }else {
            headerView.headerLabel.text = "You’ll need a password"
            nextButton.setTitle("Next", for: .normal)
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        strengthIndicatorContainerView.layer.cornerRadius = strengthIndicatorContainerView.bounds.height/2
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
    
    @IBAction func nextTapped(_ sender: Any) {
        guard let password = passwordTextField.text else{ return }
        if password.count < 8 {
            showAlert(message: Texts.passwordLength)
            return
        }else if password.count >= 65 {
            showAlert(message: Texts.passwordLengthMax)
            return
        }
        
        viewModel.password = password
        if isPasswordChange {
            MBProgressHUD.showCustomHud(to: view, animated: true).label.text = "One moment..."
            viewModel.passwordReset()
        }else {
            let controller = PhoneVC.instantiate(fromAppStoryboard: .auth)
            controller.viewModel = viewModel
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @objc fileprivate func textFieldChanged(_ textField: UITextField) {
        guard let text = textField.text else { return }
        if text.isEmpty {
            //setRightIcon(imageName: "password")
        } else {
            let image = passwordTextField.isSecureTextEntry ? "visibilityOn" : "visibilityOff"
            setRightIcon(imageName: image)
        }
        switch PasswordStrength.checkStrength(password: text) {
        case .none:
            passwordStrenghtLabel.isHidden = true
            firstIndicatorView.backgroundColor = UIColor.appNewPlaceholderColor
            secondIndicatorView.backgroundColor = UIColor.appNewPlaceholderColor
            thirdIndicatorView.backgroundColor = UIColor.appNewPlaceholderColor
        case .weak:
            passwordStrenghtLabel.isHidden = false
            passwordStrenghtLabel.textColor = UIColor.appRed
            passwordStrenghtLabel.text = Texts.weak.capitalized
            firstIndicatorView.backgroundColor = UIColor.appRed
            secondIndicatorView.backgroundColor = UIColor.appNewPlaceholderColor
            thirdIndicatorView.backgroundColor = UIColor.appNewPlaceholderColor
        case .moderate:
            passwordStrenghtLabel.isHidden = false
            passwordStrenghtLabel.textColor = UIColor.moderatePasswordBlue
            passwordStrenghtLabel.text = Texts.normal.capitalized
            firstIndicatorView.backgroundColor = UIColor.moderatePasswordBlue
            secondIndicatorView.backgroundColor = UIColor.moderatePasswordBlue
            thirdIndicatorView.backgroundColor = UIColor.appNewPlaceholderColor
        case .strong:
            passwordStrenghtLabel.isHidden = false
            passwordStrenghtLabel.textColor = UIColor.strongPasswordGreen
            passwordStrenghtLabel.text = Texts.strong.capitalized
            firstIndicatorView.backgroundColor = UIColor.strongPasswordGreen
            secondIndicatorView.backgroundColor = UIColor.strongPasswordGreen
            thirdIndicatorView.backgroundColor = UIColor.strongPasswordGreen
        }
        if text.count > 7 {
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.appRed
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.appRed.withAlphaComponent(0.3)
        }
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.count >= 65 { // string == " " ||
            return false
        }
        return true
    }
}

enum PasswordStrength: Int {
    case none
    case weak
    case moderate
    case strong
    
    static func checkStrength(password: String) -> PasswordStrength {
        let len: Int = password.count
        var strength: Int = 0
        
        switch len {
        case 0:
            return .none
        case 1...8:
            strength += 1
        case 8...12:
            strength += 2
        default:
            strength += 3
        }
        
        // Upper case, Lower case, Number & Symbols
        let patterns = ["^(?=.*[A-Z]).*$", "^(?=.*[a-z]).*$", "^(?=.*[0-9]).*$", "^(?=.*[!@#%&-_=:;\"'<>,`~\\*\\?\\+\\[\\]\\(\\)\\{\\}\\^\\$\\|\\\\\\.\\/]).*$"]
        for pattern in patterns {
            if (password.range(of : pattern, options: .regularExpression) != nil) {
                strength += 1
            }
        }
        switch strength {
        case 0:
            return .none
        case 1...3:
            return .weak
        case 4...6:
            return .moderate
        default:
            return .strong
        }
    }
}
