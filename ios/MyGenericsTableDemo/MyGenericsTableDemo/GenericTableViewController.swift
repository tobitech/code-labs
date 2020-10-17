//
//  ViewController.swift
//  MyGenericsTableDemo
//
//  Created by Oluwatobi Omotayo on 02/07/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

class GenericTableViewController<T: GenericCell<U>, U>: UITableViewController {
    
    let cellId = "cellId"
    
    var items = [U]()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(T.self, forCellReuseIdentifier: cellId)
        
        tableView.tableFooterView = UIView()
        let rc = UIRefreshControl()
        rc.addTarget(self, action: #selector(handleRefresh), for: .valueChanged)
        tableView.refreshControl = rc
        
    }
    
    @objc func handleRefresh() {
        tableView.refreshControl?.endRefreshing()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! GenericCell<U>
        cell.item = items[indexPath.row]
        
        return cell
    }


}



class GenericCell<U>: UITableViewCell {
    var item: U!
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
}










