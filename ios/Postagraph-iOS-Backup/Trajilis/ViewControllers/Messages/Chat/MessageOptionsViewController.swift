//
//  MessageOptionsViewController.swift
//  Trajilis
//
//  Created by bharats802 on 24/02/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit


enum MessageOptions: Int {
    case reply = 0
    case forward = 1
    case edit = 2
    case copy = 3
    case delete = 4
}
class MessageOptionsViewController: UIViewController {

    @IBOutlet weak var stackView:UIStackView!
    @IBOutlet weak var viewCopySeparator:UIView!
    @IBOutlet weak var btnCopy:UIButton!
   
    @IBOutlet var editOption: [UIView]!
    @IBInspectable var cornerRadius: Int = -1
    
    var didSelectOption:((Int)->Void)?

    var showEdit: Bool = false
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let r = CGFloat(cornerRadius)
        if r >= 0 && view.superview?.layer.cornerRadius != r {
            view.superview?.layer.cornerRadius = r
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        for v in editOption {
            v.isHidden = !showEdit
        }
        // Do any additional setup after loading the view.
    }
    @IBAction func btnOptionTapped(sender:UIButton) {
        self.dismiss(animated: true) {
            self.didSelectOption?(sender.tag)
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
