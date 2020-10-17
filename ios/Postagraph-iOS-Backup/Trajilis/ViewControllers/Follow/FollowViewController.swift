//
//  FollowTableViewController.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 10/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FollowViewController: BaseVC {

    var viewModel: FollowViewModel!
    var onDone: (()->())?
    var isFullScreen: Bool = true

    private var searchBarView: SearchView!
    private var shouldUpdate:Bool  = false
    private var didAnimate: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var tableViewTopConstraint: NSLayoutConstraint!
    @IBOutlet weak var searchTextFieldContainer: UIView!
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = viewModel.title
        titleLabel.text = viewModel.title
        tableView.tableFooterView = UIView(frame: .zero)
        titleLabel.superview?.isHidden = isFullScreen
        tableViewTopConstraint.constant = isFullScreen ? 0 : 150
        
        searchTextField.delegate = self
        searchTextField.placeholder = viewModel.searchPlaceHolderText
        
        viewModel.reload = { [weak self] in
            guard let self = self else { return }
            if self.didAnimate {
                self.tableView.reloadData()
            } else {
                self.didAnimate = true
                self.animateTable(tableView: self.tableView)
            }
        }
        searchTextFieldContainer.set(borderWidth: 0.5, of: UIColor(hexString: "#e5e5e5"))
        addRightBarButtonItem()
        navigationController?.navigationBar.barTintColor = UIColor.appRed
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
        if self.shouldUpdate {
            self.shouldUpdate = false
            self.viewModel.loadData()
        }
    }

    private func addRightBarButtonItem() {
        switch viewModel.type! {
        case .friend:
            let inviteFriendBarItem = UIBarButtonItem(image: UIImage.init(named: "create-group-white"), style: .plain, target: self, action: #selector(gotoInviteFriends))
            navigationItem.rightBarButtonItem = inviteFriendBarItem
        default:
            break
        }
    }

    @objc private func gotoInviteFriends() {
        let controller = InviteContainerController.instantiate(fromAppStoryboard: .invite)
        navigationController?.pushViewController(controller, animated: true)
    }

    fileprivate func followOrUnfollow(user: Followers, indexPath: IndexPath) {
        if user.status { //unfollow
            unfollowWarning(user: user, indexPath: indexPath)
        } else { //follow
            viewModel.follow(follower: user)
            tableView.reloadRows(at: [indexPath], with: .automatic)
        }
    }

    private func unfollowWarning(user: Followers, indexPath: IndexPath) {
        let alertController = UIAlertController(title: nil, message: "Are you sure you want to unfollow the user?", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { (_) in
            let delete = self.viewModel.follow(follower: user)
            switch self.viewModel.type! {
            case .friend:
                self.tableView.reloadData()
            default:
                if delete {
                    self.tableView.deleteRows(at: [indexPath], with: .automatic)
                }else {
                    self.tableView.reloadRows(at: [indexPath], with: .automatic)
                }
            }
        }

        let cancel = UIAlertAction(title: "Cancel", style: .default, handler: nil)

        alertController.addAction(cancel)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }

    fileprivate func search(text: String) {
        viewModel.isSearching = !text.isEmpty
        tableView.reloadData()
        searchIconImageView.tintColor = text.isEmpty ? UIColor(hexString: "#e5e5e5") : UIColor(hexString: "#aeaeae")
        viewModel.search(text: text)
    }

    @IBAction func closeTapped(_ sender: Any) {
        onDone?()
        dismiss(animated: true, completion: nil)
    }
    
}

extension FollowViewController: UITableViewDataSource, UITableViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if viewModel.isSearching && !viewModel.type.isRemoteSearch { return }
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            if let indexPath = visibleIndexPath.first {
                if (viewModel.followers.count - indexPath.row) == 5 && !viewModel.isLastContent {
                    viewModel.loadData(isLoadingMore: true)
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch viewModel.type! {
        case .friend:
            if viewModel.isSearching {
                return viewModel.followers.count
            } else {
                return !viewModel.isSearching ? viewModel.followers.count : viewModel.filteredFollowers.count
            }
        default:
            return !viewModel.isSearching ? viewModel.followers.count : viewModel.filteredFollowers.count
        }
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(FollowTableViewCell.self, for: indexPath)
        let follow: Followers!
        switch viewModel.type! {
        case .friend:
            if viewModel.isSearching {
                follow = viewModel.followers[indexPath.row]
            } else {
                follow = viewModel.isSearching ? viewModel.filteredFollowers[indexPath.row] :  viewModel.followers[indexPath.row]
            }
        default:
            follow = viewModel.isSearching ? viewModel.filteredFollowers[indexPath.row] :  viewModel.followers[indexPath.row]
        }

        cell.user = follow
        cell.followOrUnfollow = {
            self.followOrUnfollow(user: follow, indexPath: indexPath)
        }
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let follow: Followers!
        switch viewModel.type! {
        case .friend:
            if viewModel.isSearching {
                follow = viewModel.followers[indexPath.row]
            } else {
                follow = viewModel.isSearching ? viewModel.filteredFollowers[indexPath.row] :  viewModel.followers[indexPath.row]
            }
        default:
            follow = viewModel.isSearching ? viewModel.filteredFollowers[indexPath.row] :  viewModel.followers[indexPath.row]
        }

        let controller: ProfileViewController = Router.get()
        let vModel = ProfileViewModel(userId: follow.userId)
        controller.viewModel = vModel
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
        self.shouldUpdate = true
    }

}

extension FollowViewController: UITextFieldDelegate {
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
        search(text: newText)
        return true
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        search(text: textField.text!)
    }
    
    func textFieldShouldClear(_ textField: UITextField) -> Bool {
        search(text: "")
        return true
    }
    
}
