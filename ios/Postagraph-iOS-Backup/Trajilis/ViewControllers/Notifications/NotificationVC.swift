//
//  NotificationVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 11/11/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

final class NotificationVC: BaseVC {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var noNotificationInstructionsw: UIView!
    @IBOutlet weak var notificationCounterLabel: UILabel!
    
    var viewModel = NotificationViewModel()
    private var didAnimate: Bool = false
    
    var onDismiss: (()->())?
    var onOpenMessage: (()->())?
    var onOpenComment: ((_ feedId: String, _ commentId: String)->())?
    var onOpenFeed: ((_ feedId: String)->())?
    var onOpenProfile: ((_ userId: String)->())?
    var onOpenInvitedTrip: (()->())?
    var onOpenTripster: (() -> ())?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        notificationCounterLabel.superview?.set(cornerRadius: 8)
        notificationCounterLabel.rounded()
        UIApplication.shared.applicationIconBadgeNumber = 0
        
        tableView.dataSource = self
        tableView.delegate = self
        
        spinner(with: "Please wait...", blockInteraction: true)
        viewModel.clearBadgeCount()
        viewModel.reload = { [weak self] in
            guard let self = self else {return}
            self.hideSpinner()
            self.tableView.isHidden = self.viewModel.notifications.isEmpty
            self.noNotificationInstructionsw.isHidden = !self.viewModel.notifications.isEmpty
            if self.didAnimate {
                self.tableView.reloadData()
            } else {
                self.didAnimate = true
                self.animateTable(tableView: self.tableView)
            }
        }
        
        viewModel.updateNotificationCount = { [weak self] in
            guard let self = self else {return}
            let count = self.viewModel.unreadCount
//            self.notificationCounterLabel.isHidden = count == nil
            self.notificationCounterLabel.text = (count ?? 0) > 9 ? "9+" : "\(count ?? 0)"
        }
    }
    
    @IBAction private func menuTapped() {
        let controller = UIAlertController(title: nil, message: nil, preferredStyle: Helpers.actionSheetStyle())
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let clear = UIAlertAction(title: "Clear all notifications", style: .default) { (_) in
            self.deleteAllNotification()
        }
        
        let markRead = UIAlertAction(title: "Mark all notifications as read", style: .default) { (_) in
            self.viewModel.markAllRead()
        }
        controller.addAction(clear)
        controller.addAction(markRead)
        controller.addAction(cancel)
        present(controller, animated: true, completion: nil)
    }
    
    @IBAction func closeTapped(_ sender: Any) {
        dismiss(animated: true, completion: {
            self.onDismiss?()
        })
    }
    
    private func deleteAllNotification() {
        spinner(with: "One moment...", blockInteraction: true)
        viewModel.deleteAllNotification()
    }
    
    private func profileTapped(not_f: TrajilisNotification) {
        dismiss(animated: true) {
            self.onOpenProfile?(not_f.senderId)
        }
//        let controller = ProfileVC.instantiate(fromAppStoryboard: .profile)
//        let vModel = ProfileViewModel(userId:  not_f.senderId)
//        controller.viewModel = vModel
//        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func pushReply(not_f: TrajilisNotification) {
        dismiss(animated: true) {
            self.onOpenComment?(not_f.entityId, not_f.updateHistoryId)
        }
        //        let controller = ReplyVC.instantiate(fromAppStoryboard: .comment)
        //        let model = ReplyViewModel(commentId: not_f.updateHistoryId)
        //        controller.viewModel = model
        //        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func pushTrip(not_f: TrajilisNotification) {
        if (not_f.message.contains("invited you to a trip")) {
            
//            self.fetchInvitedTrips(createdById:not_f.senderId)
            dismiss(animated: true) {
                self.onOpenInvitedTrip?()
            }
        } else {
            dismiss(animated: true) {
                self.onOpenTripster?()
            }
//            kAppDelegate.mainTabbar?.selectedIndex = kTabIndex.Tripster.rawValue
        }
    }
    
    private func fetchInvitedTrips(createdById: String) {
        spinner(with: "One Moment...")
        APIController.makeRequest(request: .getTripList(userId: Helpers.userId, invitationStatus: "INVITED", count: 0, limit: 1000)) { [weak self] (response) in
            
            guard let sSelf = self else {
                return
            }
            sSelf.hideSpinner()
            switch response {
            case .failure(_):
                self?.showAlert(message: "No invitation found. Please try again later.")
                break
            case .success(let value):
                guard let json = try? value.mapJSON()  as? JSONDictionary, let tripData = json?["data"] as? [JSONDictionary] else {
                    self?.showAlert(message:"No invitation found. Please try again later.")
                    return }
                
                let tripList = tripData.map{Trip.init(json: $0)}
                
                if tripList.count > 0 {
                    let filter = tripList.filter({ (trip) -> Bool in
                        if(trip.userId == createdById) {
                            return true
                        }
                        return false
                    })
                    if let first = filter.first {
                        self?.onOpenInvitedTrip?()
//                        let controller = TripInvitationVC.instantiate(fromAppStoryboard: .tripster)
//                        controller.trips = [first]
//                        controller.hidesBottomBarWhenPushed = true
//                        sSelf.navigationController?.pushViewController(controller, animated: true)
                    } else {
                        sSelf.showAlert(message: "No invitation found. Please try again later.")
                    }
                } else {
                    self?.showAlert(message:"No invitation found. Please try again later.")
                }
            }
        }
    }
    
    private func pushMessage(not_f: TrajilisNotification) {
        dismiss(animated: true) {
            self.onOpenMessage?()
        }
    }
    
    private func pushComment(not_f: TrajilisNotification) {
        dismiss(animated: true) {
            self.onOpenComment?(not_f.entityId, not_f.updateHistoryId)
        }
//        let controller = FeedDetailVC.instantiate(fromAppStoryboard: .feed)
//        controller.feedId = not_f.updateHistoryId
//        navigationController?.pushViewController(controller, animated: true)
        
        //        let controller = CommentVC.instantiate(fromAppStoryboard: .comment)
        //        let model = CommentViewModel.init(feedId: not_f.updateHistoryId)
        //        controller.viewModel = model
        //        navigationController?.pushViewController(controller, animated: true)
    }
    
    private func pushPost(not_f: TrajilisNotification) {
        dismiss(animated: true) {
            self.onOpenFeed?(not_f.updateHistoryId)
        }
//        let controller = FeedDetailVC.instantiate(fromAppStoryboard: .feed)
//        controller.feedId = not_f.updateHistoryId
//        navigationController?.pushViewController(controller, animated: true)
    }
    
}

