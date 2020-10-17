//
//  SettingViewController.swift
//  Trajilis
//
//  Created by Moses on 29/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField
import MobileCoreServices
import AVKit
import SDWebImage

class SettingViewController: BaseVC {
    
    private var defaultPhoneCountry : Country?
    
    @IBOutlet var scrollView : UIScrollView!
    
    @IBOutlet var basicStack: UIStackView!
    @IBOutlet var firstname : SkyFloatingLabelTextField!
    @IBOutlet var lastname : SkyFloatingLabelTextField!
    @IBOutlet var username : SkyFloatingLabelTextField!
    @IBOutlet var dob : SkyFloatingLabelTextField! {
        didSet {
            dob.loadDatePicker()
        }
    }
//    @IBOutlet var status : SkyFloatingLabelTextField!
    
    @IBOutlet weak var statusLineView: UIView!
    @IBOutlet weak var statusPlaceHolder: UILabel!
    @IBOutlet var status: UITextView!
    @IBOutlet weak var statusHeightConstraint: NSLayoutConstraint!
    
    @IBOutlet var contactStack: UIStackView!
    @IBOutlet var phoneTextField: SkyFloatingLabelTextField! {
        didSet {
            phoneTextField.setRightIcon(imageName: "phone")
        }
    }
    @IBOutlet var email : SkyFloatingLabelTextField!
    @IBOutlet var cityButton : UIButton!{
        didSet {
            cityButton.addTarget(self, action: #selector(cityEvent), for: .touchUpInside)
        }
    }
    @IBOutlet var city : SkyFloatingLabelTextField!
    @IBOutlet var stateButton : UIButton! {
        didSet {
            stateButton.addTarget(self, action: #selector(stateEvent), for: .touchUpInside)
        }
    }
    @IBOutlet var state : SkyFloatingLabelTextField!
    @IBOutlet var countryTxtButton : UIButton! {
        didSet {
            countryTxtButton.addTarget(self, action: #selector(countryTxtEvent), for: .touchUpInside)
        }
    }
    @IBOutlet weak var countryTxt : SkyFloatingLabelTextField!
    
    
    private var defaultCurrency: Currency?
    private var defaultCountry: Country?
    private var defaultState: State?
    private var isEdited = false
    private var profileImage: UIImage?
    private var profileVideoCoverImage: UIImage?
    private var profileVideo: URL?
    
    init() {
        super.init(nibName: "SettingViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureTextFields()
        updateFieldUIs()
        refreshUser()
        
        status.delegate = self
    }
    
    private func configureTextFields() {
        firstname.titleFormatter = { $0 }
        lastname.titleFormatter = { $0 }
        username.titleFormatter = { $0 }
        dob.titleFormatter = { $0 }
        phoneTextField.titleFormatter = { $0 }
        email.titleFormatter = { $0 }
        city.titleFormatter = { $0 }
        state.titleFormatter = { $0 }
        countryTxt.titleFormatter = { $0 }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Edit Profile"
        showNavigationBar()
    }
    
    func isValidData() -> Bool {
        
        guard let fname =  firstname.text, !fname.isEmpty else {
            self.showAlert(message: "Please enter a valid first name.")
            return false
        }
        guard let lname =  lastname.text, !lname.isEmpty else {
            self.showAlert(message: "Please enter a valid last name.")
            return false
        }
        
        guard !username.text!.isEmpty else {
            self.showAlert(message: "Please enter a valid username.")
            return false
        }
        
        return true
        
    }
    
    @objc private func countryEvent() {
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.didSelectCountry = { [weak self] country in
            self?.defaultPhoneCountry = country
            if let url = country.countryFlag {
//                self?.countryImgView.sd_setImage(with: url, completed: nil)
            }
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func cityEvent() {
        guard let countryId = defaultCountry?.id else { return }
        guard let stateId = defaultState?.id else { return }
        
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.countryId = countryId
        controller.stateId = stateId
        controller.type = .city
        controller.didSelectCity = { [weak self] city in
            self?.city.text = city.name
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func stateEvent() {
        guard let countryId = defaultCountry?.id else { return }
        
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.countryId = countryId
        controller.type = .state
        controller.didSelectState = { [weak self] state in
            self?.city.text = ""
            self?.state.text = state.name
            self?.defaultState = state
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc private func countryTxtEvent() {
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.type = .country
        controller.didSelectCountry = { [weak self] country in
            self?.city.text = ""
            self?.state.text = ""
            self?.defaultCountry = country
            self?.countryTxt.text = country.name
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func saveChanges(_ sender: Any) {
        if let user = (UIApplication.shared.delegate as? AppDelegate)?.user {
            updateAccount(user: user)
        }
    }

}


extension SettingViewController {
    func refreshUser() {
        Helpers.getCurrentUser { (success) in
            self.updateFieldUIs()
        }
    }
    private func updateFieldUIs() {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else {
            return
        }
        //self.scrollView.setContentOffset(CGPoint.zero, animated: false)
        var ph_country = JSONDictionary()
        ph_country["country_id"] = user.countryId
        ph_country["country_name"] = user.country
        ph_country["currency"] = user.currencyCountry
        ph_country["currency_symbol"] = user.currencySymbol
        //ph_country["sort_name"] = user.
        ph_country["tele_country_code"] = user.dialCode
        
        defaultPhoneCountry = Country.init(json: ph_country)
        defaultCountry = Country.init(json: ph_country)
        
        var currency = JSONDictionary()
        currency["country_id"] = user.countryId
        currency["country_name"] = user.country
        currency["currency"] = user.currency
        currency["currency_symbol"] = user.currencySymbol
        //currency["sort_name"] = user.
        currency["tele_country_code"] = user.dialCode
        
        defaultCurrency = Currency.init(currency)
        
        firstname.text = user.firstname
        lastname.text = user.lastname
        username.text = user.username
        dob.text = user.dob
        status.text = user.status
        phoneTextField.text = user.phone
        email.text = user.email
        city.text = user.city
        state.text = user.state
        countryTxt.text = user.country
        textViewDidChange(status)
    }
    
    

    private func updateAccount(user: User) {
        guard let userId = UserDefaults.standard.value(forKey: USERID) as? String else { return }

        var request = JSONDictionary()
        request["city"] = city.text
        request["state"] = state.text
        request["country"] = countryTxt.text
        request["country_id"] = defaultCountry?.id
        request["currency"] = defaultCurrency?.currency ?? ""
        request["currency_country"] = user.currencyCountry
        request["currency_symbol"] = user.currencySymbol
        request["distance_unit"] = user.distance
        request["dob"] = dob.text
        request["email"] = email.text
        request["f_name"] = firstname.text
        request["image_url"] = user.profileImage
        request["profile_video"] = user.profileVideo
        request["profile_video_thumb"] = user.profileVideoThumb
        request["l_name"] = lastname.text
        request["notification_enable"] = user.notificationEnable
        request["phone_number"] = phoneTextField.text
        request["status"] = status.text
        request["tel_country_code"] = defaultPhoneCountry?.dialCode
        request["user_id"] = userId
        request["user_name"] = username.text
        request["work_at"] = user.workAt


        APIController.makeRequest(request: TrajilisAPI.updateUserDetail(param: request)) { [weak self](response) in
            if let self = self {
                // MBProgressHUD.hide(for: self.view, animated: true)
                switch response {
                case .failure(let error):
                    self.showAlert(message: error.desc)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                    if let meta = json?["meta"] as? JSONDictionary, let message = meta["message"] as? String {
                        self.showAlert(message: message)
                        if let crncy = self.defaultCurrency?.currency {
                            CurrencyViewController.saveCurrencyInSettings(crncy: crncy)
                        }
                        Helpers.getCurrentUser(completion: { (success) in
                            
                        })
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }            
        }
    }

    private func signout() {
        APIController.makeRequest(request: .signout) { (_) in }
        UserDefaults.standard.removeObject(forKey: USERID)
        let dic = UserDefaults.standard.dictionaryRepresentation()
        for key in dic.keys {
            if(key != "is_dev_env") {
                UserDefaults.standard.removeObject(forKey: key)
            }
        }
        UserDefaults.standard.synchronize()
        try? DataStorage.shared.dataStorage.removeAll()
        (UIApplication.shared.delegate as? AppDelegate)?.user = nil
        let controller = UIStoryboard(name: "Initial", bundle: nil).instantiateInitialViewController()
        UIApplication.shared.keyWindow?.rootViewController = controller
    }

    func deleteAccount() {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else {
            return
        }

        MBProgressHUD.showCustomHud(to: self.view, animated: true).label.text = "One moment..."

        APIController.makeRequest(request: TrajilisAPI.deleteUserAccount(userId: user.id)) { (response) in
            MBProgressHUD.hide(for: self.view, animated: true)

            switch response {
            case .failure(let error):
                self.showAlert(message: error.desc)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                if let meta = json?["meta"] as? JSONDictionary, let status = meta["status"] as? String, status == "200" {
                    self.signout()
                } else if let meta = json?["meta"] as? JSONDictionary, let message = meta["message"] as? String {
                    self.showAlert(message: message)
                }
            }
        }
    }
    
    @IBAction private func deleteAccountEvent () {
        let alertController = UIAlertController.init(title: nil, message: "Are you sure you want to delete your account?", preferredStyle: .alert)
        let yesAction = UIAlertAction.init(title: "Yes", style: .default) { (_) in
            self.deleteAccount()
        }
        let cancel = UIAlertAction.init(title: "Cancel", style: .default, handler: nil)
        alertController.addAction(yesAction)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)

    }
    
}


extension SettingViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        if string.rangeOfCharacter(from: .letters) != nil || string == ""{
            return true
        } else {
            return false
        }
    }
}

extension SettingViewController: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        statusLineView.backgroundColor = UIColor(hexString: "#38344D")
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        statusLineView.backgroundColor = UIColor(hexString: "#38344D", alpha: 0.8)
    }
    
    func textViewDidChange(_ textView: UITextView) {
        statusPlaceHolder.isHidden = !textView.text.isEmpty
        
        let textHeight = (textView.text as NSString).boundingRect(with: CGSize(width: textView.frame.width, height: 150), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: textView.font!], context: nil).height
        let height = max(min(textHeight, 100), 40)
        statusHeightConstraint.constant = height
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
           textView.contentOffset.y = textView.contentSize.height - height
        }
    }
    
}
