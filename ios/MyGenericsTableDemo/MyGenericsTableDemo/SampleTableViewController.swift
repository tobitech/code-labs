//
//  SampleTableViewController.swift
//  MyGenericsTableDemo
//
//  Created by Oluwatobi Omotayo on 02/07/2018.
//  Copyright © 2018 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

class BaseTableViewController<T: BaseCell<U>, U>: UITableViewController {
    
    let cellId = "cellId"
    
    var items = [U]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.register(T.self, forCellReuseIdentifier: cellId)
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! BaseCell<U>
        
        cell.item = self.items[indexPath.row]
        
        return cell
    }
    
}

class BaseCell<U>: UITableViewCell {
    var item: U!
}



class SomeListController: BaseTableViewController<DogCell, Dog> {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        items = [
            Dog(name: "Woof Woof"),
            Dog(name: "Ruff Ruff Ruff")
        ]
    }
}


struct Dog {
    let name: String
}

class DogCell: BaseCell<Dog> {
    override var item: Dog! {
        didSet {
            textLabel?.text = item.name
        }
    }
}





