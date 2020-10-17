//
//  ViewController.swift
//  Notes
//
//  Created by Bart Jacobs on 05/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit
import CoreData

class NotesViewController: UIViewController {

    // MARK: - Segues

    private enum Segue {

        static let Note = "Note"
        static let AddNote = "AddNote"

    }

    // MARK: - Properties

    @IBOutlet var notesView: UIView!
    @IBOutlet var messageLabel: UILabel!
    @IBOutlet var tableView: UITableView!

    // MARK: -

    private var coreDataManager = CoreDataManager(modelName: "Notes")

    // MARK: -

    private lazy var fetchedResultsController: NSFetchedResultsController<Note> = {
        // Create Fetch Request
        let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()

        // Configure Fetch Request
        fetchRequest.sortDescriptors = [NSSortDescriptor(key: #keyPath(Note.updatedAt), ascending: false)]

        // Create Fetched Results Controller
        let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                                  managedObjectContext: self.coreDataManager.mainManagedObjectContext,
                                                                  sectionNameKeyPath: nil,
                                                                  cacheName: nil)

        // Configure Fetched Results Controller
        fetchedResultsController.delegate = self

        return fetchedResultsController
    }()

    // MARK: -

    private var hasNotes: Bool {
        guard let fetchedObjects = fetchedResultsController.fetchedObjects else { return false }
        return fetchedObjects.count > 0
    }

    // MARK: -

    private let estimatedRowHeight = CGFloat(44.0)

    // MARK: -

    private lazy var updatedAtDateFormatter: DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, HH:mm"
        return dateFormatter
    }()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Notes"

        setupView()
        fetchNotes()
        updateView()
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard let identifier = segue.identifier else { return }

        switch identifier {
        case Segue.AddNote:
            guard let destination = segue.destination as? AddNoteViewController else {
                return
            }

            // Configure Destination
            destination.managedObjectContext = coreDataManager.mainManagedObjectContext
        case Segue.Note:
            guard let destination = segue.destination as? NoteViewController else {
                return
            }

            guard let indexPath = tableView.indexPathForSelectedRow else {
                return
            }

            // Fetch Note
            let note = fetchedResultsController.object(at: indexPath)

            // Configure Destination
            destination.note = note
        default:
            break
        }
    }

    // MARK: - View Methods

    private func setupView() {
        setupMessageLabel()
        setupTableView()
    }

    private func updateView() {
        tableView.isHidden = !hasNotes
        messageLabel.isHidden = hasNotes
    }

    // MARK: -

    private func setupMessageLabel() {
        messageLabel.text = "You don't have any notes yet."
    }

    // MARK: -

    private func setupTableView() {
        tableView.isHidden = true
        tableView.estimatedRowHeight = estimatedRowHeight
        tableView.rowHeight = UITableViewAutomaticDimension
    }

    // MARK: - Helper Methods

    private func fetchNotes() {
        coreDataManager.mainManagedObjectContext.perform {
            do {
                let fetchRequest: NSFetchRequest<Note> = Note.fetchRequest()
                
                let notes = try fetchRequest.execute()
                
                if let note = notes.first {
                    print(note)
                    
                    if let title = note.title {
                        print(title)
                    }
                    
                    print(note)
                    
                    if let category = note.category {
                        print(category)
                    }
                }
            } catch {
                print(error)
            }
        }
    }

}

extension NotesViewController: NSFetchedResultsControllerDelegate {

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
            if let indexPath = indexPath, let cell = tableView.cellForRow(at: indexPath) as? NoteTableViewCell {
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

extension NotesViewController: UITableViewDataSource {

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
        guard let cell = tableView.dequeueReusableCell(withIdentifier: NoteTableViewCell.reuseIdentifier, for: indexPath) as? NoteTableViewCell else {
            fatalError("Unexpected Index Path")
        }

        // Configure Cell
        configure(cell, at: indexPath)

        return cell
    }

    func configure(_ cell: NoteTableViewCell, at indexPath: IndexPath) {
        // Fetch Note
        let note = fetchedResultsController.object(at: indexPath)

        // Configure Cell
        cell.titleLabel.text = note.title
        cell.contentsLabel.text = note.contents
        cell.tagsLabel.text = note.alphabetizedTagsAsString ?? "No Tags"
        cell.updatedAtLabel.text = updatedAtDateFormatter.string(from: note.updatedAtAsDate)

        if let color = note.category?.color {
            cell.categoryColorView.backgroundColor = color
        } else {
            cell.categoryColorView.backgroundColor = .white
        }
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }

        // Fetch Note
        let note = fetchedResultsController.object(at: indexPath)

        // Delete Note
        coreDataManager.mainManagedObjectContext.delete(note)
    }

}

extension NotesViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }

}
