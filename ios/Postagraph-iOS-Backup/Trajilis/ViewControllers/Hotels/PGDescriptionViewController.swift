//
//  PGDescriptionViewController.swift
//  Trajilis
//
//  Created by bharats802 on 24/04/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class PGDescriptionViewController: UIViewController {

    @IBOutlet weak var textView:UITextView!
    
    var text:String?
    override func viewDidLoad() {
        super.viewDidLoad()
        self.textView.text = text
        // Do any additional setup after loading the view.
        let cancelBtn = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(btnCancelTapped(sender:)))
        self.navigationItem.rightBarButtonItem  = cancelBtn
        // Do any additional setup after loading the view.
    }
    @IBAction func btnCancelTapped(sender:UIBarButtonItem){
        self.dismiss(animated: true, completion: nil)
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
