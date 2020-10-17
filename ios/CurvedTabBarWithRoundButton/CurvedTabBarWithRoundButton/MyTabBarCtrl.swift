//
//  MyTabBarCtrl.swift
//  CurvedTabBarWithRoundButton
//
//  Created by Oluwatobi Omotayo on 04/05/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

class MyTabBarCtrl: UITabBarController, UITabBarControllerDelegate {
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupMiddleButton()
    }
    
    // TabBarButton - Setup Middle Button
    func setupMiddleButton() {
        let middleBtn = UIButton(frame: CGRect(x: (self.view.bounds.width / 2 - 25), y: -20, width: 50, height: 50))
        
        // Style the button your own way
        middleBtn.layer.cornerRadius = 25.0
        middleBtn.layer.masksToBounds = true
        middleBtn.setImage(UIImage(systemName: "folder.fill"), for: .normal)
        middleBtn.backgroundColor = .black
        
        // add to the tab bar and click event
        self.tabBar.addSubview(middleBtn)
        middleBtn.addTarget(self, action: #selector(self.menuButtonAction), for: .touchUpInside)
        
        self.view.layoutIfNeeded()
    }
    
    @objc func menuButtonAction() {
        print(123...)
        self.selectedIndex = 2 // to select the middle tab. use "1" if you have only 3 tabs
    }
}
