//
//  CreateGroupViewController.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/30/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SDWebImage
import MobileCoreServices
import AVKit

class CreateGroupViewController: BaseVC {
    
    weak var chatVC:ChatViewController?
    
    @IBOutlet weak var createGroupImageButton: UIButton!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var underLineView: UIView!
    @IBOutlet weak var nextButton: UIButton!
    
    var chatContact: ChatContact?
    private var isEditMode: Bool = true
    private var image: UIImage? {
        didSet {
            self.createGroupImageButton.setImage(image, for: .normal)
        }
    }
    private var imageChanged: Bool = false {
        didSet {
            setNextButton()
        }
    }
    private let currentUser = (UIApplication.shared.delegate as! AppDelegate).user!
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if chatContact != nil {
            nameTextField.text = chatContact?.groupName
            isEditMode = chatContact?.admin?.userId == currentUser.id
        }
        nameTextField.delegate = self
        textFieldDidEndEditing(nameTextField)
        createGroupImageButton.rounded()
        createGroupImageButton.set(borderWidth: 1, of: UIColor(hexString: "#E5E5E5"))
        nextButton.addTarget(self, action: #selector(self.saveTapped), for: .touchUpInside)
        createGroupImageButton.addTarget(self, action: #selector(self.selectImageTapped), for: .touchUpInside)
        nameTextField.addTarget(self, action: #selector(self.setNextButton), for: UIControl.Event.editingChanged)
        
        if let group = self.chatContact {
            if let url = URL(string: group.groupImage) {
                createGroupImageButton.sd_imageIndicator = SDWebImageActivityIndicator.gray
                createGroupImageButton.sd_setImage(with: url, for: .normal, placeholderImage: UIImage(named: "createGroupAddImagePlaceholder"))
            }
        }
        
        nameTextField.isUserInteractionEnabled = isEditMode
        createGroupImageButton.isUserInteractionEnabled = isEditMode
        setNextButton()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        showNavigationBar()
        if let group = self.chatContact {
            navigationItem.title = group.groupName
        } else {
            navigationItem.title = "Create Group"
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if self.chatContact == nil && nameTextField.text!.isEmpty {
            nameTextField.becomeFirstResponder()
        }
    }
    
    @objc private func setNextButton() {
        if let group = chatContact {
            if nameTextField.text != group.groupName || imageChanged  {
                nextButton.setTitle("Save and Continue", for: .normal)
            }else {
                nextButton.setTitle(isEditMode ? "Manage Members" : "Next", for: .normal)
            }
        }
        
        let enable = !nameTextField.text!.isEmpty
        nextButton.isEnabled = enable
        nextButton.alpha = enable ? 1 : 0.6
    }
    
    private func openAddMember() {
        let vc: AddMemberToTripViewController = Router.get()
        let viewModel = AddMemberToTripViewModel()
        viewModel.mode = chatContact == nil ? .add : (isEditMode ? .add : .view)
        
        if let chatContact = chatContact {
            viewModel.noMemberTitle = chatContact.isAdmin ? "You need to add at least 1 member to your group." : "No Members"
            viewModel.noMemberSubtitle = "Tap the search bar to find members."
            viewModel.selectedUsers = chatContact.members
        }else {
            viewModel.noMemberTitle = "You need to add at least 1 member to your group."
            viewModel.noMemberSubtitle = "Tap the search bar to find members."
        }
        vc.viewModel = viewModel
        vc.title = nameTextField.text
        vc.onAdd = { [weak self] userId in
            //            self?.viewModel.addUserToTrip(userId: userId)
        }
        vc.onRemove = { [weak self] userId in
            //            self?.viewModel.deleteUserFromTrip(userId: userId)
        }
        vc.onDone = { [unowned self] in
            if self.chatContact == nil {
                self.createGroup(users: viewModel.selectedUsers)
            }else if self.isEditMode {
                self.updateGroup(users: viewModel.selectedUsers, completion: { [weak self] in
                    self?.navigationController?.popViewController(animated: true)
                })
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func selectImageTapped() {
        view.endEditing(true)
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
            self.imageChanged = true
            self.createGroupImageButton.setImage(UIImage(named: "createGroupAddImagePlaceholder"), for: .normal)
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
    
    private func openCamera(isCamera:Bool) {
        if isCamera {
            let controller = CameraVC.instantiate(fromAppStoryboard: .video)
            controller.recordType = .simpleCamera
            controller.cameraMode = .Image
            let navController = UINavigationController(rootViewController: controller)
            navController.isNavigationBarHidden = true
            
            controller.didCaptureImage = {[weak self] (image,error) in
                if let img = image {
                    self?.createGroupImageButton.setImage(img, for: .normal)
                    self?.image = img
                    self?.imageChanged = true
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
    
    @objc private func saveTapped() {
        view.endEditing(true)
        if nameTextField.text!.isEmpty {
            showAlert(message: "Group name is required.")
            return
        }
        if chatContact == nil {
            openAddMember()
        }else if isEditMode && (imageChanged || nameTextField.text != chatContact!.groupName) {
            updateGroup(users: nil, completion: { [weak self] in
                 self?.openAddMember()
            })
        }else {
            openAddMember()
        }
    }
    
    private func uploadImage(image: UIImage, completion: @escaping (String?) -> ()) {
        Helpers.uploadToS3(image: image) { (url, _) in
            DispatchQueue.main.async {
                completion(url)
            }
        }
    }
    
    private func userToJSONDict(user: CondensedUser) -> JSONDictionary {
        return [
            "user_id": user.userId,
            "user_image": user.userImage,
            "user_name": user.username
        ]
    }
    
    private func createGroup(users: [CondensedUser]) {
        if users.isEmpty {
            showAlert(message: "Please search & add at least one member to the group.")
        }else {
            self.spinner(with: "Creating Group...", blockInteraction:true)
            if let image = self.image {
                uploadImage(image: image) { url in
                    self.createGroupWithImage(url: url ?? "", users: users)
                }
            } else {
                createGroupWithImage(url: "", users: users)
            }
        }
    }
    
    private func createGroupWithImage(url: String, users: [CondensedUser]) {
        let grpMembers: [JSONDictionary] = (users + [currentUser.condensedUser]).map(userToJSONDict)
        let param = [
            "group_image": url,
            "group_members": grpMembers,
            "group_name": nameTextField.text!,
            "user_id": currentUser.id
            ] as JSONDictionary
        
        APIController.makeRequest(request: .createGroup(param: param)) { [weak self](response) in
            DispatchQueue.main.async {
                self?.hideSpinner()
                switch response {
                case .failure(let e):
                    self?.showAlert(message: e.desc)
                case .success(let result):
                    if let json = try? result.mapJSON() as? JSONDictionary,
                        let data = json?["data"] as? JSONDictionary,
                        let self = self {
                        let group = ChatContact.init(json: data)
                        if !group.groupId.isEmpty {
                            let controller = ChatViewController.instantiate(fromAppStoryboard: .message)
                            controller.chatContact = group
                            controller.currentUser = self.currentUser.condensedUser
                            controller.hidesBottomBarWhenPushed = true
                            self.navigationController?.pushViewController(controller, animated: true)
                            SocketIOManager.shared.msgVC?.viewModel.refresh()
                            return
                        }
                    }
                    self?.showAlert(message: "Unable to create group at this time. Please try again later")
                }
            }
        }
    }
    
    private func updateGroup(users: [CondensedUser]?, completion: @escaping () -> ()) {
        spinner(with: "Updating...", blockInteraction: true)
        var errorMessage: String?
        
        func updateComplete() {
            DispatchQueue.main.async {
                self.hideSpinner()
                self.chatVC?.updateGroup(group: self.chatContact!)
                SocketIOManager.shared.msgVC?.viewModel.refresh()
                if let errorMessage = errorMessage {
                    self.showAlert(message: errorMessage)
                }else {
                    completion()
                }
            }
        }
        
        var acknowledgeCounter = 0 {
            didSet {
                if acknowledgeCounter == 0 {
                    updateComplete()
                }
            }
        }
        
        if let users = users {
            if manageGroup(users: users, completion: { success in
                if success {
                    self.chatContact?.members = users
                }else {
                    errorMessage = "Unable to update members of the group."
                }
                acknowledgeCounter -= 1
            }) {
                acknowledgeCounter += 1
            }
        }
        
        if uploadImageAndUpdate(completion: { url in
            if let url = url {
                self.imageChanged = false
                self.image = nil
                self.chatContact?.groupImage = url
            }else {
                errorMessage = "Unable to update image of the group."
            }
            acknowledgeCounter -= 1
        }) {
            acknowledgeCounter += 1
        }
        
        if updateGroupName(onCompletion: { (success) in
            if success {
                self.chatContact?.groupName = self.nameTextField.text!
            }else {
                errorMessage = "Unable to change name of the group."
            }
            acknowledgeCounter -= 1
        }) {
            acknowledgeCounter += 1
        }
    }
    
    private func uploadImageAndUpdate(completion: @escaping (String?) -> ()) -> Bool {
        if imageChanged {
            if let image = image {
                uploadImage(image: image) { (url) in
                    if let url = url {
                        self.updateImage(url: url, completion: completion)
                    }else {
                        completion(nil)
                    }
                }
            }else {
                self.updateImage(url: "", completion: completion)
            }
        }
        return imageChanged
    }
    
    private func updateImage(url: String, completion: @escaping (String?) -> ()) {
        let parameters = [
            "group_id": chatContact!.groupId,
            "group_image": url,
            "user_id": currentUser.id
            ] as JSONDictionary
        
        APIController.makeRequest(request: .updateGroupImage(param: parameters)) {(response) in
            switch response {
            case .failure( _):
                completion(nil)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else { return }
                if let status = meta["status"] as? String, status == "200" {
                    completion(url)
                } else {
                    completion(nil)
                }
            }
        }
    }
    
    private func updateGroupName(onCompletion: @escaping (Bool)->()) -> Bool {
        if chatContact!.groupName == nameTextField.text! {
            return false
        }
        
        APIController.makeRequest(request: .updateGroupName(userId: currentUser.id, groupId: chatContact!.groupId, groupName: nameTextField.text!)) {(response) in
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
        return true
    }
    
    private func manageGroup(users: [CondensedUser], completion: @escaping (Bool) -> ()) -> Bool {
        let membersToDelete = chatContact!.members.filter({!users.contains($0)}).map(userToJSONDict)
        let membersToAdd = users.filter({!chatContact!.members.contains($0)}).map(userToJSONDict)
        
        if membersToAdd.isEmpty && membersToDelete.isEmpty {
            return false
        }
        
        let parameters = [
            "group_id":chatContact!.groupId,
            "joine_member_list":membersToAdd,
            "remove_member_list":membersToDelete,
            "user_id":currentUser.id
            ] as JSONDictionary
        
        APIController.makeRequest(request: .manageGroup(param: parameters)) {(response) in
            switch response {
            case .failure( _):
                completion(false)
            case .success(let result):
                guard let json = try? result.mapJSON() as? JSONDictionary,
                    let meta = json?["meta"] as? JSONDictionary else { return }
                if let status = meta["status"] as? String, status == "200" {
                    completion(true)
                } else {
                    completion(false)
                }
            }
        }
        return true
    }
    
}

extension CreateGroupViewController: UITextFieldDelegate {
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        underLineView.alpha = 1
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        underLineView.alpha = textField.text!.isEmpty ? 0.6 : 1
    }
    
    //    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
    //        let newText = (textField.text! as NSString).replacingCharacters(in: range, with: string)
    //        if let group = chatContact {
    //
    //        }
    //        return true
    //    }
    
}

extension CreateGroupViewController: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as AnyObject
        if mediaType as! String == kUTTypeImage as String {
            if let image = info[UIImagePickerController.InfoKey.editedImage] as? UIImage {
                createGroupImageButton.setImage(image, for: .normal)
                self.image = image
                imageChanged = true
            }
        }
        dismiss(animated: true, completion: nil)
    }
}
