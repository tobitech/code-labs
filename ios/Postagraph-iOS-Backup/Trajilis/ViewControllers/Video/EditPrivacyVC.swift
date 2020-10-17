//
//  EditPrivacyVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 19/06/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

final class EditPrivacyVC: BaseVC {
    @IBOutlet var publicButton: UIButton!
    @IBOutlet var followButton: UIButton!
    @IBOutlet var privateButton: UIButton!
    @IBOutlet var containerView: UIView!

    var postType = "PUBLIC"
    var feed: Feed!

    override func viewDidLoad() {
        super.viewDidLoad()
        containerView.layer.cornerRadius = 15
        containerView.layer.masksToBounds = true
        if feed.feed_visibility == "PUBLIC" {
            privacyTapped(publicButton)
        } else if feed.feed_visibility == "FOLLOWER" {
            privacyTapped(followButton)
        } else {
            privacyTapped(privateButton)
        }
        navigationItem.title = "Change Privacy"
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
        navigationController?.navigationBar.prefersLargeTitles = false
    }

    @IBAction func privacyTapped(_ sender: UIButton) {
        let checked = UIImage(named: "privacy-checked")
        let unchecked = UIImage(named: "privacy-unchecked")
        if sender.tag == 1000 {
            postType = "PUBLIC"
            publicButton.setImage(checked, for: .normal)
            followButton.setImage(unchecked, for: .normal)
            privateButton.setImage(unchecked, for: .normal)
        } else if sender.tag == 1001 {
            postType = "FOLLOWER"
            publicButton.setImage(unchecked, for: .normal)
            followButton.setImage(checked, for: .normal)
            privateButton.setImage(unchecked, for: .normal)
        } else if sender.tag == 1002 {
            postType = "PRIVATE"
            publicButton.setImage(unchecked, for: .normal)
            followButton.setImage(unchecked, for: .normal)
            privateButton.setImage(checked, for: .normal)
        }
    }

    @IBAction func doneTapped(_ sender: Any) {
        let parameters: JSONDictionary = [
            "user_id": UserDefaults.standard.string(forKey: USERID)!,
            "feed_id": feed.id,
            "feed_visibility": postType
        ]
        self.spinner(with: "Updating...", blockInteraction: true)
        APIController.makeRequest(request: .editFeed(param: parameters)) { (response) in
            DispatchQueue.main.async {
                self.hideSpinner()
                switch response {
                case .success(_):
                    NotificationCenter.default.post(name: Constants.NotificationName.Reload, object: nil)
                    self.navigationController?.popViewController(animated: true)
                case .failure(let error):
                    self.showAlert(message: error.desc)
                }
            }
        }
    }

}
