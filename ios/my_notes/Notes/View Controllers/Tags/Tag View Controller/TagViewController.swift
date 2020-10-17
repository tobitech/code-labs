//
//  TagViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 07/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

class TagViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var nameTextField: UITextField!

    // MARK: -

    var tag: Tag?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Tag"

        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Update Tag
        if let name = nameTextField.text, !name.isEmpty {
            tag?.name = name
        }
    }

    // MARK: - View Methods

    private func setupView() {
        setupNameTextField()
    }

    // MARK: -

    private func setupNameTextField() {
        // Configure Name Text Field
        nameTextField.text = tag?.name
    }

}
