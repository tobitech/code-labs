//
//  SocketIOManager.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 04/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import Moya
import Result
import Flurry_iOS_SDK

final class AuthManager: NSObject {
    typealias Completion = (_ result: Result<Moya.Response, APIError>) -> Void
    static let shared = AuthManager()
    var isRefreshting:Bool = false
    
    var pendingRequests:[TrajilisAPI:Completion] = [TrajilisAPI:Completion]()
    
    override init() {
        super.init()
    }

    func refreshToken(request: TrajilisAPI, completion: @escaping Completion) {
        
        guard let refreshToken = UserDefaults.standard.string(forKey: kRefreshToken) else {
            completion(Result(error: APIError(desc: "Not able to connect with server.")))
            return
        }
        print("Refreshing Refresh Token ", refreshToken)
        //TrajilisAPI
        self.pendingRequests[request] = completion
        if self.isRefreshting {
            return
        }
        self.isRefreshting = true
        APIController.makeRequest(request: .refreshToken(refresh: refreshToken)) { (response) in
            self.isRefreshting = false
            switch response {
            case .failure(let error):
                
                Flurry.logError("refresh_token_api_fail", message: error.desc, exception: nil);
                
                
                if let comple = self.pendingRequests[request] {
                    comple(Result(error: APIError(desc: "Your session has expired. Please login again.")))
                }
                self.pendingRequests.removeAll()
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
                
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary else { return }
                guard let accessToken = json?["accessToken"],let refreshToken =  json?["refreshToken"] else {
                        return
                }
                UserDefaults.standard.set(refreshToken, forKey: kRefreshToken)
                UserDefaults.standard.set(accessToken, forKey: kAccessToken)
                UserDefaults.standard.synchronize()
                for request in self.pendingRequests.keys {
                    if let comple = self.pendingRequests[request] {
                        APIController.makeRequest(request: request, completion: comple)
                    }
                }
                self.pendingRequests.removeAll()
            }
            
        }
    }
}
