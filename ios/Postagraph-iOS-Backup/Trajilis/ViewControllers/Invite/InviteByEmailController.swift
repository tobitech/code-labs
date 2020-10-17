//
//  InviteByEmailController.swift
//  Trajilis
//
//  Created by Moses on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class InviteByEmailController: BaseVC {
    
    let viewModel: IInviteViewModel = InviteViewModel()
    var selectionIsValid: ((Bool)->())?

    @IBOutlet fileprivate weak var email: UITextField! {
        didSet {
            email.delegate = self
        }
    }
    
    @IBOutlet fileprivate weak var message: UITextView! {
        didSet {
            message.delegate = self
            message.textColor = UIColor.lightGray
        }
    }
    
    func validate() -> Bool {
        return hasEmail(text: email.text!)// email.text!.isValidEmail
    }
    
    private func hasEmail(text: String) -> Bool {
        return text.components(separatedBy: ",").first(where: {!$0.trimmingCharacters(in: .whitespacesAndNewlines).isValidEmail}) == nil
    }
    
    func send() {
        
        guard let email = email.text, !email.isEmpty  else {
            showAlert(message: "Please enter your email")
            return
        }

        if !hasEmail(text: email) {
            showAlert(message: "Please enter a valid email")
            return
        }

        guard let message = message.text, !message.isEmpty else {
            showAlert(message: "Please enter your message")
            return
        }
        
        spinner(with: "One moment...", blockInteraction: true)
        Helpers.createDynamicLink(user: kAppDelegate.user!, mode: .invite) { (url) in
            if let url = url {
                var request = JSONDictionary()
                request["email"] = email
                request["message"] = message + "\n" + "Click the link below to download on the app store:\n \(url.absoluteString)"
                
                guard let userId = UserDefaults.standard.value(forKey: USERID) as? String else { return }
                request["user_id"] = userId
                
                self.viewModel.invite(by: .inviteFriendsByEmail(param: request)) { (stateModel) in
                    switch stateModel.state {
                    case .loading: break
                    default:
                        self.hideSpinner()
                    }
                    
                    switch stateModel.state {
                    case .loading: break
                    case .error(let errorMessage):
                        self.showAlert(message: errorMessage)
                    case .noData(let message):
                        self.showAlert(message: message)
                    default:
                        break
                    }
                }
            }else {
                self.hideSpinner()
            }
        }
    }
}

extension InviteByEmailController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let oldText = textField.text! as NSString
        let newText = oldText.replacingCharacters(in: range, with: string)
        if !newText.isEmpty {
            for scalar in newText.unicodeScalars {
                if !scalar.isASCII {
                    return false
                }
            }
        }
        selectionIsValid?(hasEmail(text: newText))
        return true
    }
}

extension InviteByEmailController : UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Enter Message Here" {
            textView.text = ""
            textView.textColor = UIColor.black
        }
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        if textView.text.isEmpty {
            textView.text = "Enter Message Here"
            textView.textColor = UIColor.lightGray
        }
    }
}

