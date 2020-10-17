//
//  ViewController.swift
//  EnvironmentsConfig
//
//  Created by Oluwatobi Omotayo on 06/05/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        #if DEBUG
            print("I am from debug")
        #endif
        
        print(Environment.apiKey)
        print(Environment.rootURL.absoluteString)
    }


}

