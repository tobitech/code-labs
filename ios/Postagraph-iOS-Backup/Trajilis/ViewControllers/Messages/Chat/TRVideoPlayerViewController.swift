//
//  TRVideoPlayerViewController.swift
//  Trajilis
//
//  Created by bharats802 on 22/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import AVKit

class TRVideoPlayerViewController: AVPlayerViewController {

    var url:URL?
    override func viewDidLoad() {
        super.viewDidLoad()
//        self.setupNavigationController()
        self.view.backgroundColor = .appBG
        self.title = "Video"

        if let videoURL = self.url {
            let player = AVPlayer(url: videoURL)
            self.player = player            
        }
        
        // Do any additional setup after loading the view.
        let cancelBtn = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(btnCancelTapped(sender:)))
        self.navigationItem.leftBarButtonItem  = cancelBtn
        // Do any additional setup after loading the view.
    }
    @IBAction func btnCancelTapped(sender:UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
    }

    class func getVC(url:URL?) -> TRVideoPlayerViewController {
        let vc = TRVideoPlayerViewController()
        vc.url = url
        return vc
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
