//
//  URLSessionProtocol.swift
//  DogYears
//
//  Created by Oluwatobi Omotayo on 09/01/2020.
//  Copyright © 2020 Razeware. All rights reserved.
//

import Foundation

protocol URLSessionProtocol {
    func dataTask(with request: URLRequest,
                  completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        
        let task = dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask
        
        return task as URLSessionDataTaskProtocol
    }
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}
