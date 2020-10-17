//
//  BaseTVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 13/02/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class BaseTVC: UITableViewController, TRBaseVCProtocol {

    var didAnimate: Bool = false
    override func viewDidLoad() {
        super.viewDidLoad()
        self.setBackgroundImage()
        tableView.tableFooterView = UIView(frame: .zero)
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
    func unauthenticatedBlock(canDismiss: Bool) {
        let controller = AnonymousSignupVC.instantiate(fromAppStoryboard: .main)
        controller.didDismiss = { [weak self] in
            self?.dim(.out, speed: 0)
        }
        controller.canDismiss = canDismiss
        controller.definesPresentationContext = true
        controller.modalPresentationStyle = .overCurrentContext
        controller.providesPresentationContextTransitionStyle = true
        self.dim(.in, color: UIColor.black, alpha: 0.3, speed: 0.5)
        present(controller, animated: true, completion: nil)
    }
    
    func updateUserInterface() {
        guard let status = Network.reachability?.status else { return }
        if status == .unreachable {
            showAlert(message: "You are offline.")
        }
    }
    
    @objc func statusManager(_ notification: Notification) {
        updateUserInterface()
    }
    
    func spinner(with text: String? = nil,blockInteraction:Bool = false) {
        self.hideSpinner()
        let spinnerActivity = MBProgressHUD.showCustomHud(to: self.view, animated: true)
        if let txt = text {
            spinnerActivity.label.text = txt
        }
        spinnerActivity.isUserInteractionEnabled = blockInteraction
    }
    
    func hideSpinner() {
        MBProgressHUD.hide(for: self.view, animated: true)
    }
    
    func goHome() {
        let controller = UIStoryboard(name: "Main", bundle: nil).instantiateInitialViewController()
        navigationController?.present(controller!, animated: true, completion: nil)
    }
    
    //MARK : Animate the Tableview
    func animateTable() {
        tableView.reloadData()
        didAnimate = true
        let cells = tableView.visibleCells
        let tableHeight: CGFloat = tableView.bounds.size.height
        
        for i in cells {
            let cell: UITableViewCell = i as UITableViewCell
            cell.transform = CGAffineTransform(translationX: 0, y: tableHeight)
        }
        
        var index = 0
        
        for a in cells {
            let cell: UITableViewCell = a as UITableViewCell
            UIView.animate(withDuration: 1.5, delay: 0.05 * Double(index), usingSpringWithDamping: 0.8, initialSpringVelocity: 0, options: UIView.AnimationOptions(rawValue: UInt(0)), animations: {
                cell.transform = CGAffineTransform(translationX: 0, y: 0);
            }, completion: nil)
            
            index += 1
        }
    }
}
