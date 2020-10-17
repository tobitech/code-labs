//
//  CategoryViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 06/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit

class CategoryViewController: UIViewController {

    // MARK: - Segues

    private enum Segue {

        static let Color = "Color"

    }

    // MARK: - Properties

    @IBOutlet var colorView: UIView!
    @IBOutlet var nameTextField: UITextField!

    // MARK: -

    var category: Category?

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Edit Category"

        setupView()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Update Category
        if let name = nameTextField.text, !name.isEmpty {
            category?.name = name
        }
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {
        case Segue.Color:
            guard let destination = segue.destination as? ColorViewController else {
                return
            }

            // Configure Destination
            destination.delegate = self
            destination.color = category?.color ?? .white
        default:
            break
        }
    }

    // MARK: - View Methods

    private func setupView() {
        setupNameTextField()
    }

    // MARK: -

    private func setupColorView() {
        // Configure Layer Color View
        colorView.layer.cornerRadius = CGFloat(colorView.frame.width / 2.0)

        updateColorView()
    }

    private func updateColorView() {
        // Configure Color View
        colorView.backgroundColor = category?.color
    }

    // MARK: -

    private func setupNameTextField() {
        // Configure Name Text Field
        nameTextField.text = category?.name
    }

}

extension CategoryViewController: ColorViewControllerDelegate {

    func controller(_ controller: ColorViewController, didPick color: UIColor) {
        // Update Category
        category?.color = color

        // Update View
        updateColorView()
    }

}
