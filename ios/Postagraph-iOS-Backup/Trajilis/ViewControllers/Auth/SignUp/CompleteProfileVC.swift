//
//  CompleteProfileVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

final class CompleteProfileVC: BaseVC {
    @IBOutlet var profileButton: UIButton!
    
    @IBOutlet var nextButton: UIButton!
    @IBOutlet var whatsOnYourMindTextField: SkyFloatingLabelTextField!
    @IBOutlet var cityTextField: SkyFloatingLabelTextField!
    @IBOutlet var stateTextField: SkyFloatingLabelTextField!
    @IBOutlet var usernameLabel: UILabel!
    @IBOutlet var nameLabel: UILabel!
    
    var profileImage: UIImage? {
        didSet {
            profileButton.setImage(profileImage, for: .normal)
        }
    }
    var countryId: String = ""
    lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Locator.shared.authorize()
        Locator.shared.locate { (_) in }
        Locator.shared.placemark { (placemark) in
            guard let place = placemark else { return }
            self.stateTextField.text = place.administrativeArea
            self.cityTextField.text = place.subAdministrativeArea
        }
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
        if let user = (UIApplication.shared.delegate as? AppDelegate)?.user {
            nameLabel.text = user.firstname + " " + user.lastname
            usernameLabel.text = user.username
        }
        nextButton.makeCornerRadius(cornerRadius: 4)
        profileButton.makeBorder(borderWidth: 1, borderColour: UIColor(red: 0.9, green: 0.9, blue: 0.9, alpha: 1))
        profileButton.makeCornerRadius(cornerRadius: profileButton.frame.height/2)
        whatsOnYourMindTextField.titleFormatter = { $0 }
        whatsOnYourMindTextField.selectedTitle = "Write a short bio here"
        cityTextField.titleFormatter = { $0 }
        cityTextField.selectedTitle = "City"
        stateTextField.titleFormatter = { $0 }
        stateTextField.selectedTitle = "State"
    }
    
    @IBAction func profileImageTapped(_ sender: Any) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let cancel = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel, handler: nil)
        let camera = UIAlertAction(title: "Take Photo", style: UIAlertAction.Style.default) { (_) in
            self.photoFromCamera()
        }
        camera.setValue(UIColor.appRed, forKey: "titleTextColor")
        let gallery = UIAlertAction(title: "Photo Library", style: UIAlertAction.Style.default) { (_) in
            self.photoFromLibrary()
        }
        gallery.setValue(UIColor.appRed, forKey: "titleTextColor")
        
        alertController.addAction(cancel)
        alertController.addAction(camera)
        alertController.addAction(gallery)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func nextButtonTapped(_ sender: Any) {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
        guard let state = stateTextField.text,
            let status = whatsOnYourMindTextField.text,
            let city = cityTextField.text else { return }
        if state.isEmpty {
            showAlert(message: "Please enter state to continue.")
            return
        }
        
        if city.isEmpty {
            showAlert(message: "Please enter city to continue.")
            return
        }
        
        let param = [
            "city": city,
            "image_url": "",
            "user_id": user.id,
            "status": status
        ]
        spinner(with: "Updating profile...")
        APIController.makeRequest(request: .completeProfile(param: param)) { (response) in
            
            func showProfile() {
                self.hideSpinner()
                let controller: ProfileViewController = Router.get()
                let vModel = ProfileViewModel(userId: user.id)
                vModel.isCompleteProfile = true
                controller.viewModel = vModel
                controller.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(controller, animated: true)
            }
            
            if let img = self.profileImage {
                Helpers.uploadProfileImage(image: img, completion: {
                    showProfile()
                })
            }else {
                showProfile()
            }
        }
        
    }
    
    @IBAction func skipTapped(_ sender: Any) {
        nextButtonTapped(sender)
    }
    
    fileprivate func photoFromLibrary() {
        imagePicker.delegate = self
        imagePicker.allowsEditing = true
        imagePicker.sourceType = .photoLibrary
        present(imagePicker, animated: true, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func stateTapped(_ sender: Any?) {
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.type = .state
        controller.title = "Select State"
    
        controller.didSelectState = { [weak self] state in
            self?.selectedState = state
            self?.stateTextField.text = state.name
            self?.cityTextField.text = ""
            if let sender = sender as? String, sender == "city" {
                self?.cityTapped(nil)
            }
        }
        controller.countryId = countryId
        navigationController?.pushViewController(controller, animated: true)
    }
    
    private var selectedState: State?
    
    @IBAction func cityTapped(_ sender: Any?) {
        if selectedState == nil {
            stateTapped("city")
            return
        }
        let controller = SelectCountryVC.instantiate(fromAppStoryboard: .auth)
        controller.type = .city
        controller.stateId = selectedState?.id
        controller.title = "Select City"
        controller.didSelectCity = { [weak self] city in
            self?.cityTextField.text = city.name
            self?.updateButton()
        }
        controller.countryId = countryId
        controller.stateId = selectedState?.id
        navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func photoFromCamera() {
        if (UIImagePickerController.isSourceTypeAvailable(.camera)) {
            imagePicker.delegate = self
            imagePicker.allowsEditing = true
            imagePicker.sourceType = .camera
            imagePicker.cameraCaptureMode = .photo
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            showAlert(message: "Application cannot access the camera.")
        }
    }
    
    func updateButton() {
        nextButton.isEnabled = true
        nextButton.backgroundColor = UIColor.appRed
    }
    
}

extension CompleteProfileVC: UIImagePickerControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        if let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            profileImage = image
            //updateButton()
        }
        dismiss(animated: true, completion: nil)
    }
}
