//
//  SearchFriendVCViewController.swift
//  Trajilis
//
//  Created by user on 17/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class SearchFriendVC: BaseVC {
    
    //Outlets
    @IBOutlet weak var tableView: UITableView!
    
    //Mar: Properties
    let headerView = SearchFriendTopView.fromNib()
    let viewModel = SearchViewModel()
    var isSearching = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        MBProgressHUD.showCustomHud(to: view, animated: true).label.text = "One moment..."
        setupCompletionHandler()

    }
    
    fileprivate func search(text: String) {
//        viewModel.searchUsers(searchParam: text)
    }
    
    
    private func setupCompletionHandler() {
        
//        viewModel.userSearchComplete = {message in
//            MBProgressHUD.hide(for: self.view, animated: true)
//            if let msg = message {
//                self.showAlert(message: msg)
//            }else {
//                //TODO Reload tableview
//            }
//        }
//        
//        viewModel.getSuggestionComplete = { message in
//            MBProgressHUD.hide(for: self.view, animated: true)
//            if let msg = message {
//                self.showAlert(message: msg)
//            }else {
//                //TODO Reload tableview
//            }
//        }
    }

    private func setupTableView() {
        tableView.tableHeaderView = headerView
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(UINib.init(nibName: "SearchFriendTableViewCell", bundle: nil), forCellReuseIdentifier: "SearchFriendTableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    @IBAction func backBtnPressed( _ sender: UIButton) {
        self.navigationController?.popViewController(animated: true)
    }
    
}

extension SearchFriendVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "SearchFriendTableViewCell", for: indexPath) as! SearchFriendTableViewCell
        cell.user = viewModel.users[indexPath.row]
        
        return cell
    }
    
    
}


extension SearchFriendVC {
    
    private func hideSuggestionLbl() {
        headerView.suggestedBtn.isHidden = true
    }
    
    private func showSuggestionLbl() {
        headerView.suggestedBtn.isHidden = false
    }
}


extension SearchFriendVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = !searchText.isEmpty
        search(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
    }
}
