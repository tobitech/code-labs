//
//  AddCategoryViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 06/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

class AddCategoryViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var nameTextField: UITextField!

    // MARK: -

    var managedObjectContext: NSManagedObjectContext?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Category"

        setupView()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Show Keyboard
        nameTextField.becomeFirstResponder()
    }

    // MARK: - View Methods

    private func setupView() {
        setupBarButtonItems()
    }

    // MARK: -

    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(save(sender:)))
    }

    // MARK: - Actions

    @objc private func save(sender: UIBarButtonItem) {
        guard let managedObjectContext = managedObjectContext else { return }
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(with: "Name Missing", and: "Your category doesn't have a name.")
            return
        }

        // Create Category
        let category = Category(context: managedObjectContext)

        // Configure Category
        category.name = nameTextField.text

        // Pop View Controller
        _ = navigationController?.popViewController(animated: true)
    }

}
