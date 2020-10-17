//
//  PhoneVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 01/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import PhoneNumberKit

final class PhoneVC: BaseVC, UITextFieldDelegate {
    
//    @IBOutlet var progressIndicatorView: UIImageView!
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var countryCodeLbl: UILabel!
    @IBOutlet var headerView: HeaderWithLineView!
    @IBOutlet var sendCodeBtn: UIButton!
    @IBOutlet var countryFlagImageView: UIImageView!
    @IBOutlet var phoneTextField: SkyFloatingLabelTextField!
    @IBOutlet var dropdownButton: UIButton!
    @IBOutlet weak var phoneTextFieldInfo: UILabel!
    
    var viewModel: SignupViewModel!
    var textfield: PhoneNumberTextField = PhoneNumberTextField()
    var isPasswordReset = false
    var isFromSettings = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        phoneTextField.titleFormatter = { $0 }
        phoneTextField.selectedTitle = "Phone number"
        //phoneTextField.setRightIcon(imageName: "phone")
        phoneTextField.lineColor = .clear
        phoneTextField.selectedLineColor = .clear
        phoneTextField.addTarget(self, action: #selector(textFieldChanged(_:)), for: .editingChanged)
        phoneTextField.delegate = self
        viewModel.getCountries()
        viewModel.fetchCountriesCompleted = { message in
            DispatchQueue.main.async {
                MBProgressHUD.hide(for: self.view, animated: true)
                if let msg = message {
                    self.showAlert(message: msg)
                } else {
                    self.updateUI()
                }
            }
        }
        viewModel.didSelectCountry = {
            self.updateUI()
        }
        viewModel.phoneAvailabilityCheckComplete = { message in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let msg = message {
                self.showAlert(message: msg)
            } else {
                self.spinner(with: "Sending OTP...")
                self.viewModel.requestOTP()
            }
        }
        
        viewModel.otpRequestComplete = { message in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let msg = message {
                self.showAlert(message: msg)
            } else {
               self.nextScreen()
            }
        }
        countryFlagImageView.isUserInteractionEnabled = true
        let tap = UITapGestureRecognizer()
        tap.addTarget(self, action: #selector(handleCountryTap))
        countryFlagImageView.addGestureRecognizer(tap)
        sendCodeBtn.makeCornerRadius(cornerRadius: 4)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        countryFlagImageView.layer.shadowRadius = 4.0
        countryFlagImageView.layer.shadowOffset = CGSize(width: 1.0, height: 1.0)
        countryFlagImageView.layer.opacity = 1.0
        countryFlagImageView.layer.shadowColor = UIColor.appRed.cgColor
        countryFlagImageView.layer.masksToBounds = false
        countryFlagImageView.layer.borderColor = UIColor.appRed.cgColor
        countryFlagImageView.layer.borderWidth = 1
        countryFlagImageView.clipsToBounds = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    func setupUI() {
        if isPasswordReset {
//            progressIndicatorView.isHidden = false
            headerView.headerLabel.text = (isFromSettings) ? "Reset Password" : "Forgot Password"
//            headerView.headerFontSize = 24
            subtitleLabel.text = "Enter your registered phone number. We will send you a verification code to reset your password"
            phoneTextFieldInfo.isHidden = true
        } else {
            headerView.headerLabel.text = "What’s your number"
        }
    }
    
    private func nextScreen() {
        let controller = VerifyPhoneVC.instantiate(fromAppStoryboard: .auth)
        controller.viewModel = viewModel
        controller.isPasswordReset = isPasswordReset
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func updateUI() {
        textfield.defaultRegion = viewModel.country!.sortName
        countryCodeLbl.text = viewModel.country!.dialCode
        if let url = self.viewModel.countryFlag {
            self.countryFlagImageView.sd_setImage(with: url, completed: nil)
        }
    }
    
    @objc fileprivate func handleCountryTap() {
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.didSelectCountry = { [weak self] country in
            self?.textfield.defaultRegion = country.sortName
            self?.viewModel.country = country
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func dropTapped(_ sender: Any) {
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        
        
        guard let text = phoneTextField.text, !text.isEmpty else {
            self.showAlert(message: "Please enter a valid phone number")
            return
        }

        viewModel.phone = text.replacingOccurrences(of: " ", with: "")
        print(kAppDelegate.user?.phone)
//        let result = string.trimmingCharacters(in: CharacterSet(charactersIn: "0123456789.") 2025286343
        if isFromSettings && (viewModel.phone.filter("0123456789".contains) != kAppDelegate.user?.phone || viewModel.country?.dialCode != kAppDelegate.user?.dialCode) {
            self.showAlert(message: "Please enter phone number that was used to register this account.")
            return
        }
        
        spinner(with: "One moment...")
        if isPasswordReset {
            viewModel.requestOTP()
        } else {
            viewModel.checkPhoneAvailability()
        }
        
    }
    
    private func format(phone: String) {
        textfield.text = phone
        nextButtonChangeState(enable: textfield.isValidNumber)
        phoneTextField.text = textfield.text
    }
    
    @objc func textFieldChanged(_ sender: UITextField) {
        if let text = sender.text {
            format(phone: text)
        }
        
    }
    
    private func nextButtonChangeState(enable: Bool) {
        sendCodeBtn.isEnabled = enable
        let backgroundColour = enable ? UIColor.appRed : UIColor.appRed.withAlphaComponent(0.3)
        sendCodeBtn.backgroundColor = backgroundColour
    }

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        guard let text = textField.text else { return true }
        
        let newLength = text.count + string.count - range.length
        if string == "*"  || string == "#" || newLength > 15 {
            return false
        }
        return true
    }
}
