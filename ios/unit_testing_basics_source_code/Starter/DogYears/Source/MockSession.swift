//
//  MockSession.swift
//  DogYears
//
//  Created by Oluwatobi Omotayo on 09/01/2020.
//  Copyright © 2020 Razeware. All rights reserved.
//

import Foundation

class MockSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        completionHandler(Data(), nil, nil)
        return MockDataTask()
    }
}
