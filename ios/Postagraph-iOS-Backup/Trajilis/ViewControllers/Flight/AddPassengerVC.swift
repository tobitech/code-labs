//
//  AddPassengerVC.swift
//  Trajilis
//
//  Created by Johnson Ejezie on 29/01/2019.
//  Copyright © 2019 Johnson. All rights reserved.
//

import UIKit

class AddPassengerVC: UIViewController {

    @IBOutlet var infantDOBLabel: UILabel!
    @IBOutlet var infantHiddenTextField: UITextField!
    @IBOutlet var infantLastNameLabel: UITextField!
    @IBOutlet var infantFirstNameLabel: UITextField!
    @IBOutlet var dobLabel: UILabel!
    @IBOutlet var maleIcon: UIImageView!
    @IBOutlet var femaleIcon: UIImageView!
    @IBOutlet var lastnameTextField: UITextField!
    @IBOutlet var firstnameTextField: UITextField!
    @IBOutlet var containerView: UIView!
    @IBOutlet var hiddenTextField: UITextField!
    @IBOutlet var infantSwitch: CustomSwitch!
    @IBOutlet var infantViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet var infantSubviews: [UIView]!

    var gender = "male"
    var type: PassengerType!
    var didDismiss:(() -> Void)?
    var didEnterPassenger:((Passenger) -> Void)?
    var passenger: Passenger?
    var isWithInfant = false

    override func viewDidLoad() {
        super.viewDidLoad()
        updateInfant(withInfant: false)
        if let passenger = self.passenger {
            firstnameTextField.text = passenger.firstname
            lastnameTextField.text = passenger.lastname
            dobLabel.text = passenger.dob
            if passenger.dob == "male" {
                maleTapped(self)
            } else {
                femaleTapped(self)
            }
            isWithInfant = passenger.isWithInfant
            infantSwitch.isOn = isWithInfant
            updateInfant(withInfant: passenger.isWithInfant)
            if let infant = passenger.infant {
                infantFirstNameLabel.text = infant.firstname
                infantLastNameLabel.text = infant.lastname
                infantDOBLabel.text = infant.dob
            }
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        containerView.layer.cornerRadius = 6
        containerView.layer.masksToBounds = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        didDismiss?()
    }

    private func updateInfant(withInfant: Bool) {
        infantViewHeightConstraint.constant = withInfant ? 112.5 : 0
        for subview in infantSubviews {
            subview.alpha = withInfant ? 1 : 0
        }
    }

    @IBAction func maleTapped(_ sender: Any) {
        gender = "male"
        femaleIcon.image = UIImage(named: "unselected-dot")
        maleIcon.image = UIImage(named: "select_icon")
    }

    @IBAction func switchValueChanged(_ sender: CustomSwitch) {
        isWithInfant = sender.isOn
        updateInfant(withInfant: sender.isOn)
    }

    @IBAction func cancelTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }

    @IBAction func saveTapped(_ sender: Any) {
        guard let first = firstnameTextField.text,
        let last = lastnameTextField.text,
            !first.isEmpty, !last.isEmpty else {
                showAlert(message: "Please both first and last name")
                return
        }
        if dobLabel.text == "DOB" {
            showAlert(message: "Date of birth is required.")
            return
        }
        if isWithInfant {
            guard let infantFirst = infantFirstNameLabel.text,
                let infantLast = infantLastNameLabel.text,
                !infantFirst.isEmpty, !infantLast.isEmpty else {
                    showAlert(message: "Please both first and last name of infant is required.")
                    return
            }
            if infantDOBLabel.text == "DOB" {
                showAlert(message: "Date of birth is of infant required.")
                return
            }
            let infant = Infant.init(firstname: infantFirst, lastname: infantLast, dob: infantDOBLabel.text!)
            let passenger = Passenger.init(firstname: first, lastname: last, gender: gender, dob: dobLabel.text!, isWithInfant: isWithInfant, type: type, infant: infant)
            didEnterPassenger?(passenger)
        } else {
            let passenger = Passenger.init(firstname: first, lastname: last, gender: gender, dob: dobLabel.text!, isWithInfant: isWithInfant, type: type, infant: nil)
            didEnterPassenger?(passenger)
        }

        dismiss(animated: true, completion: nil)
    }

    @IBAction func femaleTapped(_ sender: Any) {
        gender = "female"
        maleIcon.image = UIImage(named: "unselected-dot")
        femaleIcon.image = UIImage(named: "select_icon")
    }
    
    @IBAction func dateTapped(_ sender: Any) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.backgroundColor = UIColor.white
        datePickerView.addTarget(self, action: #selector(datePickerValueChanged), for: UIControl.Event.valueChanged)
        hiddenTextField.inputView = datePickerView
        hiddenTextField.becomeFirstResponder()
    }

    @IBAction func infantDateTapped(_ sender: Any) {
        let datePickerView: UIDatePicker = UIDatePicker()
        datePickerView.datePickerMode = .date
        datePickerView.backgroundColor = UIColor.white
        datePickerView.addTarget(self, action: #selector(infantDatePickerValueChanged), for: UIControl.Event.valueChanged)
        infantHiddenTextField.inputView = datePickerView
        infantHiddenTextField.becomeFirstResponder()
    }

    @objc func datePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd"
        self.dobLabel.text = dateFormatter.string(from: sender.date)
    }

    @objc func infantDatePickerValueChanged(sender: UIDatePicker) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat =  "yyyy-MM-dd"
        self.infantDOBLabel.text = dateFormatter.string(from: sender.date)
    }
}
