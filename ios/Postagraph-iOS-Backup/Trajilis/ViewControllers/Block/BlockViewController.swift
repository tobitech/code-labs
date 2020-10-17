//
//  BlockViewController.swift
//  Trajilis
//
//  Created by Moses on 08/12/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class BlockViewController: UITableViewController {
    var users = [User]()
    var count : ((Int) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.register(UINib.init(nibName: BlockCell.name, bundle: nil), forCellReuseIdentifier: BlockCell.name)
        self.tableView.separatorStyle = .none
        fetch()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = Texts.blockedUser
        showNavigationBar()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        hideNavigationBar()
        count?(users.count)
    }
    
    
    fileprivate func fetch() {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else {
            return
        }
        
        MBProgressHUD.showCustomHud(to: self.view, animated: true).label.text = "One moment..."
        
        APIController.makeRequest(request: .getBlockedUsers(userId: user.id)) { (response) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch response {
            case .failure(_):
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let data = json?["data"] as? [JSONDictionary] else { return }
                let list = data.compactMap{ User.init(json:$0) }
                self.users = list
            }
            self.tableView.reloadData()
            
        }
    }
    
    fileprivate func unBlockUser (with blockUser: User, index: IndexPath) {
        
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else {
            return
        }
        
        MBProgressHUD.showCustomHud(to: self.view, animated: true).label.text = "One moment..."
        
        APIController.makeRequest(request: .unblockUser(userId: user.id, unblockUserId: blockUser.id)) { (response) in
            
            MBProgressHUD.hide(for: self.view, animated: true)
            
            switch response {
            case .failure(_):
                break
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                let meta = json?["meta"] as? JSONDictionary else { return }
                if let status = meta["status"] as? String, status == "200" {
                    self.users.remove(at: index.row)
                }
                
                if let message = meta["message"] as? String {
                    self.showAlert(message: message)
                }
            }
            self.tableView.reloadData()
        }
    }
}


extension BlockViewController {
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: BlockCell.name) as! BlockCell
        cell.indexPath = indexPath
        cell.user = users[indexPath.row]
        cell.event = unBlockUser
        return cell
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 85
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
}
