//
//  FollowViewController.swift
//  Trajilis
//
//  Created by Moses on 23/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class FollowViewController: UITableViewController {
    
    let  provider : IFollowDataProvider = FollowDataProvider()
    let viewModel : IFollowViewModel = FollowViewModel()
    var type : FollowType!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        provider.controller = self
        tableView.delegate = provider
        tableView.dataSource = provider
        tableView.register(UINib.init(nibName: FollowCell.name, bundle: nil ), forCellReuseIdentifier: FollowCell.name)
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if type == FollowType.following {
            title = Texts.following
        } else {
            title = Texts.follower
        }
        
        showNavigationBar()
        
        provider.type = type
        provider.scrollDidHitBottom = { self.load($0) }
        provider.set =  set
        load(0)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavigationBar()
    }
    
    fileprivate func set(_ follow: Followers, row: IndexPath) {
        
        var typ : FollowType!
        
        if type == .follower {
            typ = FollowType.following
        } else if type == .following {
            typ = FollowType.follower
        }
        
        viewModel.follow(by: typ, id: follow.userId, render: { stateModel in
            
            switch stateModel.state {
            case .dataLoaded(let data , _):
                if data {
                    self.provider.temp.remove(at: row.row)
                    self.provider.followers = self.provider.temp
                    self.tableView.reloadData()
                }
            default:
                break
            }
        })
        
    }

    fileprivate func load(_ count: Int) {
        
        viewModel.getFollow(by: type, count: count) { (stateModel) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch stateModel.state {
            case .loading:
                MBProgressHUD.showAdded(to: self.view, animated: true).label.text = "One moment..."
            case .error(let errorMessage):
                self.showAlert(message: errorMessage)
            case .noData(let message):
                print(message)
            case .dataLoaded(let data, _):
                self.provider.followers = self.provider.temp + data.list
                self.provider.temp = self.provider.temp + data.list
                self.tableView.reloadData()
                break
            }
        }
    }
}

protocol IFollowDataProvider : UITableViewDataSource, UITableViewDelegate {
    var temp: [Followers] { get set }
    var followers: [Followers] { get set }
    var set: ((Followers, IndexPath) -> Void)? { get set }
    var scrollDidHitBottom: ((Int) -> Void)? { get set }
    var type : FollowType! { get set }
    var controller : FollowViewController! { get set }
    
}

class FollowDataProvider: NSObject, IFollowDataProvider {
    var followers = [Followers]()
    var temp = [Followers]()
    var set: ((Followers, IndexPath) -> Void)?
    var scrollDidHitBottom: ((Int) -> Void)?
    var count = 1
    var lastIndex: IndexPath?
    var type: FollowType!
    var controller: FollowViewController!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return followers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.name) as! FollowCell
        cell.follow = followers[indexPath.row]
        cell.indexPath = indexPath
        cell.set = self.set
        cell.type = self.type
        self.lastIndex = indexPath
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }
    
    func tableView(_ tableView: UITableView, shouldHighlightRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let searchbarView = SearchView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 44))
        searchbarView.searchBar.delegate = controller
        return searchbarView
    }

    func scrollViewWillBeginDecelerating(_ scrollView: UIScrollView) {
        print(lastIndex!.row)
        print(temp.count - 1 )
        if let index = lastIndex, index.row == temp.count - 1 {
            scrollDidHitBottom?(count * 50)
            count += 1
        }
    }
}



extension FollowViewController : UISearchBarDelegate {
    
    func searchBarTextDidEndEditing(_ searchBar: UISearchBar) {
        searchBar.text = ""
        provider.followers = provider.temp
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String)
    {
        searchProducts(searchText)
    }
    
    func searchProducts(_ userInput: String) {
        
        if userInput.isEmpty {
            provider.followers = provider.temp
            tableView.reloadData()
            return
        }
        
        let terms = userInput.components(separatedBy: CharacterSet.whitespaces)
        var searchPredicates = [NSPredicate]()
        
        for term in terms {
            if term.isEmpty  {continue}
            searchPredicates.append(NSPredicate(format: "self.name contains[c] %@", userInput))
        }
        
        let compoundPredicate = NSCompoundPredicate(orPredicateWithSubpredicates: searchPredicates)
        let emptyPredicate = NSPredicate(format: "1 == 1")
        let predicate = userInput.isEmpty ? emptyPredicate : compoundPredicate
        
        let filtered = (provider.temp as NSArray).filtered(using: predicate)
        provider.followers = filtered as! [Followers]
        tableView.reloadData()
    }
}
