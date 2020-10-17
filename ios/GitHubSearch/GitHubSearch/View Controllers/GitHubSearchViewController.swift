//
//  GitHubSearchViewController.swift
//  GitHubSearch
//
//  Created by Oluwatobi Omotayo on 18/05/2020.
//  Copyright © 2020 Oluwatobi Omotayo. All rights reserved.
//

import UIKit
import RxSwift

class GitHubSearchViewController: UIViewController {
    
    var viewModel = GitHubSearchViewModel()
    let disposeBag = DisposeBag()
    
    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    @IBOutlet var errorLabel: UILabel!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        configureViewModel()
        setupObservables()
    }
    
    func configureViewModel() {
        let searchObservable = searchBar.rx.text
            .orEmpty
            .throttle(.milliseconds(500), scheduler: MainScheduler.instance).distinctUntilChanged()
        viewModel.configure(search: searchObservable)
    }
    
    func setupObservables() {
        disposeBag.insert(
            viewModel.data
                .bind(to: tableView.rx.items(cellIdentifier: "Cell")) { index, repository, cell in
                    cell.textLabel?.text = repository.name
                    cell.detailTextLabel?.text = repository.url
            },
            viewModel.error
                .bind(to: errorLabel.rx.text),
            viewModel.error
                .map { $0 == nil }
                .bind(to: errorLabel.rx.isHidden),
            viewModel.processing
                .bind(to: activityIndicator.rx.isAnimating)
        )
    }
}

