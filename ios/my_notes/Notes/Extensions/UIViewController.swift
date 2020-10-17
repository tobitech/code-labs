//
//  UIViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 06/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

extension UIViewController {

    // MARK: - Alerts

    func showAlert(with title: String, and message: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)

        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))

        // Present Alert Controller
        present(alertController, animated: true, completion: nil)
    }

}
