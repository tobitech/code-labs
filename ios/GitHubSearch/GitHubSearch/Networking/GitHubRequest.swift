//
//  SearchRequest.swift
//  GitHubSearch
//
//  Created by Oluwatobi Omotayo on 18/05/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import Foundation
import Moya

enum GitHub {
    case search
}

extension GitHub: TargetType {
    var baseURL: URL {
        return URL(string: "")!
    }
    
    var path: String {
        return ""
    }
    
    var method: Moya.Method {
        return .get
    }
    
    var sampleData: Data {
        return .init()
    }
    
    var task: Task {
        return .requestPlain
    }
    
    var headers: [String : String]? {
        return [:]
    }
}
