//
//  ViewController.swift
//  MyLottieSample
//
//  Created by Oluwatobi Omotayo on 04/11/2019.
//  Copyright © 2019 Oluwatobi Omotayo. All rights reserved.
//

import UIKit
import Lottie

class ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
    }

    @IBAction func showAnimation(_ sender: Any) {

        let loadingAnimationView = AnimationView(name: "loading_feed")
        
        loadingAnimationView.contentMode = .scaleAspectFill
        loadingAnimationView.loopMode = .loop
        self.view.addSubview(loadingAnimationView)
        
        loadingAnimationView.translatesAutoresizingMaskIntoConstraints = false
            NSLayoutConstraint.activate([
                loadingAnimationView.topAnchor.constraint(equalTo: view.topAnchor),
                loadingAnimationView.leftAnchor.constraint(equalTo: view.leftAnchor),
                loadingAnimationView.rightAnchor.constraint(equalTo: view.rightAnchor),
                loadingAnimationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
//            loadingAnimationView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
//            loadingAnimationView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
//            loadingAnimationView.widthAnchor.constraint(equalToConstant: 200),
//            loadingAnimationView.heightAnchor.constraint(equalToConstant: 200)
            ])
        
        loadingAnimationView.play()
    }

}

