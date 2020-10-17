//
//  FareRuleVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 03/03/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class FareRuleVC: UIViewController, UITableViewDataSource, UITableViewDelegate {

    @IBOutlet var fareRuleLabel: UILabel!
    @IBOutlet var tblView: UITableView!
    var rules = ""
    
    var fareRules : [PGFareRule]?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Fare Rules"
        
        let cancelBarButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        cancelBarButton.tintColor = UIColor.appRed
        navigationItem.leftBarButtonItem = cancelBarButton
        
        fareRuleLabel.text = rules
        tblView.rowHeight = UITableView.automaticDimension
        tblView.estimatedRowHeight = 100
        tblView.tableFooterView = UIView(frame:CGRect.zero)
        
        if let fareRules = self.fareRules, fareRules.count > 0 {
            self.tblView.isHidden = false
            self.fareRuleLabel.isHidden = true
        } else {
            self.fareRuleLabel.isHidden = false
            self.tblView.isHidden = true
        }
    }
    
    @objc func handleCancel() {
        self.dismiss(animated: true, completion: nil)
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.fareRules?.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "PGFareRuleCell", for: indexPath)
        
        if let rules = fareRules {
            let rule = rules[indexPath.row]
            cell.textLabel?.text = rule.category
            cell.detailTextLabel?.text = rule.text
        }
        
        return cell
    }
    
}
