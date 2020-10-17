//
//  ViewController.swift
//  Breakpoints
//
//  Created by Oluwatobi Omotayo on 04/07/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

struct User {
    
    let first: String
    let last: String
    
}

class ViewController: UIViewController {
    
    enum JSONError: Error {
        case resourceNotFound
        case unableToLoadData
        case invalidJSON
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        /// let's trigger an exception by creating a user and storing it in the UserDefaults database
        let currentUser = User(first: "Tobi", last: "Omotayo")
        UserDefaults.standard.set(currentUser, forKey: "currentUser")
        
        /*
        do {
            // Load JSON data
            let json = try loadJSONData()
            print(json)
        } catch {
            print(error)
        }
        */
    }
    
    /*
    private func loadJSONData() throws -> Any {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            throw JSONError.resourceNotFound
        }
        
        guard let data = try? Data.init(contentsOf: url) else {
            throw JSONError.unableToLoadData
        }
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw JSONError.invalidJSON
        }
        
        return json
    }
    */
    
    private func loadJSONData() throws -> Any {
        /// because this method is throwing there is not need to wrap below statement in a docatch
        /// any error thrown will be propagated at the call site of this method
        let data = try loadData()
        
        guard let json = try? JSONSerialization.jsonObject(with: data, options: []) else {
            throw JSONError.invalidJSON
        }
        
        return json
    }
    
    private func loadData() throws -> Data {
        guard let url = Bundle.main.url(forResource: "data", withExtension: "json") else {
            throw JSONError.resourceNotFound
        }
        
        guard let data = try? Data.init(contentsOf: url) else {
            throw JSONError.unableToLoadData
        }
        
        return data
    }
}

