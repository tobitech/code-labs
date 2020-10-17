//
//  CategoriesViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 06/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

class CategoriesViewController: UIViewController {

    // MARK: - Segues

    private enum Segue {

        static let Category = "Category"
        static let AddCategory = "AddCategory"

    }

    // MARK: - Properties

    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    // MARK: -

    var note: Note?

    // MARK: -

    private lazy var fetchedResultsController: NSFetchedResultsController<Category> = {
        guard let managedObjectContext = self.note?.managedObjectContext else {
            fatalError("No Managed Object Context Found")
        }

        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Category> = Category.fetchRequest()

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: "name", ascending: true)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Categories"

        setupView()

        do {
            try fetchedResultsController.performFetch()
        } catch {
            let fetchError = error as NSError
            print("Unable to Perform Fetch Request")
            print("\(fetchError), \(fetchError.localizedDescription)")
        }

        updateView()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {
        case Segue.AddCategory:
            guard let destination = segue.destination as? AddCategoryViewController else {
                return
            }

            // Configure Destination
            destination.managedObjectContext = note?.managedObjectContext
        case Segue.Category:
            guard let destination = segue.destination as? CategoryViewController else {
                return
            }

            guard let cell = sender as? CategoryTableViewCell else {
                return
            }

            guard let indexPath = tableView.indexPath(for: cell) else {
                return
            }

            // Fetch Category
            let category = fetchedResultsController.object(at: indexPath)

            // Configure Destination
            destination.category = category
        default:
            break
        }
    }

    // MARK: - View Methods

    private func setupView() {
        setupMessageLabel()
        setupBarButtonItems()
    }

    private func updateView() {
        var hasCategories = false

        if let fetchedObjects = fetchedResultsController.fetchedObjects {
            hasCategories = fetchedObjects.count > 0
        }

        tableView.isHidden = !hasCategories
        messageLabel.isHidden = hasCategories
    }

    // MARK: -

    private func setupMessageLabel() {
        // Configure Message Label
        messageLabel.text = "You don't have any categories yet."
    }

    // MARK: -

    private func setupBarButtonItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(add(sender:)))
    }

    // MARK: - Actions

    @objc private func add(sender: UIBarButtonItem) {
        performSegue(withIdentifier: Segue.AddCategory, sender: self)
    }

}

extension CategoriesViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }

    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()

        updateView()
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows(at: [indexPath], with: .fade)
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }
        case .update:
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? CategoryTableViewCell {
                configure(cell, at: indexPath)
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows(at: [indexPath], with: .fade)
            }

            if let newIndexPath = newIndexPath {
                tableView.insertRows(at: [newIndexPath], with: .fade)
            }
        }
    }

}

extension CategoriesViewController: UITableViewDataSource {

    func numberOfSections(in tableView: UITableView) -> Int {
        guard let sections = fetchedResultsController.sections else { return 0 }
        return sections.count
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let section = fetchedResultsController.sections?[section] else { return 0 }
        return section.numberOfObjects
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // Dequeue Reusable Cell
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryTableViewCell.reuseIdentifier, for: indexPath) as? CategoryTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        // Configure Cell
        configure(cell, at: indexPath)

        return cell
    }

    func configure(_ cell: CategoryTableViewCell, at indexPath: IndexPath) {
        // Fetch Note
        let category = fetchedResultsController.object(at: indexPath)

        // Configure Cell
        cell.nameLabel.text = category.name

        if note?.category == category {
            cell.nameLabel.textColor = .bitterSweet
        } else {
            cell.nameLabel.textColor = .black
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        // Fetch Category
        let category = fetchedResultsController.object(at: indexPath)

        // Delete Category
        note?.managedObjectContext?.delete(category)
    }

}

extension CategoriesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)

        // Fetch Category
        let category = fetchedResultsController.object(at: indexPath)

        // Update Note
        note?.category = category

        // Pop View Controller From Navigation Stack
        let _ = navigationController?.popViewController(animated: true)
    }

}
