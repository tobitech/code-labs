//
//  VerifyPhoneVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 01/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

final class VerifyPhoneVC: BaseVC {
    
    @IBOutlet var nextButton: UIButton!
    
    @IBOutlet var subtitleLabel: UILabel!
    @IBOutlet var headerView: HeaderWithLineView!
//    @IBOutlet var progressIndicatorView: UIImageView!
    @IBOutlet var fourthTextField: UITextField!
    @IBOutlet var thirdTextField: UITextField!
    @IBOutlet var secondtextField: UITextField!
    @IBOutlet var firstTextField: UITextField!
    @IBOutlet var textFields: [UITextField]!
    
    @IBOutlet weak var topTextField: UITextField!
    
    var isPasswordReset = false
    var viewModel: SignupViewModel!

//    var autoFillTextField = UITextField()

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        firstTextField.delegate = self
        secondtextField.delegate = self
        thirdTextField.delegate = self
        fourthTextField.delegate = self
        topTextField.delegate = self
        topTextField.text = " "
        [firstTextField, secondtextField, thirdTextField, fourthTextField].forEach({
            $0!.textColor = .black
        })
//        autoFillTextField.addTarget(self, action: #selector(textChange(sender:)), for: .editingChanged)
        viewModel.otpRequestComplete = { message in
            MBProgressHUD.hide(for: self.view, animated: true)
            if let msg = message {
                self.showAlert(message: msg)
            } else {
                self.showAlert(message: "Verification code has been sent to you.")
            }
        }
        viewModel.phoneVerificationComplete = { [weak self] message in
            guard let strongSelf = self else { return }
            MBProgressHUD.hide(for: strongSelf.view, animated: true)
            if let msg = message {
                strongSelf.showAlert(message: msg)
                strongSelf.clear()
            } else {
                strongSelf.nextScreen()
            }
        }

        if #available(iOS 12.0, *) {
            topTextField.textContentType = .oneTimeCode
        }
        topTextField.becomeFirstResponder()
        
        nextButton.makeCornerRadius(cornerRadius: 4)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        for textfield in textFields {
            textfield.layer.cornerRadius = 10
            textfield.layer.masksToBounds = true
        }
    }

    private func clear() {
        for field in textFields {
            field.text = ""
        }
    }
    
    func setupUI() {
        if isPasswordReset {
//            progressIndicatorView.isHidden = false
            headerView.headerLabel.text = "We sent you a code to verify your number"
//            headerView.headerFontSize = 34
            subtitleLabel.text = "Sent to \(viewModel.phone)"
        }else{
//            progressIndicatorView.isHidden = false
            headerView.headerLabel.text = "We sent you a code to verify your number"
//            headerView.headerFontSize = 34
            subtitleLabel.text = "Sent to \(viewModel.phone)"
        }
    }
    
    private func nextScreen() {
        if isPasswordReset {
            let controller = PasswordVC.instantiate(fromAppStoryboard: .auth)
            controller.viewModel = viewModel
            controller.isPasswordChange = true
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let controller = UserNameVC.instantiate(fromAppStoryboard: .auth)
            controller.viewModel = viewModel
            navigationController?.pushViewController(controller, animated: true)
        }
    }
    
    @IBAction func resendTapped(_ sender: Any) {
        spinner(with: "Sending OTP...")
        viewModel.requestOTP()
        clear()
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func nextTapped(_ sender: Any) {
        guard let firstDigit = firstTextField.text,
            let secondDigit = secondtextField.text,
            let thirdDigit = thirdTextField.text,
            let fourthDigit = fourthTextField.text
            else {
                return
        }
        if firstDigit.isEmpty || secondDigit.isEmpty || thirdDigit.isEmpty || fourthDigit.isEmpty {
            return
        }
        if firstDigit.count > 1 || secondDigit.count > 1 || thirdDigit.count > 1 || fourthDigit.count > 1 {
            return
        }
        let code = firstDigit + secondDigit + thirdDigit + fourthDigit
        spinner(with: "One moment...")
        viewModel.verifyPhone(code: code)
    }
}

extension VerifyPhoneVC: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        guard CharacterSet(charactersIn: "0123456789").isSuperset(of: CharacterSet(charactersIn: string)) else {
            return false
        }
        
        let textFields: [UITextField] = [firstTextField, secondtextField, thirdTextField, fourthTextField]
        var codeNow: String = textFields.reduce("", {
            return $0 + $1.text!
        })
        if string == "" {
            codeNow = String(codeNow.dropLast())
        }else if string.count > 1 {
            codeNow = string
        }else {
            codeNow = codeNow + string
        }
        
        textFields.enumerated().forEach { (arg) in
            let (offset, txt) = arg
            txt.text = Array(codeNow).item(at: offset).map({String($0)})
        }
        
        textFieldDidEndEditing(textField)
        
        return false
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        if !firstTextField.text!.isEmpty && !secondtextField.text!.isEmpty && !thirdTextField.text!.isEmpty && !fourthTextField.text!.isEmpty {
            self.view.endEditing(true)
            nextButton.isEnabled = true
            nextButton.backgroundColor = UIColor.appRed
        } else {
            nextButton.isEnabled = false
            nextButton.backgroundColor = UIColor.appRed.withAlphaComponent(0.3)
        }
    }
}
