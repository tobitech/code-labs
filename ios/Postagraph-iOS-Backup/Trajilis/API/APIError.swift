//
//  APIError.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 31/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import Foundation

struct APIError: Error {
    static var SomethingWentWrong: APIError {
        return APIError.init(desc: "Unknown error")
    }
    let desc: String
}
