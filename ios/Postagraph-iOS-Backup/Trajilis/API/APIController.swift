//
//  APIController.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 31/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation
import Moya
import Result

typealias JSONDictionary = [String: Any?]
struct APIController {
    
    typealias Completion = (_ result: Result<Moya.Response, APIError>) -> Void
    
    static func makeRequest(request: TrajilisAPI, completion: @escaping Completion) {
      
        APIProvider.request(request) { (result) in
            DispatchQueue.main.async {
                
                // 404
                if let value = result.value,value.statusCode == 401 {
                    // go for retrial
                    AuthManager.shared.refreshToken(request: request, completion: completion)
                    return
                }
                
                switch result {
                case .failure(let error):
                    completion(Result.failure(APIError.init(desc: error.localizedDescription)))
                case .success(let response):
                    if !validateResponse(response.statusCode) {
                        guard let json = try? response.mapJSON() as? JSONDictionary else {
                            completion(Result.failure(APIError.init(desc: "Unknown Error")))
                            return
                        }
                        completion(Result.failure(APIError.init(desc: json?["message"] as? String ?? json?["data"] as? String ?? "Unknown Error")))
                        return
                    }
                    completion(Result.success(response))
                }
            }
        }
    }    
    static func validateResponse(_ statusCode: Int) -> Bool {
        if case 200...300 = statusCode {
            return true
        }
        return false
    }
}
