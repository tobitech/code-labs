//
//  TripDetailUserListViewController.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/17/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class TripDetailUserListViewController: UIViewController {
    
    var viewModel: TripDetailUserListViewModel!
    var onDismiss: ((Bool)->())?
    var onAddUser: (() -> ())?
    var onOpenChat: ((TripMember) -> ())?
    var onOpenUser: ((TripMember) -> ())?
    
    private var didAnimate: Bool = false
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var bottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentView: UIView!
    @IBOutlet weak var addUserButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
        contentView.set(cornerRadius: 8)
        addUserButton.isUserInteractionEnabled = viewModel.isAdmin
        addUserButton.alpha = viewModel.isAdmin ? 1 : 0
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        didAnimate = true
        animateTable(tableView: tableView)
    }
    
    @IBAction func addMember(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.onAddUser?()
        })
    }
    
    @IBAction func close(_ sender: Any?) {
        dismiss(shouldPop: false)
    }
    
    private func dismiss(shouldPop: Bool) {
        dismiss(animated: true, completion: {
            self.onDismiss?(shouldPop)
        })
    }
    
    private func deleteUser(user: TripMember) {
        if user.userId == Helpers.userId {
            let alertController = UIAlertController.init(title: nil, message: "Are you sure you want to leave the trip?", preferredStyle: UI_USER_INTERFACE_IDIOM() == .pad ? .alert : .actionSheet)
            let leaveAction = UIAlertAction.init(title: "Leave", style: .destructive) { (_) in
                self.viewModel.leaveTheTrip()
                self.dismiss(shouldPop: true)
            }
            let cancel = UIAlertAction.init(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(leaveAction)
            alertController.addAction(cancel)
            present(alertController, animated: true, completion: nil)
        }else {
            viewModel?.deleteUserFromTrip(member: user)
            tableView.reloadData()
        }
    }
    
}

extension TripDetailUserListViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !didAnimate { return 0}
        return viewModel.members.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(TripDetailUserTableViewCell.self, for: indexPath)
        let user = viewModel.members.item(at: indexPath.row)
        cell.user = user
        cell.canDeleteUser = viewModel.isAdmin
        cell.isCurrentUser = user?.userId == Helpers.userId
        cell.onChatTapped = { [weak self] in
            self?.dismiss(animated: true, completion: {
                self?.onOpenChat?(user!)
            })
        }
        cell.onDeleteTapped = { [weak self] in
            self?.deleteUser(user: user!)
        }
        return cell
    }
    
}

extension TripDetailUserListViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let user = viewModel.members.item(at: indexPath.row)
        dismiss(animated: true) {
            self.onOpenUser?(user!)
        }
    }
    
}
