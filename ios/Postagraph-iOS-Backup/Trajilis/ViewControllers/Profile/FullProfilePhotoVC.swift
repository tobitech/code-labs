//
//  FullProfilePhotoVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 02/03/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FullProfilePhotoVC: UIViewController {

    @IBOutlet var imageView: UIImageView!
    var urlString = ""

    override func viewDidLoad() {
        super.viewDidLoad()
        let tap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        imageView.isUserInteractionEnabled = true
        imageView.addGestureRecognizer(tap)

        if urlString == "http://52.70.183.47/Dev_Traz/ProfileImage/avtar.png" {
            urlString = "http://stage.trajilis.com/ProfileImage/avtar960x1704.png"
            if let url = URL(string: urlString) {
                imageView.sd_setImage(with: url, completed: nil)
            }
        } else if urlString == "http://stage.trajilis.com/ProfileImage/avtar.png" {
            urlString = "http://stage.trajilis.com/ProfileImage/avtar960x1704.png"
            if let url  = URL(string: urlString) {
                imageView.sd_setImage(with: url, completed: nil)
            }
        } else {
            if let url  = URL(string: urlString) {
                imageView.sd_setImage(with: url, completed: nil)
            }
        }
    }

    @objc private func handleTap() {
        dismiss(animated: true, completion: nil)
    }

}
