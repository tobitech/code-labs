//
//  SignupViewModel.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 01/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import PhoneNumberKit

final class SignupViewModel {
    var firstname = ""
    var lastname = ""
    var email = ""
    var password = ""
    var phone = ""
    var username = ""
    var country: Country? {
        didSet {
            if let _ = country?.sortName {
                didSelectCountry?()
            }
        }
    }
    
    var countries = [Country]()
    
    var emailVerificationComplete:((String?) -> ())?
    var fetchCountriesCompleted:((String?) -> ())?
    var phoneAvailabilityCheckComplete:((String?) -> ())?
    var otpRequestComplete:((String?) -> ())?
    var phoneVerificationComplete:((String?) -> ())?
    var didSelectCountry:(() -> ())?
    var usernameVerificationComplete:((String?) -> ())?
    var signupComplete:((String?) -> ())?
    var passwordResetComplete: ((String?, Bool)->())?
    
    var countryFlag: URL? {
        guard let code = country?.sortName else { return nil }
        let urlString = "http://www.geonames.org/flags/x/\(code.lowercased()).\("gif")"
        return URL(string: urlString)
    }
    
    func signup() {
        var param: JSONDictionary = [
            "country": country!.name,
            "country_id": country!.id,
            "device_token": UserDefaults.standard.string(forKey: "deviceId") ?? "5555555555",
            "device_tpye": "ios",
            "email": email,
            "f_name": firstname,
            "l_name": lastname,
            "lat": UserDefaults.standard.string(forKey: "latitude") ?? "0",
            "lon": UserDefaults.standard.string(forKey: "longitude") ?? "0",
            "offset": "0",
            "password": password,
            "phone_number": phone,
            "phone_varified": "true",
            "registration_type": "regular",
            "tel_country_code": country!.dialCode,
            "user_name": username,
            "profile_image_type" : ""
        ]
        
        if let invitedBy = UserDefaults.standard.string(forKey: "User_Invited_By") {
            param["referal"] = invitedBy
        }
        
        APIController.makeRequest(request: .signup(param: param)) { (response) in
            print("got ressponse why its not working??????")
            switch response {
            case .failure(let error):
                self.signupComplete?(error.desc)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else {
                    self.signupComplete?(kDefaultError)
                    return
                }
                guard let session_id = json?["session_id"] as? String,
                    let data = json?["data"] as? JSONDictionary,let apiKey = json?["apiKey"] as? JSONDictionary,let accessToken = apiKey["accessToken"],let refreshToken = apiKey["refreshToken"] else {
                        
                        if let meta = json?["meta"] as? JSONDictionary, let msg = meta["message"] as? String {
                            self.signupComplete?(msg)
                        } else {
                            self.signupComplete?(kDefaultError)
                        }
                        return
                }
                let user = User.init(json: data)
                UserDefaults.standard.set(user.id, forKey: USERID)
                UserDefaults.standard.set(session_id, forKey: APIREQUESTTOKENKEY)
                kAppDelegate.user = user
                
                UserDefaults.standard.set(refreshToken, forKey: kRefreshToken)
                UserDefaults.standard.set(accessToken, forKey: kAccessToken)
                UserDefaults.standard.synchronize()
                self.signupComplete?(nil)
            }
        }
    }
    