extension NotificationVC: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.notifications.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "NotificationListTableViewCell") as! NotificationListTableViewCell
        let notification = viewModel.notifications.item(at: indexPath.row)
        cell.notification = notification
        cell.onProfileTapped = { [weak self] in
            self?.profileTapped(not_f: notification!)
        }
        return cell
    }
}

extension NotificationVC: UITableViewDelegate {
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        if let visibleIndexPath = tableView.indexPathsForVisibleRows {
            if let indexPath = visibleIndexPath.first {
                if (viewModel.notifications.count - indexPath.row) == 5 && !viewModel.isLastContent {
                    viewModel.loadMore()
                }
            }
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let not_f = viewModel.notifications[indexPath.row]
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (_, index) in
            if !not_f.isRead {
                self.viewModel.updateNumberOfUnreadMessage()
            }
            self.viewModel.deleteNotification(not_f: not_f)
        }
        return [delete]
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let not_f = viewModel.notifications[indexPath.row]
        if !not_f.isRead {
            not_f.isRead = true
            viewModel.updateNumberOfUnreadMessage()
            viewModel.markRead(notificationId: not_f.id)
        }
        guard let notificationType = not_f.notificationType else { return }
        let type = NotificationViewModel.NotificationNavigationType.navType(type: notificationType)
        
        switch type {
        case .message:
            pushMessage(not_f: not_f)
        case .post:
            pushPost(not_f: not_f)
        case .profile:
            profileTapped(not_f: not_f)
        case .reply:
            pushReply(not_f: not_f)
        case .trip:
            pushTrip(not_f: not_f)
        case .comment:
            pushComment(not_f: not_f)
        }
    }
    
}
