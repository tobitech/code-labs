//
//  CurrencyViewController.swift
//  Trajilis
//
//  Created by Moses on 06/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class CurrencyViewController: UITableViewController {
    var currencies = [Currency]()
    var filtered = [Currency]()
    var selectCurrency : Currency?
    var selectedHandle : ((Currency) -> Void)?
    var previouseIndexPath : IndexPath?

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveCurrency))
        tableView.register(UINib.init(nibName: CurrencyCell.name, bundle: nil), forCellReuseIdentifier: CurrencyCell.name)
        fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Texts.selectCurrency
        showNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavigationBar()
    }
    
    fileprivate func handledToggle(_ index: IndexPath, currency: Currency, toggle: Bool) {
        
        if toggle {
            
            if let oldIndex = previouseIndexPath {
                let cell = tableView.cellForRow(at: oldIndex) as! CurrencyCell
                cell.off = true
            }
            
            self.selectCurrency = currency
            self.previouseIndexPath = index
        } else {
            self.selectCurrency = nil
            self.previouseIndexPath = nil
        }
    }
    
    @objc func saveCurrency() {
        if let currency = selectCurrency {
            selectedHandle?(currency)
        }
        navigationController?.popViewController(animated: true)
    }
    
    fileprivate func fetch() {
        
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else {
            return
        }
        
        MBProgressHUD.showAdded(to: self.view, animated: true).label.text = "One moment..."
        
        APIController.makeRequest(request: .getCurrencyList(userId: user.id)) { (response) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch response {
            case .failure(_):
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                let list = data.compactMap{ Currency.init($0) }
                self.currencies = list
                self.filtered = list
            }
            self.tableView.reloadData()
            
        }
    }
}

extension CurrencyViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return filtered.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CurrencyCell.name) as! CurrencyCell
        cell.indexPath = indexPath
        cell.currency = filtered[indexPath.row]
        cell.handle = handledToggle
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchbarView = SearchView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 44))
        searchbarView.searchBar.delegate = self
        return searchbarView
    }
}

extension CurrencyViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        search(text: searchText)
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
    
    fileprivate func search(text: String) {
        
        if text.isEmpty {
            filtered = currencies
            tableView.reloadData()
            return
        }
        
        filtered = currencies.filter { $0.countryName.lowercased().contains(text.lowercased()) }
        tableView.reloadData()
    }
}
