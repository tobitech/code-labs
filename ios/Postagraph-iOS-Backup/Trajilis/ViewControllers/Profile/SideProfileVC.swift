//
//  SideProfileVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 10/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit
import MessageUI


final class SideProfileVC: BaseVC , MFMailComposeViewControllerDelegate {
    
    @IBOutlet var tableView: UITableView!
    @IBOutlet var activity:UIActivityIndicatorView!

    var items = [SideMenuItem]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.activity.stopAnimating()
        self.activity.hidesWhenStopped = true
        if(!Helpers.isLoggedIn()) {
            setupDataSourceForGuest()
        } else {
            setupDataSource()
        }        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideNavigationBar()
        tableView.reloadData()
        
        //self.refreshProfile()
    }
    private func refreshProfile() {
        if(Helpers.isLoggedIn()) {
            self.activity.startAnimating()
            Helpers.getCurrentUser { [weak self](success) in
                if let strngSelf = self {
                    strngSelf.activity.stopAnimating()
                    if(success) {
                        strngSelf.setupDataSource()
                        strngSelf.tableView.reloadData()
                    }
                }
            }
        }
    }
    private func setupDataSource() {
        items = [
            SideMenuItem(title: "SAVED FOR LATER", action: savedPosts(_:)),
            SideMenuItem(title: "MY BOOKINGS", action: myBooking(_:)),
            SideMenuItem(title: "LIKED PLACES", action: likedPlaces(_:)),
            SideMenuItem(title: "INVITE YOUR FRIENDS", action: inviteFriends(_:)),
            SideMenuItem(title: "SHARE YOUR FEEDBACK", action: shareFeedback(_:)),
            SideMenuItem(title: "SETTINGS", action: setting(_:))
        ]
    }
    private func setupDataSourceForGuest() {
        items = [
            SideMenuItem(title: "INVITE YOUR FRIENDS", action: inviteFriends(_:)),
            SideMenuItem(title: "SHARE YOUR FEEDBACK", action: shareFeedback(_:)),
        ]
    }
    

    func myPlaces(_ sender: Any?) {
        let controller = PlacesVC.instantiate(fromAppStoryboard: .places)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func savedPosts(_ sender: Any?) {
        let recordingsViewController = RecordingsViewController.instantiate(fromAppStoryboard: .video)
        recordingsViewController.hidesBottomBarWhenPushed = true
        recordingsViewController.isShowingSavedRecordings = true
        navigationController?.pushViewController(recordingsViewController, animated: true)
    }
    
    func myBooking(_ sender: Any?) {
        let bookingsViewController = MyHotelsBookingsViewController.instantiate(fromAppStoryboard: .hotels)
        bookingsViewController.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(bookingsViewController, animated: true)
    }

    func likedPlaces(_ sender: Any?) {
        let controller = LikedFeedVC.instantiate(fromAppStoryboard: .profile)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func inviteFriends(_ sender: Any?) {
        let inviteController = InviteContainerController.instantiate(fromAppStoryboard: .invite)
        navigationController?.pushViewController(inviteController, animated: true)
    }

 
    func shareFeedback(_ sender: Any?) {
        let controller = MFMailComposeViewController()
        controller.mailComposeDelegate = self
        controller.setToRecipients(["hello@postagraph.com"])
        controller.setSubject("User Feedback")
        controller.setMessageBody("", isHTML: false)

        if MFMailComposeViewController.canSendMail(){
            self.present(controller, animated: true, completion: nil)
        }else{
            print("Can't send email")
        }
    }

    func setting(_ sender: Any?) {
        let controller = SettingsViewController.instantiate(fromAppStoryboard: .settings)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func profileTapped(_ sender: Any) {
        guard let id = UserDefaults.standard.string(forKey: USERID) else { return }
        let controller: ProfileViewController = Router.get()
        let vModel = ProfileViewModel(userId: id)
        controller.viewModel = vModel
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
 
    
    @IBAction func placesTapped(_ sender: Any) {
        let controller = PlacesVC.instantiate(fromAppStoryboard: .places)
        navigationController?.pushViewController(controller, animated: true)
    }
    
    @IBAction func signOutTapped(_ sender: Any) {
        let alertController = UIAlertController(title: "Logout", message: "Are you sure you want to logout?", preferredStyle: Helpers.actionSheetStyle())
//        alertController.view.tintColor = UIColor.black
        
        let logout = UIAlertAction(title: "Logout", style: .destructive) { (action:UIAlertAction) in
            APIController.makeRequest(request: .signout) { (_) in }
            UserDefaults.standard.removeObject(forKey: USERID)
            let dic = UserDefaults.standard.dictionaryRepresentation()
            for key in dic.keys {
                if(key != "is_dev_env") {
                    UserDefaults.standard.removeObject(forKey: key)
                }
            }
            UserDefaults.standard.synchronize()
            try? DataStorage.shared.dataStorage.removeAll()
            (UIApplication.shared.delegate as? AppDelegate)?.user = nil
            let controller = UIStoryboard(name: "Initial", bundle: nil).instantiateInitialViewController()
            UIApplication.shared.keyWindow?.rootViewController = controller
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler:nil)
        
        alertController.addAction(logout)
        alertController.addAction(cancel)
        present(alertController, animated: true, completion: nil)
    }
    
    @IBAction func backTapped(_ sender: Any) {
        NotificationCenter.default.post(name: NSNotification.Name.init("HideMenu"), object: nil)
    }
    
    fileprivate func followers() {
        let controller = FollowViewController.instantiate(fromAppStoryboard: .follow)
        let model = FollowViewModel(type: .follow(type: .follower))
        controller.viewModel = model
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
    fileprivate func following() {
        let controller = FollowViewController.instantiate(fromAppStoryboard: .follow)
        let model = FollowViewModel(type: .follow(type: .following))
        controller.viewModel = model
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }

    fileprivate func gotoProfile() {
        guard let user = (UIApplication.shared.delegate as? AppDelegate)?.user else { return }
        let controller: ProfileViewController = Router.get()
        let vModel = ProfileViewModel(userId: user.id)
        controller.viewModel = vModel
        controller.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension SideProfileVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuTableViewCell.identifier) as! SideMenuTableViewCell
        let title = items[indexPath.row].title
        cell.titleLabel.text = title
        cell.titleLabel.textColor = UIColor.darkGray
        return cell
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        items[indexPath.row].action(nil)
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        if !Helpers.isLoggedIn() { return nil }
        let cell = tableView.dequeueReusableCell(withIdentifier: SideMenuHeaderTableViewCell.identifier) as! SideMenuHeaderTableViewCell
        let user = (UIApplication.shared.delegate as! AppDelegate).user
        cell.configure(user: user!)
        cell.placesBlock = {
            self.myPlaces(nil)
        }
        cell.followingBlock = {
            self.following()
        }

        cell.followersBlock = {
            self.followers()
        }

        cell.profileBlock = {
            self.gotoProfile()
        }
        return cell
    }

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return !Helpers.isLoggedIn() ? 0 : 120
    }
}


extension SideProfileVC {
    
    func mailComposeController(_ controller: MFMailComposeViewController, didFinishWith result: MFMailComposeResult, error: Error?) {
        controller.dismiss(animated: true, completion: nil)
    }
}


struct SideMenuItem {
    let title: String
    let action: (Any?) -> Void

    init(title: String, action: @escaping ((Any?) -> Void)) {
        self.title = title
        self.action = action
    }
}
