//
//  InviteByPhoneController.swift
//  Trajilis
//
//  Created by Moses on 24/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

class InviteByPhoneController: BaseVC {

    @IBOutlet fileprivate weak var tableView: UITableView!
    
    private let viewModel: IInviteViewModel = InviteViewModel()
    private var phones = [ByPhone]()
    private var toInvite = [ByPhone]() {
        didSet {
            selectionIsValid?(validate())
        }
    }
    
    var selectionIsValid: ((Bool)->())?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.delegate = self
        tableView.dataSource = self
        ByPhone.fetch(load)
    }
    
    private func load(_ phones: [ByPhone]) {
        self.phones = phones.sorted(by: {$0.name < $1.name})
        tableView.reloadData()
    }
    
    func validate() -> Bool {
        return !toInvite.isEmpty
    }

    func send() {
        guard let user = kAppDelegate.user, !toInvite.isEmpty else { showAlert(message: "Contacts not selected"); return }
        
        spinner(with: "One moment...", blockInteraction: true)
        Helpers.createDynamicLink(user: user, mode: .invite) { (url) in
            if let url = url {
                var request = JSONDictionary()
                request["phone_book"] = ByPhone.phoneStrings(self.toInvite)
                request["message"] = url.absoluteString
                
                guard let userId = UserDefaults.standard.value(forKey: USERID) as? String else { return }
                request["user_id"] = userId
                
                self.viewModel.invite(by: .inviteFriendsByPhoneNo(param: request)) { (stateModel) in
                    
                    switch stateModel.state {
                    case .loading: break
                    default:
                        self.hideSpinner()
                    }
                    
                    switch stateModel.state {
                    case .loading: break
                    case .error(let errorMessage):
                        self.showAlert(message: errorMessage)
                    case .noData(let message):
                        self.showAlert(message: message)
                    default:
                        break
                    }
                }
            }else {
                self.hideSpinner()
            }
        }
    }
    
    private func add(_ phone: ByPhone) {
        toInvite.append(phone)
    }
    
    private func remove(_ phone: ByPhone) {
        toInvite.removeAll(where: { $0 == phone })
    }
}

extension InviteByPhoneController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return phones.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ByPhoneCell.name) as! ByPhoneCell
        let phone = phones[indexPath.row]
        cell.phone = phone
        cell.addPhone = add
        cell.removePhone = remove
        cell.isPhoneSelected = toInvite.contains(phone)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

}


