//
//  CreateGroupVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 20/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit
import MobileCoreServices
import SDWebImage

final class CreateGroupVC: BaseVC {
    
    weak var chatVC:ChatViewController?
    
    @IBOutlet var groupImageView: UIImageView!
    @IBOutlet var collectionViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var tableView: UITableView!
    @IBOutlet var collectionView: UICollectionView!
    @IBOutlet var nameTextField: UITextField!
    
    var chatContact:ChatContact?
    var image: UIImage?
    
    var isImageChanged:Bool = false
    
    var users = [Followers]()
    var isEditMode:Bool = false
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        return imagePicker
    }()
    
    
    var selectedUsers = [CondensedUser]() {
        didSet {
           if selectedUsers.isEmpty {
                UIView.animate(withDuration: 0.1) {
                    self.collectionViewHeightConstraint.constant = 0
                }
            } else {
                UIView.animate(withDuration: 0.1) {
                    self.collectionViewHeightConstraint.constant = 80
                    self.collectionView.reloadData()
                }
            }
            
        }
    }

    var searchText: String = "" {
        didSet {
            NSObject.cancelPreviousPerformRequests(withTarget: self, selector: #selector(search), object: nil)
            perform(#selector(search), with: nil, afterDelay: 0.75)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        self.image = nil
        self.groupImageView.sd_setImage(with: nil, completed: nil)
        if let chatContact = self.chatContact {
            navigationItem.title = chatContact.groupName
            self.fillWithGroup(group: chatContact)
            if isEditMode {
                let nextButton = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(saveTapped))
                navigationItem.rightBarButtonItem = nextButton
            }
        } else {
            navigationItem.title = "Create Group"
            let nextButton = UIBarButtonItem(title: "Next", style: .plain, target: self, action: #selector(nextTapped))
            navigationItem.rightBarButtonItem = nextButton
        }
        
        tableView.backgroundColor = .clear
        tableView.register(UINib.init(nibName: FollowCell.name, bundle: nil), forCellReuseIdentifier: FollowCell.name)
        tableView.register(UINib.init(nibName: MessageTableViewCell.identifier, bundle: nil), forCellReuseIdentifier: MessageTableViewCell.identifier)
    }
    
    func fillWithGroup(group:ChatContact) {
        self.nameTextField.text = group.groupName
        
        if(!isEditMode) {
            self.groupImageView.isUserInteractionEnabled = false
            self.nameTextField.isUserInteractionEnabled = false
        } else {
            self.selectedUsers.append(contentsOf: group.members)
        }
        if let url = URL(string: group.groupImage) {
            self.groupImageView.sd_imageIndicator = SDWebImageActivityIndicator.gray
            self.groupImageView.sd_setImage(with: url) { (img, error, type, url) in
                self.image = img
            }
        }        
        self.tableView.register(MessageTableViewCell.classForCoder(), forCellReuseIdentifier:MessageTableViewCell.identifier)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        groupImageView.makeRounded()
        groupImageView.layer.cornerRadius = groupImageView.bounds.height/2
        groupImageView.layer.masksToBounds = true
        groupImageView.layer.borderColor = UIColor.appRed.cgColor
        groupImageView.layer.borderWidth = 1
        
        nameTextField.layer.cornerRadius = nameTextField.bounds.height/2
        nameTextField.layer.masksToBounds = true
        nameTextField.layer.borderColor = UIColor.appRed.cgColor
        nameTextField.layer.borderWidth = 1
    }

    @objc fileprivate func search() {
        if searchText.isEmpty  { return }
        APIController.makeRequest(request: .searchExplorer(searchParam: searchText, count: 0, limit: 1000)) { (response) in
            DispatchQueue.main.async {
                switch response {
                case .failure(_):
                    break
                case .success(let result):
                    guard let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? [JSONDictionary] else { return }
                    self.users = data.compactMap{ Followers.init(json: $0) }
                    self.tableView.reloadData()
                }
            }

        }

    }
    @objc private func saveTapped() {
        guard  let group = self.chatContact else {
            return
        }
        
        guard let text = nameTextField.text else { return }
        if text.isEmpty {
            showAlert(message: "Group name is required.")
            return
        }
        
        
        if self.selectedUsers.count > 0 {
            
            var isNameChanged = false
            
           
            var userAdded = [CondensedUser]()
            
            var memberToDelete = group.members.map({ $0.userId })
            
            for user in self.selectedUsers {
                // if already present in members
                let index = group.members.firstIndex { (member) -> Bool in
                    if member.userId == user.userId {
                        return true
                    }
                    return false
                }
                if index != nil {
                    if let indexInDelete = memberToDelete.firstIndex(of: user.userId) {
                        memberToDelete.remove(at: indexInDelete)
                    }
                } else {
                    userAdded.append(user)
                }
            }
            
            if text != group.groupName {
                isNameChanged = true
            }
            
            var isMemberDeleted = false
            if memberToDelete.count > 0 {
                isMemberDeleted = true
            }
            var isMemberAdded = false
            if userAdded.count > 0 {
                isMemberAdded = true
            }
            
 
            
            if isNameChanged || isMemberDeleted || isMemberAdded || self.isImageChanged {
                
                self.spinner(with: "Updating...", blockInteraction: true)
                let apiGroup = DispatchGroup()
                var isNameChangeSuccess = true
                if isNameChanged {
                    apiGroup.enter()
                    self.makeUpdateGroupNameCall(grpId: group.groupId, group_name: text) { (success) in
                        isNameChangeSuccess = success
                        apiGroup.leave()
                    }
                }
                
                
                var isMemberUpdateSuccess = true
                if isMemberDeleted || isMemberAdded {
                    apiGroup.enter()
                    self.makeManageGroupCall(grpId:group.groupId,deletedUser: memberToDelete, addedUsers: userAdded, onCompletion: { (success) in
                        isMemberUpdateSuccess = success
                        apiGroup.leave()
                    })
                }
                
                var isImageUpdateSuccess = true
                
                
                if self.isImageChanged {
                    apiGroup.enter()
                    if let image = self.image {
                        Helpers.uploadToS3(image: image) { (url, _) in
                            if let url = url,url.count > 0 {
                                self.makeImageUpdateCall(grpId: group.groupId, strURL: url, onCompletion: { (success) in
                                    isImageUpdateSuccess = success
                                    group.groupImage = url
                                    apiGroup.leave()
                                })
                            } else {
                                apiGroup.leave()
                                isImageUpdateSuccess = false
                            }
                        }
                    } else {
                        self.makeImageUpdateCall(grpId: group.groupId, strURL: "", onCompletion: { (success) in
                            isImageUpdateSuccess = success
                            group.groupImage = ""
                            apiGroup.leave()
                        })
                    }
                }
                
                
                apiGroup.notify(queue: .main) {
                    self.hideSpinner()
                    var msg = ""
                    if !isNameChangeSuccess {
                        msg = "Unable to change name of the group."
                    } else {
                        group.groupName = text
                    }
                    if !isMemberUpdateSuccess {
                        if msg.count > 0 {
                            msg = msg + " " + "Unable to update members of the group."
                        } else {
                            msg = "Unable to update members of the group."
                        }
                    } else {
                        group.members = self.selectedUsers
                    }
                    if !isImageUpdateSuccess {
                        if msg.count > 0 {
                            msg = msg + " " + "Unable to update image of the group."
                        } else {
                            msg = "Unable to update image of the group."
                        }
                    }
                    if msg.count > 0 {
                        self.showAlert(message: msg)
                    }
                    self.chatVC?.updateGroup(group: group)
                    SocketIOManager.shared.msgVC?.viewModel.refresh()
                    self.navigationController?.popViewController(animated: true)
                }
                
            } else {
                showAlert(message: "Please make some change to save.")
            }
        } else {
            showAlert(message: "Please select group members.")
        }
    }
    private func makeUpdateGroupNameCall(grpId:String,group_name:String,onCompletion:@escaping (Bool)->Void) {
        
        let userId = UserDefaults.standard.value(forKey: USERID) as! String
        
        APIController.makeRequest(request: .updateGroupName(userId:userId,groupId:grpId,groupName:group_name)) {(response) in
            switch response {
            case .failure( _):
                onCompletion(false)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else { return }
                if let status = meta["status"] as? String, status == "200" {
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
            }
        }
        
    }
    private func makeImageUpdateCall(grpId:String,strURL:String,onCompletion:@escaping (Bool)->Void) {
       
        let parameters = [
            "group_id":grpId,
            "group_image":strURL,
            "user_id":UserDefaults.standard.value(forKey: USERID) as! NSString
            ] as JSONDictionary
        
        APIController.makeRequest(request: .updateGroupImage(param: parameters)) {(response) in
            switch response {
            case .failure( _):
                onCompletion(false)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else { return }
                if let status = meta["status"] as? String, status == "200" {
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
            }
        }
        
    }
    private func makeManageGroupCall(grpId:String,deletedUser:[String],addedUsers:[CondensedUser],onCompletion:@escaping (Bool)->Void) {
        var deleteParam = [AnyObject]()
        var addedParam = [AnyObject]()
        if deletedUser.count > 0 {
            for id in deletedUser {
                let users = self.selectedUsers.filter { (usr) -> Bool in
                    if usr.userId == id {
                        return true
                    }
                    return false
                }
                if let user = users.first {
                    let prm = ["user_id":user.userId,
                               "user_image":user.userImage,
                               "user_name":user.username
                    ]
                    deleteParam.append(prm as AnyObject)
                }
            }
        }
        for user in addedUsers {
            let prm = ["user_id":user.userId,
                       "user_image":user.userImage,
                       "user_name":user.username
            ]
            addedParam.append(prm as AnyObject)
        }
        let parameters = [
            "group_id":grpId,
            "joine_member_list":addedParam,
            "remove_member_list":deleteParam,
            "user_id":UserDefaults.standard.value(forKey: USERID) as! NSString
            ] as JSONDictionary
        
        APIController.makeRequest(request: .manageGroup(param: parameters)) {(response) in
            switch response {
            case .failure( _):
                onCompletion(false)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else { return }
                if let status = meta["status"] as? String, status == "200" {
                    onCompletion(true)
                } else {
                    onCompletion(false)
                }
            }
        }
        
    }
    @objc private func nextTapped() {
        guard let text = nameTextField.text else { return }
        if text.isEmpty {
            showAlert(message: "Group name is required.")
            return
        }
        if selectedUsers.count > 0 {
            self.spinner(with: "Creating Group...",blockInteraction:true)
            if let image = self.image {
                Helpers.uploadToS3(image: image) { (url, _) in
                    DispatchQueue.main.async {
                        self.createGroupWithImage(url: url ?? "")
                    }
                }
            } else {
                createGroupWithImage(url: "")
            }
        } else {
            showAlert(message: "Please search & add at least one member to the group.")
        }
    }

    private func createGroupWithImage(url: String) {
        guard let grpName = self.nameTextField.text else {
            self.hideSpinner()
            showAlert(message: "Group name is required.")
            return
        }
        
        let grpMembers = members()
        if grpMembers.count > 1 {
           
            let param = [
                "group_image": url,
                "group_members": grpMembers,
                "group_name":grpName,
                "user_id": UserDefaults.standard.value(forKey: USERID) as! NSString
                ] as JSONDictionary
            
            APIController.makeRequest(request: .createGroup(param: param)) { [weak self](response) in
                DispatchQueue.main.async {
                    self?.hideSpinner()
                    switch response {
                    case .failure(let e):
                        self?.showAlert(message: e.desc)
                    case .success(let result):
                        guard let json = try? result.mapJSON() as? JSONDictionary else {
                            print("failed")
                            return
                        }
                        if let data = json?["data"] as? JSONDictionary  {
                            guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
                            let group = ChatContact.init(json: data)
                            if group.groupId.count > 0 {
                                let controller = ChatViewController.instantiate(fromAppStoryboard: .message)
                                controller.chatContact = group
                                controller.currentUser = user.condensedUser
                                controller.hidesBottomBarWhenPushed = true
                                self?.navigationController?.pushViewController(controller, animated: true)
                                SocketIOManager.shared.msgVC?.viewModel.refresh()
                            }  else {
                                self?.showAlert(message: "Unable to create group at this time. Please try again later")
                            }
                        }
                        break
                    }
                }
            }
        } else {
            self.hideSpinner()
            showAlert(message: "Please select group members.")
            return
        }
        
    }

    private func members() -> [JSONDictionary] {
        if selectedUsers.isEmpty { return [[:]] }
        var members = [JSONDictionary]()
        for user in selectedUsers {
            members.append([
                "user_id": user.userId,
                "user_image": user.userImage,
                "user_name": user.username
            ])
        }
        if let user = (UIApplication.shared.delegate as? AppDelegate)?.user {
            members.append([
                "user_id": user.id,
                "user_image": user.profileImage,
                "user_name": user.username
                ])
        }
        return members
    }

    @IBAction func selectImageTapped(_ sender: Any) {
        if self.chatContact == nil || isEditMode  {
            
            let alertController = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
            alertController.view.tintColor = UIColor.black
            
            
            let cameraPhotoAction = UIAlertAction(title: "Open Camera", style: .default) { (action:UIAlertAction) in
                self.openCamera(isCamera: true)
            }
            let library = UIAlertAction(title: "Photo Library", style: .default) { (action:UIAlertAction) in
                self.openCamera(isCamera: false)
            }
            let remove = UIAlertAction(title: "Remove Group Image", style: .default) { (action:UIAlertAction) in
                self.image = nil
                self.groupImageView.sd_setImage(with: nil, completed: nil)
                self.isImageChanged = true
            }
            
            let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
            
            alertController.addAction(cameraPhotoAction)
            alertController.addAction(library)
            if self.image != nil {
                alertController.addAction(remove)
            }
            alertController.addAction(cancel)
            
            self.present(alertController, animated: true, completion: nil)
        }
    }
    fileprivate func openCamera(isCamera:Bool) {
        if isCamera {
            let controller = CameraVC.instantiate(fromAppStoryboard: .video)
            controller.recordType = .simpleCamera
            controller.cameraMode = .Image
            let navController = UINavigationController(rootViewController: controller)
            navController.isNavigationBarHidden = true
            
            controller.didCaptureImage = {[weak self] (image,error) in
                if let img = image {
                    self?.groupImageView.image = img
                    self?.image = img
                    self?.isImageChanged = true
                } else {
                    self?.showAlert(message: "App is not able to take picture right now. Please try again later.")
                }
            }
            self.present(navController, animated: true, completion: nil)
        } else {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .photoLibrary
            imagePicker.mediaTypes = [kUTTypeImage as String]
            present(imagePicker, animated: true, completion: nil)
        }
    }
}

extension CreateGroupVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
       if mediaType as! String == kUTTypeImage as String {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                groupImageView.image = image
                self.image = image
                self.isImageChanged = true
            }
        }
        dismiss(animated: true, completion: nil)
    }
}


extension CreateGroupVC: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let group = self.chatContact,!isEditMode {
            return group.members.count
        }
        return users.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        if let group = self.chatContact,!isEditMode {
            let cell = tableView.dequeueReusableCell(withIdentifier: MessageTableViewCell.identifier) as! MessageTableViewCell
            if  group.members.count > indexPath.row {
                let member = group.members[indexPath.row]                
                cell.configureForUser(member: member)
                if let adminId = group.admin?.userId,adminId == member.userId {
                    cell.messageLabel.text = "admin"
                } else {
                    cell.messageLabel.text = "member"
                }
            }
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: FollowCell.name) as! FollowCell
            let user = users[indexPath.row]
            cell.configure(follow: user)
            cell.button.isUserInteractionEnabled = false
            if selectedUsers.contains(where: { $0.userId == user.userId }) {
                cell.button.setImage(UIImage.init(named: "selected-dot"), for: .normal)
            } else {
                cell.button.setImage(UIImage.init(named: "unselected-dot"), for: .normal)
            }
            return cell
        }
        

        
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let group = self.chatContact,!isEditMode {
            let user = group.members[indexPath.item]
            
            let controller = ProfileVC.instantiate(fromAppStoryboard: .profile)
            let vModel = ProfileViewModel(userId: user.userId)
            controller.viewModel = vModel
            controller.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(controller, animated: true)
        } else {
            let user = users[indexPath.row]
            if let index = selectedUsers.firstIndex(where: { $0.userId == user.userId }) {
                selectedUsers.remove(at: index)
            } else {
                selectedUsers.append(user.condensedUser)
            }
            tableView.reloadData()
        }
        
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if self.chatContact != nil,!isEditMode {
            return 30
        }
        return 60
    }

    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if let group = self.chatContact,!isEditMode {
            let label = UILabel()
            label.backgroundColor = UIColor.appRed
            label.textColor = UIColor.white
            if let adminName = group.admin?.username {
                label.text = "\tCreated By: \(adminName)"
            } else {
                label.text = "\tMembers"
            }
            return label
        } else {
            let searchbarView = SearchView.init(frame: CGRect.init(x: 0, y: 0, width: 200, height: 44))
            searchbarView.searchBar.delegate = self
            searchbarView.backgroundColor = UIColor.clear
            searchbarView.contentView.backgroundColor = UIColor.clear
            
            return searchbarView
        }
        
    }
}

extension CreateGroupVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return selectedUsers.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: FollowCollectionViewCell.identifier, for: indexPath) as! FollowCollectionViewCell
        let user = selectedUsers[indexPath.item]
        cell.configureWithUser(user: user)
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: 70, height: 70)
    }

}

extension CreateGroupVC: UISearchBarDelegate {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {

    }

    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        self.searchText = searchText
    }

    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchBar.text = ""
        searchBar.resignFirstResponder()
    }
}
