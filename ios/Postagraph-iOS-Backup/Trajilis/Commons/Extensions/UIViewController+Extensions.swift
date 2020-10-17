//
//  UIViewController+Extensions.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/10/2018.
//  Copyright © 2018 Johnson. All rights reserved.
//

import UIKit

extension UIViewController {
    func showAlert(title: String = Texts.postagraph, message: String) {
        var msg = message
        
        if message == "Unknown Error" {
            msg = kDefaultError
        }        
        let alertController = UIAlertController.init(title: title, message: msg, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    class var storyboardID: String {
        return "\(self)"
    }
    static func instantiate(fromAppStoryboard appStoryboard: AppStoryboard) -> Self {
        return appStoryboard.viewController(viewControllerClass: self)
    }
    func hideNavigationBar() {
        if !(self.navigationController?.isNavigationBarHidden ?? false) {
            self.navigationController?.isNavigationBarHidden = true
//            self.navigationController?.setNavigationBarHidden(true, animated: true)
        }
    }
    func showNavigationBar() {
        if self.navigationController?.isNavigationBarHidden ?? false {
            self.navigationController?.isNavigationBarHidden = false
//            self.navigationController?.setNavigationBarHidden(false, animated: true)
        }
    }
    
    func showAlert(title: String = Texts.postagraph, message: String, actionTitle: String = "OK", fire: @escaping (() -> Void)) {
        
        let alertController = UIAlertController.init(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction.init(title: actionTitle, style: .default) { _ in fire()}
        
        let cancelAction = UIAlertAction(title: "Cancel", style: UIAlertAction.Style.cancel) { _ in}
        
        alertController.addAction(okAction)
        alertController.addAction(cancelAction)
        present(alertController, animated: true, completion: nil)
    }
    
    func setupNavigationController() {
        self.navigationController?.navigationBar.barTintColor = .appRed
        self.navigationController?.navigationBar.isTranslucent = false
        self.navigationController?.navigationBar.tintColor = UIColor.white
        self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor: UIColor.white]
    }
}

extension Dimmable where Self: UIViewController {
    
    func unauthenticatedBlock(canDismiss: Bool) {
        let controller = AnonymousSignupVC.instantiate(fromAppStoryboard: .main)
        controller.didDismiss = { [weak self] in
            self?.dim(.out, speed: 0)
        }
        controller.canDismiss = canDismiss
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = .overFullScreen
        controller.providesPresentationContextTransitionStyle = true
        self.dim(.in, color: UIColor.black, alpha: 0.3, speed: 0.5)
        present(controller, animated: true, completion: nil)
    }
    
    func openCamera() {
        let controller = CameraVC.instantiate(fromAppStoryboard: .video)
//        controller.isNormalMode = false
        let navController = UINavigationController(rootViewController: controller)
        navController.isNavigationBarHidden = true
        navController.navigationBar.tintColor = UIColor(hexString: "#D63D41")
        present(navController, animated: true, completion: nil)
    }
    
    func animateTable(tableView: UITableView) {
        tableView.reloadData()
//        let visibleCellIndexPaths = tableView.indexPathsForVisibleRows ?? []
//        let visibleSectionIndexes = tableView.indexPathsForVisibleRows?.map{$0.section} ?? []
//        let visibleSections = Array(Set(visibleSectionIndexes)).compactMap(tableView.headerView(forSection:))
        
        var views: [UIView] = tableView.visibleCells
//        visibleCellIndexPaths.forEach({ indexPath in
//            // append header if row is first row
//            if indexPath.row == 0 {
//                if let header = tableView.headerView(forSection: indexPath.section) {
//                    views.append(header)
//                }
//            }
//
//            // append cell
//            if let cell = tableView.cellForRow(at: indexPath) {
//                views.append(cell)
//            }
//
//            // append footer if the row is last row
//            let rowCount = tableView.numberOfRows(inSection: indexPath.section)
//            if indexPath.row == rowCount - 1 {
//                if let footer = tableView.footerView(forSection: indexPath.section) {
//                    views.append(footer)
//                }
//            }
//        })
        
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        views.forEach {
            $0.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        views.forEach { view in
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: UInt(0)), animations: {
                view.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }

}
