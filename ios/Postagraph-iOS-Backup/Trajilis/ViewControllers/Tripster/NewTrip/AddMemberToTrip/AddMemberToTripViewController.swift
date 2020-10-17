//
//  AddMemberToTripViewController.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/16/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

class AddMemberToTripViewController: UIViewController {
    
    var viewModel: AddMemberToTripViewModel!
    var onDone: (()->())?
    var onAdd: ((String)->())?
    var onRemove: ((String)->())?
    
    @IBOutlet weak var searchTextFieldContainer: UIView!
    @IBOutlet weak var searchIconImageView: UIImageView!
    @IBOutlet weak var searchTextField: UITextField!
    @IBOutlet weak var selectedMemberContainer: UIView!
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var addUserInstructionView: UIView!
    @IBOutlet weak var noSearchResultInstruction: UIStackView!
    @IBOutlet weak var addUserInstruction: UIStackView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var addUserInstructionLabel: UILabel!
    @IBOutlet weak var addUserInstruction2Label: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.delegate = self
        tableView.dataSource = self
        collectionView.dataSource = self
        
        searchTextField.delegate = self
        
        addUserInstructionLabel.text = viewModel.noMemberTitle
        addUserInstruction2Label.text = viewModel.noMemberSubtitle
        
        selectedMemberContainer.isHidden = viewModel.mode == .view || (viewModel.mode != .view && viewModel.selectedUsers.isEmpty)
        
        viewModel.searchUserComplete = { [weak self] text in
            self?.setupViews()
        }
        
        searchTextFieldContainer.set(borderWidth: 0.5, of: UIColor(hexString: "#e5e5e5"))
        search(text: "")
        
        if viewModel.mode == .forwardMessage {
            addBackButton()
        }
        
        selectedUser()
    }
    
    private func addBackButton() {
        let barButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .done, target: self, action: #selector(self.close))
        barButtonItem.imageInsets = UIEdgeInsets(top: -1.5, left: -8, bottom: 1.5, right: 8)
        barButtonItem.tintColor = UIColor(hexString: "#D63D41")
        navigationItem.leftBarButtonItem = barButtonItem
    }
    
    private func setupViews() {
        if self.viewModel.isSearching {
            if self.viewModel.searchUserResponse.isEmpty {
                self.tableView.isHidden = true
                self.addUserInstruction.isHidden = true
                self.addUserInstructionView.isHidden = false
                self.noSearchResultInstruction.isHidden = false
            }else {
                self.tableView.isHidden = false
                self.addUserInstructionView.isHidden = true
            }
            self.tableView.reloadData()
        }
    }
    
    private func search(text: String) {
        searchIconImageView.tintColor = text.isEmpty ? UIColor(hexString: "#e5e5e5") : UIColor(hexString: "#aeaeae")
        if text.isEmpty {
            if viewModel.selectedUsers.isEmpty {
                tableView.isHidden = true
                addUserInstruction.isHidden = false
                addUserInstructionView.isHidden = false
                noSearchResultInstruction.isHidden = true
            }else {
                addUserInstructionView.isHidden = true
                tableView.isHidden = false
                tableView.reloadData()
            }
        }else {
            addUserInstructionView.isHidden = true
            tableView.isHidden = false
        }
        viewModel.searchUser(searchParam: text)
    }
    
    private func selectedUser() {
        if viewModel.selectedUsers.isEmpty {
            navigationItem.rightBarButtonItem = nil
            selectedMemberContainer.isHidden = true
        }else {
            selectedMemberContainer.isHidden = false
            collectionView.reloadData()
            
            if viewModel.mode == .edit {
                let barButtonItem = UIBarButtonItem(image: UIImage(named: "backIcon"), style: .done, target: self, action: #selector(self.done))
                barButtonItem.imageInsets = UIEdgeInsets(top: -1.5, left: -8, bottom: 1.5, right: 8)
                barButtonItem.tintColor = UIColor(hexString: "#D63D41")
                navigationItem.leftBarButtonItem = barButtonItem
            } else if viewModel.mode == .add || viewModel.mode == .forwardMessage {
                let barButtonItem = UIBarButtonItem(image: UIImage(named: "check-mark"), style: .done, target: self, action: #selector(self.done))
                barButtonItem.tintColor = UIColor(hexString: "#20C361")
                navigationItem.rightBarButtonItem = barButtonItem
            }
        }
        
        if viewModel.allowEmpty {
            let barButtonItem = UIBarButtonItem(image: UIImage(named: "check-mark"), style: .done, target: self, action: #selector(self.done))
            barButtonItem.tintColor = UIColor(hexString: "#20C361")
            navigationItem.rightBarButtonItem = barButtonItem
        }
    }
    
    @objc private func close() {
        navigationController?.dismiss(animated: true, completion: nil)
    }
    
    @objc private func done() {
        if viewModel.mode == .forwardMessage {
            navigationController?.dismiss(animated: true, completion: nil)
        }else {
            navigationController?.popViewController(animated: true)
        }
        if !viewModel.selectedUsers.isEmpty || viewModel.allowEmpty {
            onDone?()
        }
    }

}

extension AddMemberToTripViewController: UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if viewModel.mode == .view {return}
        let add: Bool
        let user: CondensedUser?
        if viewModel.isSearching {
            user = viewModel.searchUserResponse.item(at: indexPath.row)
            add = viewModel.add(user: user)
            let cell = tableView.cellForRow(at: indexPath) as? AddMemberToTripTableViewCell
            cell?.userIsSelected = add
        }else {
            user = viewModel.selectedUsers.item(at: indexPath.row)
            add = viewModel.add(user: user)
            tableView.reloadData()
        }
        selectedUser()
        guard let userId = user?.userId else {return}
        if add {
            onAdd?(userId)
        }else {
            onRemove?(userId)
        }
    }
    
}

extension AddMemberToTripViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.isSearching ? viewModel.searchUserResponse.count : viewModel.selectedUsers.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeue(AddMemberToTripTableViewCell.self, for: indexPath)
        let user = viewModel.isSearching ? viewModel.searchUserResponse.item(at: indexPath.row) : viewModel.selectedUsers.item(at: indexPath.row)
        cell.user = user
        cell.selectedIndicatorImageView?.isHidden = viewModel.mode == .view
        cell.userIsSelected = viewModel.selectedUsers.contains(where: {
            return $0.userId == (user?.userId ?? "")
        })
        return cell
    }
    
}

extension AddMemberToTripViewController: UITextFieldDelegate {
    
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

extension AddMemberToTripViewController: UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return viewModel.selectedUsers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeue(AddMemberToTripCollectionViewCell.self, for: indexPath)
        let placeHolderImage = UIImage(named: "userAvatar")
        cell.imageView.image = placeHolderImage
        
        if let urlString = viewModel.selectedUsers.item(at: indexPath.row)?.userImage,
            let url = URL(string: urlString) {
            cell.imageView.sd_setImage(with: url, placeholderImage: placeHolderImage)
        }
        return cell
    }
    
}
