//
//  FlightInfoView.swift
//  Trajilis
//
//  Created by bharats802 on 20/03/19.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class TravelerView: UIView {

    
    @IBOutlet weak var backView:UIView!
    
    var personType: PassengerType = .adult
    
    @IBOutlet weak var txtFirstName:UITextField!
    @IBOutlet weak var txtMName:UITextField!
    @IBOutlet weak var txtLName:UITextField!
    @IBOutlet weak var btnDOB:UIButton!
    @IBOutlet weak var btnGender:UIButton!
    @IBOutlet weak var txtPrimaryEmail:UITextField!
    
    @IBOutlet weak var viewPrimaryEmail:UIView!
    @IBOutlet weak var lblTitle:UILabel!
    
    @IBOutlet weak var lblErrorTxtFirstName:UILabel!
    @IBOutlet weak var lblErrorTxtLName:UILabel!
    @IBOutlet weak var lblErrorBtnDOB:UILabel!
    @IBOutlet weak var lblErrorBtnGender:UILabel!
    @IBOutlet weak var lblErrorTxtPrimaryEmail:UILabel!
    @IBOutlet weak var hiddenTxtField:UITextField!
    
    
    class func getView() -> TravelerView {
        
        let view  = Bundle.main.loadNibNamed("TravelerView", owner: self, options: nil)!.first as! TravelerView
        view.translatesAutoresizingMaskIntoConstraints = false
        view.hideErrors()
        return view
        
    }
    func hideErrors() {
//        self.lblErrorTxtFirstName.isHidden = true
//        self.lblErrorTxtLName.isHidden = true
//        self.lblErrorBtnDOB.isHidden = true
//        self.lblErrorBtnGender.isHidden = true
//        self.lblErrorTxtPrimaryEmail.isHidden = true
//
//
//        self.lblErrorTxtFirstName.text = "*Required"
//        self.lblErrorTxtLName.text = "*Required"
//        self.lblErrorBtnDOB.text = "*Required"
//        self.lblErrorBtnGender.text = "*Required"
//        self.lblErrorTxtPrimaryEmail.text = "*Required"
//
//        self.lblErrorTxtFirstName.textColor = .appRed
//        self.lblErrorTxtLName.textColor = .appRed
//        self.lblErrorBtnDOB.textColor = .appRed
//        self.lblErrorBtnGender.textColor = .appRed
//        self.lblErrorTxtPrimaryEmail.textColor = .appRed
        
    }
    func isValid() -> Bool {
        var valid = true
        if self.txtFirstName.text == nil || self.txtFirstName.text!.isEmpty {
            valid = false
           // self.lblErrorTxtFirstName.isHidden = false
        }
        if self.txtLName.text == nil || self.txtLName.text!.isEmpty {
            valid = false
          //  self.lblErrorTxtLName.isHidden = false
        }
//        if !self.viewPrimaryEmail.isHidden {
            if self.txtPrimaryEmail.text == nil || self.txtPrimaryEmail.text!.isEmpty || !self.txtPrimaryEmail.text!.isValidEmail  {
                valid = false
               // self.lblErrorTxtPrimaryEmail.isHidden = false
            }
//        }
//        if self.btnGender.currentTitle == "Gender*" {
//            valid = false
//            //self.lblErrorBtnGender.isHidden = false
//        }
//        if self.btnDOB.currentTitle == "Date of Birth*" {
//            valid = false
//           // self.lblErrorBtnDOB.isHidden = false
//        }
        
        return valid
    }
    
}
