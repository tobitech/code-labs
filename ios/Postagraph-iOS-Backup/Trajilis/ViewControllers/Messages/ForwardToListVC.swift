//
//  ForwardToListVC
//  Trajilis
//
//  Created by Johnson Ejezie on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class ForwardToListVC: BaseVC {

    @IBOutlet weak var btnNext:UIButton!
    @IBOutlet weak var tableView:UITableView!
    
    var isSearching = false
    var viewModel = ForwardVCViewModel()
    let searchbarView = SearchView()
    
    var forwardToUsers:[String] = [String]()
        
    var messgeToForward:Message?
    
    var currentUser: CondensedUser!
    var pageOffSet:Int = 0
    
    @IBOutlet weak var titleView:HeaderWithLineView!
    @IBOutlet weak var cnstrntTitleViewHeight:NSLayoutConstraint!
    @IBOutlet weak var cnstrntTitleViewTop:NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.btnNext.isHidden = true
        setupNavBar()
        self.tableView.backgroundColor = UIColor.clear
        viewModel.reload = {
            self.hideSpinner()
            self.tableView.reloadData()
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        self.spinner(with: "Getting Users...", blockInteraction: true)
        self.viewModel.fetchUsers()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
        navigationItem.hidesBackButton = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationItem.hidesBackButton = false
    }
    
    private func setupNavBar() {
        navigationItem.title = nil
        navigationItem.largeTitleDisplayMode = .never
        
        let backBtn = UIBarButtonItem(image: UIImage.init(named: "back-white"), style: UIBarButtonItem.Style.plain, target: self, action: #selector(btnBackTapped))
        navigationItem.leftBarButtonItem = backBtn
        
    }
    
    @objc fileprivate func btnBackTapped() {
        self.dismiss(animated: true, completion: nil)
    }
    @IBAction func btnNextTapped(sender:UIButton) {

        guard let msg = self.messgeToForward, let sender = self.currentUser else  {
            return
        }
        
        if self.forwardToUsers.count > 0 {
            // create groups for new users
            let timestamp = NSDate().timeIntervalSince1970
            let c:String = String(format:"%.0f", timestamp)
            let selectedUsers = self.forwardToUsers.joined(separator: ",")
            let parameters = [
                "entity_id":selectedUsers,
                "parent_message_id":msg.messageId,
                "message_time_stamp":c,
                "user_id":sender.userId
            ]
            self.spinner(with: "Forwarding...",blockInteraction: true)
            APIController.makeRequest(request: .forwardMessage(param: parameters)) { [weak self](response) in
                if let strngSelf = self {
                    DispatchQueue.main.async {
                        strngSelf.hideSpinner()
                        switch response {
                        case .failure(_):
                            strngSelf.showAlert(message: "Unable to forward message at this time. Please try again later.")
                        case .success(let result):
                            guard let json = try? result.mapJSON() as? JSONDictionary,
                                let meta = json?["meta"] as? JSONDictionary,
                                let status = meta["status"] as? String else { return }
                            if status == "200" {
                                strngSelf.dismiss(animated: true, completion: nil)
                            } else {
                                strngSelf.showAlert(message: "Unable to forward message at this time. Please try again later")
                            }
                        }
                    }
                }
            }
        } else {
            self.showAlert(message: "Please select users to forward message.")
        }
     
    }
}

extension ForwardToListVC:UITableViewDataSource,UITableViewDelegate {
   
    func getArrayOfUsers() -> [ForwardUser] {
        if isSearching {
            return self.viewModel.searchedUsers
        }
        return self.viewModel.allUsers
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return isSearching ? viewModel.searchedUsers.count : viewModel.allUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: PGForwardMsgCell.identifer) as! PGForwardMsgCell
        let arrayOfUsers = self.getArrayOfUsers()
        if arrayOfUsers.count > indexPath.row {
            let user = arrayOfUsers[indexPath.row]
            cell.imgCheckBox.isHidden = true
            if forwardToUsers.contains(user.entity_id){
                cell.imgCheckBox.isHidden = false
            }
            cell.lblName.text = user.entity_name
            if let url = URL(string: user.entity_image) {
                cell.imgView.sd_setImage(with: url, completed: nil)
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let arrayOfUsers = self.getArrayOfUsers()
        if arrayOfUsers.count > indexPath.row {
            let user = arrayOfUsers[indexPath.row]
            if let index = self.forwardToUsers.firstIndex(of: user.entity_id) {
                self.forwardToUsers.remove(at: index)
            } else {
                self.forwardToUsers.append(user.entity_id)
            }
            tableView.reloadRows(at: [indexPath], with: .fade)
        }
        if self.forwardToUsers.count > 0 {
            self.btnNext.isHidden = false
        } else {
            self.btnNext.isHidden = false
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 70
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        searchbarView.frame = CGRect.init(x: 0, y: 0, width: tableView.bounds.width, height: 44)
        searchbarView.searchBar.delegate = self
        return searchbarView
    }
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if self.tableView.contentOffset.y >= self.tableView.contentSize.height - self.tableView.frame.size.height {
            self.viewModel.fetchUsers()
        }
    }
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        if self.tableView.contentOffset.y <= (self.cnstrntTitleViewHeight.constant - 10) {
            navigationItem.title = nil
            self.cnstrntTitleViewTop.constant = -self.tableView.contentOffset.y
            print("---- \(self.tableView.contentOffset.y)")
        } else {
            self.cnstrntTitleViewTop.constant = -self.cnstrntTitleViewHeight.constant
            navigationItem.title = "Forward To"
        }
    }
}

extension ForwardToListVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        isSearching = !searchText.isEmpty
        if isSearching {
            viewModel.search(text: searchText)
        } else {
            self.tableView.reloadData()
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
        isSearching = false
        self.tableView.reloadData()
    }
}

class PGForwardMsgCell : UITableViewCell {
    
    @IBOutlet weak var imgView:UIImageView!
    @IBOutlet weak var lblName:UILabel!
    @IBOutlet weak var viewSeparator:UIView!
    @IBOutlet var imgCheckBox: UIImageView!
    static let identifer = "PGForwardMsgCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        viewSeparator.backgroundColor = UIColor.appRed
        self.backgroundColor = UIColor.clear
        self.contentView.backgroundColor = UIColor.clear
        self.imgView.makeRounded()
        self.imgView.layer.borderColor = UIColor.appRed.cgColor
        self.imgView.layer.borderWidth = 1
        // Initialization code
    }

}
