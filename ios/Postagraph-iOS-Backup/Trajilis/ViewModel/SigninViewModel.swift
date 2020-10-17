//
//  AuthViewModel.swift
//  Trajilis
//
//  Created by Perfect Aduh on 12/08/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import Foundation
import Flurry_iOS_SDK

class SigninViewModel {
    
    
    var signinComplete: ((String?, User?)->())?
    
    init() {
        
    }
    
    
    func signin(email: String, password: String) {
        
        let param = [
            "device_token": UserDefaults.standard.string(forKey: "deviceId") ?? "5555555555",
            "device_type": "ios",
            "email": email,
            "lat": UserDefaults.standard.string(forKey: "latitude") ?? "0",
            "lon": UserDefaults.standard.string(forKey: "longitude") ?? "0",
            "offset": "0",
            "password": password
        ]
        //MBProgressHUD.showAdded(to: view, animated: true).label.text = "One moment..."
        APIController.makeRequest(request: .login(param: param)) { [weak self](response) in
            guard let `self` = self else { return }
            switch response {
            case .failure(_):
                self.signinComplete?("Unknown error", nil)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                guard let session_id = json?["session_id"] as? String,
                    let data = json?["data"] as? JSONDictionary,let apiKey = json?["apiKey"] as? JSONDictionary,let accessToken = apiKey["accessToken"],let refreshToken = apiKey["refreshToken"] else {
                        let meta = json?["meta"] as? JSONDictionary
                        let message = meta?["message"] as? String
                        self.signinComplete?(message ?? "Invalid credential", nil)
                        return
                }
                print("LOGIN REFRESH TOKEN: ", refreshToken)
                let user = User.init(json: data)
                if !user.id.isEmpty {
                    
                    Flurry.setUserID(user.id);
                    UserDefaults.standard.set(user.id, forKey: USERID)
                    UserDefaults.standard.set(session_id, forKey: APIREQUESTTOKENKEY)
                    UserDefaults.standard.set(refreshToken, forKey: kRefreshToken)
                    UserDefaults.standard.set(accessToken, forKey: kAccessToken)
                    UserDefaults.standard.synchronize()
                    (UIApplication.shared.delegate as? AppDelegate)?.user = user
                    Helpers.getCurrentUser()
                    self.signinComplete?(nil, user)
                } else {
                    let meta = json?["meta"] as? JSONDictionary
                    let message = meta?["message"] as? String
                    self.signinComplete?(message ?? "Invalid credential", nil)
                }
            }
        }
    }
}
