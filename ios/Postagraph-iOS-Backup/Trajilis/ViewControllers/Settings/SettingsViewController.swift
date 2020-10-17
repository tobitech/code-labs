//
//  SettingsViewController.swift
//  Trajilis
//
//  Created by user on 16/08/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import MessageUI

class SettingsViewController: BaseVC {
    
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var pushNotifSwift: UISwitch!
    @IBOutlet weak var distantUnitLbl : UILabel!
    @IBOutlet weak var currencyLbl: UILabel!
    @IBOutlet weak var currencyBtn: UIButton! {
        didSet {
            currencyBtn.addTarget(self, action: #selector(currencyEvent), for: .touchUpInside)
        }
    }
    @IBOutlet weak var shareFeedBackButton: UIButton!{
        didSet {
            shareFeedBackButton.addTarget(self, action: #selector(handleShareFeedBack), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var blockedUsersBtn: UIButton! {
        didSet {
            blockedUsersBtn.addTarget(self, action: #selector(blockedUsersEvent), for: .touchUpInside)
        }
    }
    @IBOutlet weak var distantUnitBtn: UIButton! {
        didSet {
            distantUnitBtn.addTarget(self, action: #selector(distanceUnitEvent), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var resetPasswordBtn: UIButton! {
        didSet {
            resetPasswordBtn.addTarget(self, action: #selector(handleResetPassword), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var privacyPolicyBtn: UIButton! {
        didSet {
            privacyPolicyBtn.addTarget(self, action: #selector(handlePrivacyPolicy), for: .touchUpInside)
        }
    }
    
    @IBOutlet weak var termsAndConditionBtn: UIButton! {
        didSet {
            termsAndConditionBtn.addTarget(self, action: #selector(handleTermsAndCondition), for: .touchUpInside)
        }
    }
    @IBOutlet weak var logoutBtn: UIButton! {
        didSet {
            logoutBtn.addTarget(self, action: #selector(handleLogout), for: .touchUpInside)
        }
    }
    @IBOutlet weak var deactivateButton: UIButton! {
        didSet {
            deactivateButton.addTarget(self, action: #selector(deactivateAccount), for: .touchUpInside)
        }
    }
    @IBOutlet weak var deleteButton: UIButton! {
        didSet {
            deleteButton.addTarget(self, action: #selector(deleteAccount), for: .touchUpInside)
        }
    }
    
    fileprivate var viewModel: SignupViewModel!
    fileprivate var defaultCurrency: Currency?
    private var defaultDistance: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        scrollView.delegate = self
        updateFieldUIs()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = "Settings"
        showNavigationBar()
        navigationController?.navigationBar.barTintColor = UIColor.white
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        title = ""
    }
    
    @objc fileprivate func handleLogout() {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: Helpers.actionSheetStyle())
        //        alertController.view.tintColor = UIColor.black
        
        let logout = UIAlertAction(title: "Logout", style: .destructive) { (action:UIAlertAction) in
            self.spinner(with: "Logging out...", blockInteraction: true)
            APIController.makeRequest(request: .signout) { response in
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
                    if let status = meta["status"] as? String, status == "200",
                        let message = meta["message"] as? String, message == "Successful" {
                        self.logoutCleanup()
                    } else {
                        self.showAlert(message: kDefaultError)
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        
        alertController.addAction(logout)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    private func logoutCleanup() {
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
    
    @objc fileprivate func handlePrivacyPolicy() {
        if let url = Bundle.main.url(forResource: "ppolicy", withExtension: "pdf") {
            goToWebVC(with: url, title: "Privacy Policy")
        }
    }
    
    @objc private func handleShareFeedBack() {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients(["hello@postagraph.com"])
        controller.setSubject("User Feedback")
        controller.setMessageBody("", isHTML: false)
        
        if MFMailComposeViewController.canSendMail(){
            self.present(controller, animated: true, completion: nil)
        }else{
            print("Can't send email")
        }
    }
    
    @objc fileprivate func handleTermsAndCondition() {
        if let url = Bundle.main.url(forResource: "tcondition", withExtension: "pdf") {
            goToWebVC(with: url, title: "Terms & Condition")
        }
    }
    
    @objc fileprivate func handleResetPassword() {
        let vModel = SignupViewModel()
        let controller = PhoneVC.instantiate(fromAppStoryboard: .auth)
        controller.isPasswordReset = true
        controller.isFromSettings = true
        controller.viewModel = vModel
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc fileprivate func currencyEvent() {
        let controller = CurrencyViewController()
        controller.selectedHandle = { currency in
            self.defaultCurrency = currency
            if let selectedCurrency = currency?.currency {
                self.setCurrency(currency: selectedCurrency)
            }
             self.updateAccount()
        }
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func setCurrency(currency: String) {
        let boldFont = UIFont(name: "PTSans-Bold", size: 15)!
        let regularFont = UIFont(name: "PTSans-Regular", size: 15)!
        let attribute = NSMutableAttributedString(string: "Currency ", attributes: [.font: regularFont, .foregroundColor: UIColor.black])
        attribute.append(NSAttributedString(string: currency, attributes: [.font: boldFont, .foregroundColor: UIColor.black]))
        self.currencyLbl.attributedText = attribute
    }
    
    @objc fileprivate func blockedUsersEvent() {
        let controller = BlockViewController()
        controller.count = { count in
            //self.blockedUsersCount.text = "\(count)"
        }
        //self.updateUser()
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @objc fileprivate func distanceUnitEvent() {
        let controller = DistanceUinitViewController()
        controller.selected = {
            self.defaultDistance = $0
            self.setDistance(distance: $0)
            self.updateAccount()
        }
        if let text = distantUnitLbl.text, !text.isEmpty {
            controller.unit = text.lowercased().contains("mile") ? DistantUnit.miles : DistantUnit.kilometers
        }
        controller.modalTransitionStyle = .crossDissolve
        controller.modalPresentationStyle = .overFullScreen
        present(controller, animated: true, completion: nil)
    }
    
    @objc fileprivate func deactivateAccount() {
        let alertController = UIAlertController(title: "Deactivate Account?", message: "Are you sure you want to deactivate your account? You can login into the app and reactivate whenever you want.", preferredStyle: Helpers.actionSheetStyle())
        //        alertController.view.tintColor = UIColor.black
        
        let deactivate = UIAlertAction(title: "Deactivate", style: .destructive) { (action:UIAlertAction) in
            self.deactivate()
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        
        alertController.addAction(deactivate)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    private func deactivate() {
        self.spinner(with: "Deactivating...", blockInteraction: true)
        APIController.makeRequest(request: .deactivate(userId: Helpers.userId)) { response in
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
                if let status = meta["status"] as? String, status == "200",
                    let message = meta["message"] as? String, message == "Successful" {
                    self.logoutCleanup()
                } else {
                    self.showAlert(message: kDefaultError)
                }
            }
        }
    }
    
    @objc fileprivate func deleteAccount() {
        let alertController = UIAlertController(title: "Delete Account?", message: "Are you sure you want to delete your account? You won't be able to recover your account in future. Consider using deactivate your account, if you want to remain inactive?", preferredStyle: Helpers.actionSheetStyle())
        //        alertController.view.tintColor = UIColor.black
        
        let deactivate = UIAlertAction(title: "Deactivate", style: .destructive) { (action:UIAlertAction) in
            self.deactivate()
        }
        let delete = UIAlertAction(title: "Delete", style: .destructive) { (action:UIAlertAction) in
            self.spinner(with: "Deleting account...", blockInteraction: true)
            APIController.makeRequest(request: .delete(userId: Helpers.userId)) { response in
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
                    if let status = meta["status"] as? String, status == "200",
                        let message = meta["message"] as? String, message == "Successful" {
                        self.logoutCleanup()
                    } else {
                        self.showAlert(message: kDefaultError)
                    }
                }
            }
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        alertController.addAction(deactivate)
        alertController.addAction(delete)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func notificationSwitched(_ sender: Any) {
        updateAccount()
    }
    
    private func setDistance(distance: String) {
        let boldFont = UIFont(name: "PTSans-Bold", size: 15)!
        let regularFont = UIFont(name: "PTSans-Regular", size: 15)!
        let attribute = NSMutableAttributedString(string: "Distance ", attributes: [.font: regularFont, .foregroundColor: UIColor.black])
        attribute.append(NSAttributedString(string: distance, attributes: [.font: boldFont, .foregroundColor: UIColor.black]))
        self.distantUnitLbl.attributedText = attribute
    }
    
    private func goToWebVC(with url: URL, title: String) {
        let vc = OnboardingWebVC.instantiate(fromAppStoryboard: .onboarding)
        vc.url = url
        vc.title = title
        navigationController?.pushViewController(vc, animated: true)
    }
    
    fileprivate func updateFieldUIs() {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else {
            return
        }
        pushNotifSwift.setOn(user.notificationEnable.contains("true") ? true : false, animated: true)
        setCurrency(currency: user.currency)
        setDistance(distance: user.distance)
        defaultCurrency = Currency(JSONDictionary())
        defaultCurrency?.countryName = user.currencyCountry
        defaultCurrency?.currency = user.currency
        defaultCurrency?.currencySymbol = user.currencySymbol
        
        defaultDistance = user.distance
    }
    
    private func updateAccount() {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
        
        var request = JSONDictionary()
        request["city"] = user.city
        request["state"] = user.state
        request["country"] = user.country
        request["country_id"] = user.countryId
        request["currency"] = defaultCurrency?.currency ?? ""
        request["currency_country"] = defaultCurrency?.countryName ?? ""
        request["currency_symbol"] = defaultCurrency?.currencySymbol ?? ""
        request["distance_unit"] = defaultDistance ?? ""
        request["dob"] = user.dob
        request["email"] = user.email
        request["f_name"] = user.firstname
        request["image_url"] = user.profileImage
        request["profile_video"] = user.profileVideo
        request["profile_video_thumb"] = user.profileVideoThumb
        request["l_name"] = user.lastname
        request["notification_enable"] = pushNotifSwift.isOn ? "true" : "false"
        request["phone_number"] = user.phone
        request["status"] = user.status
        request["tel_country_code"] = user.dialCode
        request["user_id"] = user.id
        request["user_name"] = user.username
        request["work_at"] = user.workAt
        
        
        APIController.makeRequest(request: TrajilisAPI.updateUserDetail(param: request)) { [weak self](response) in
            if let strngSelf = self {
//                MBProgressHUD.hide(for: strngSelf.view, animated: true)
                switch response {
                case .failure(let error):
                    strngSelf.showAlert(message: error.desc)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                    if let meta = json?["meta"] as? JSONDictionary, let message = meta["message"] as? String {
                        strngSelf.showAlert(message: message)
                        if let crncy = strngSelf.defaultCurrency?.currency {
                            CurrencyViewController.saveCurrencyInSettings(crncy: crncy)
                        }
                        Helpers.getCurrentUser(completion: { (success) in
                            strngSelf.updateFieldUIs()
                        })
                    }
                }
            }
        }
    }
    
    
}


extension SettingsViewController: UIScrollViewDelegate {
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        if scrollView.contentOffset.x != 0 {
            scrollView.contentOffset.x = 0
        }
    }
}

extension SettingsViewController: MFMailComposeViewControllerDelegate {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
    
}