    func checkUsername() {
        guard !username.isEmpty else { return }
        APIController.makeRequest(request: .verifyUsername(username: username)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(let error):
                    self.usernameVerificationComplete?(error.desc)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary,
                        let message = meta["message"] as? String else { return }
                    if message.lowercased() != "Username Already Exist".lowercased() {
                        self.usernameVerificationComplete?(nil)
                    } else {
                        self.usernameVerificationComplete?(message)
                    }
                }
            }

        }
    }
    
    func getCountries() {
        APIController.makeRequest(request: .countries) { (response) in
            switch response {
            case .failure(let err):
                self.fetchCountriesCompleted?(err.desc)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                self.countries = data.compactMap{ Country.init(json: $0) }
                let local = (Locale.current as NSLocale).object(forKey: NSLocale.Key.countryCode) as? String ?? "US"
                self.country = self.countries.first(where: { $0.sortName.lowercased() == local.lowercased() })
                self.fetchCountriesCompleted?(nil)
                
            }
        }
    }
    
    func verifyPhone(code: String) {
        guard let number = try? PhoneNumberKit().parse(phone, withRegion: country!.sortName, ignoreType: false) else {
            return
        }
        let formatted = PhoneNumberKit().format(number, toType: .e164)
        APIController.makeRequest(request: .verifyPhone(param: ["OTP": code, "phone": formatted])) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    self.phoneVerificationComplete?("Verification failed. Please try again.")
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary,
                        let message = meta["message"] as? String else { return }
                    if message.lowercased() == "Phone no. verified".lowercased() {
                        self.phoneVerificationComplete?(nil)
                    } else {
                        self.phoneVerificationComplete?(message)
                    }
                }
            }
        }
    }
    
    func requestOTP() {
        do {
            guard let country = country else { return }
            guard let number = try? PhoneNumberKit().parse(phone, withRegion: country.sortName, ignoreType: false) else {
                self.otpRequestComplete?("Please enter a valid phone number.")
                return
            }
            let formatted = PhoneNumberKit().format(number, toType: .e164)
            APIController.makeRequest(request: .requestPhoneOTP(param: ["phone": formatted])) { [weak self](response) in
                DispatchQueue.main.async {
                    switch response {
                    case .failure(let error):
                        self?.otpRequestComplete?(error.desc)
                    case .success(let result):
                        guard let json = try? result.mapJSON() as? JSONDictionary,
                            let meta = json?["meta"] as? JSONDictionary,
                            let message = meta["message"] as? String else { return }
                        if message.lowercased() == "sent".lowercased() {
                            self?.otpRequestComplete?(nil)
                        } else {
                            self?.otpRequestComplete?(message)
                        }
                    }
                }
            }
        } catch {
            print(error)
            self.otpRequestComplete?("App is not able to perform the action right now. Please try again later.")
        }
        
    }
    
    func checkPhoneAvailability() {
        APIController.makeRequest(request: .phoneAvailability(param: ["phone_no": phone, "tele_country_code": country!.dialCode ])) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(let error):
                    self.phoneAvailabilityCheckComplete?(error.desc)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary,
                        let message = meta["message"] as? String else { return }
                    if message.lowercased() == "UserId Available".lowercased() {
                        self.phoneAvailabilityCheckComplete?(nil)
                    } else {
                        self.phoneAvailabilityCheckComplete?(Texts.phoneExist)
                    }
                }
            }
        }
    }
    
    func verifyEmail() {
        APIController.makeRequest(request: .emailAvailability(email: email)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(let error):
                    self.emailVerificationComplete?(error.desc)
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let meta = json?["meta"] as? JSONDictionary,
                        let message = meta["message"] as? String else { return }
                    if message.lowercased() == "UserId Available".lowercased() {
                        self.emailVerificationComplete?(nil)
                    } else {
                        self.emailVerificationComplete?(Texts.emailAlreadyExits)
                    }
                }
            }
        }
    }
    
    func passwordReset() {
        
        let param = [
            "password": password,
            "phone": phone,
            "phone_verified": "true",
            "tele_code": country!.dialCode
        ]
        
        APIController.makeRequest(request: .resetPassword(param: param)) { [weak self](response) in
            guard let `self`  = self else { return }
        
            switch response {
            case .failure(_):
                self.passwordResetComplete?(kDefaultError, false)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else {
                        self.passwordResetComplete?(kDefaultError, false)
                        return
                }
                if let status = meta["status"] as? String, status == "200" {
                    if let message = meta["message"] as? String, message == "failed" {
                        self.passwordResetComplete?(kDefaultError, false)
                    } else {
                        self.passwordResetComplete?(nil, true)
                    }
                }
            }
        }
    }
}
