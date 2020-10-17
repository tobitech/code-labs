//
//  AddLocationViewController.swift
//  Cloudy
//
//  Created by Bart Jacobs on 10/07/2017.
//  Copyright © 2017 Cocoacasts. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

protocol AddLocationViewControllerDelegate {
    func controller(_ controller: AddLocationViewController, didAddLocation location: Location)
}

class AddLocationViewController: UIViewController {

    // MARK: - Properties

    @IBOutlet var tableView: UITableView!
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var activityIndicatorView: UIActivityIndicatorView!

    // MARK: -

    var viewModel: AddLocationViewViewModel!

    // MARK: -

    var delegate: AddLocationViewControllerDelegate?

    // MARK: -

    private let disposeBag = DisposeBag()

    // MARK: - View Life Cycle

    override func viewDidLoad() {
        super.viewDidLoad()

        title = "Add Location"

        // Initialize View Model
        viewModel = AddLocationViewViewModel(query: searchBar.rx.text.orEmpty.asDriver(), locationService: Geocoder())

        // Drive Table View
        viewModel.locations
            .drive(onNext: { [unowned self] (_) in
                // Update Table View
                self.tableView.reloadData()
            })
            .disposed(by: disposeBag)

        // Drive Activity Indicator View
        viewModel.querying.drive(activityIndicatorView.rx.isAnimating).disposed(by: disposeBag)

        // Search Button Clicked
        searchBar.rx.searchButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned self] in
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)

        // Cancel Button Clicked
        searchBar.rx.cancelButtonClicked
            .asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned self] in
                self.searchBar.resignFirstResponder()
            })
            .disposed(by: disposeBag)
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Show Keyboard
        searchBar.becomeFirstResponder()
    }

    // MARK: - View Methods

    private func setupView() {

    }

    private func updateView() {

    }

}

extension AddLocationViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.numberOfLocations
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: LocationTableViewCell.reuseIdentifier, for: indexPath) as? LocationTableViewCell else { fatalError("Unexpected Table View Cell") }

        if let viewModel = viewModel.viewModelForLocation(at: indexPath.row) {
            // Configure Table View Cell
            cell.configure(withViewModel: viewModel)
        }

        return cell
    }

}

extension AddLocationViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let location = viewModel.location(at: indexPath.row) else { return }

        // Notify Delegate
        delegate?.controller(self, didAddLocation: location)

        // Pop View Controller From Navigation Stack
        navigationController?.popViewController(animated: true)
    }

}

extension AddLocationViewController: UISearchBarDelegate {

}
