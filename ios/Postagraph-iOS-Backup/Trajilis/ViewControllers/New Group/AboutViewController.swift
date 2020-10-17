//
//  About ViewController.swift
//  Trajilis
//
//  Created by Moses on 08/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class AboutViewController: UIViewController {

    @IBOutlet weak var version : UILabel! {
        didSet {
            var versionNumber: String = ""
            
            if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
                versionNumber = version + "."
            }
            
            if let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
                versionNumber += build
            }
            
            version.text = "Version " + versionNumber
        }
    }
    
    
    init() {
        super.init(nibName: "AboutViewController", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Texts.about
        showNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavigationBar()
    }


    @IBAction private func help() {
        
    }
    
    @IBAction private func rate() {
        
    }

    @IBAction private func term() {
        
    }

    @IBAction private func policy() {
        
    }


}
