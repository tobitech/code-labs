//
//  FlightTravelerView.swift
//  Trajilis
//
//  Created by Oluwatobi Omotayo on 16/09/2019.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit
import SkyFloatingLabelTextField

protocol TravelerInfoCellDelegate: class {
    func didCompleteForm(_ cell: TravelerInfoCell, updatedTravelerInfo: TravelerInfo)
}

class TravelerInfoCell: UITableViewCell {
    
    @IBOutlet weak var passengerTitleLabel: UILabel!
    @IBOutlet weak var firstnameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var lastnameTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var emailTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var dobTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var phoneTextField: SkyFloatingLabelTextField!
    @IBOutlet weak var maleButton: UIButton!
    @IBOutlet weak var femaleButton: UIButton!
    /*
    let passengerTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Adult"
        label.font = UIFont(name: "PTSans-Regular", size: 16)
        label.textColor = UIColor.defaultText
        return label
    }()
    
    let genderTitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Gender"
        label.font = UIFont(name: "PTSans-Regular", size: 16)
        label.textColor = UIColor.defaultText
        return label
    }()
    
    lazy var lastnameTextField: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField()
        tf.titleFormatter = { $0 }
        tf.title =  "Last Name"
        tf.selectedTitle =  "Last Name"
        tf.placeholder =  "Last Name"
        tf.addTarget(self, action: #selector(handleInputChanged), for: .editingChanged)
        tf.textColor = UIColor.textBlack
        tf.placeholderColor = UIColor.appGrey
        tf.lineColor = UIColor.appGrey
        tf.selectedLineColor = UIColor.textBlack
        tf.selectedTitleColor = UIColor.appGrey
        tf.lineHeight = 1.0
        tf.selectedLineHeight = 1.0
        tf.autocapitalizationType = .words
        tf.autocorrectionType = .no
        return tf
    }()
    
    lazy var firstnameTextField: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField()
        tf.titleFormatter = { $0 }
        tf.selectedTitle =  "First Name"
        tf.placeholder =  "First Name"
        tf.title =  "First Name"
        tf.addTarget(self, action: #selector(handleInputChanged), for: .editingChanged)
        tf.textColor = UIColor.textBlack
        tf.placeholderColor = UIColor.appGrey
        tf.lineColor = UIColor.appGrey
        tf.selectedLineColor = UIColor.textBlack
        tf.selectedTitleColor = UIColor.appGrey
        tf.lineHeight = 1.0
        tf.selectedLineHeight = 1.0
        tf.autocapitalizationType = .words
        tf.autocorrectionType = .no
        return tf
    }()
    
    lazy var emailTextField: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField()
        tf.titleFormatter = { $0 }
        tf.selectedTitle =  "Email"
        tf.placeholder =  "Email"
        tf.title =  "Email"
        tf.addTarget(self, action: #selector(handleInputChanged), for: .editingChanged)
        tf.textColor = UIColor.textBlack
        tf.placeholderColor = UIColor.appGrey
        tf.lineColor = UIColor.appGrey
        tf.selectedLineColor = UIColor.textBlack
        tf.selectedTitleColor = UIColor.appGrey
        tf.lineHeight = 1.0
        tf.selectedLineHeight = 1.0
        tf.autocapitalizationType = .none
        tf.keyboardType = .emailAddress
        tf.autocorrectionType = .no
        return tf
    }()
    
    lazy var dobTextField: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField()
        tf.titleFormatter = { $0 }
        tf.selectedTitle =  "Date of Birth"
        tf.placeholder =  "Date of Birth"
        tf.title =  "Date of Birth"
        tf.loadDatePicker()
        tf.addTarget(self, action: #selector(handleInputChanged), for: .editingChanged)
        tf.textColor = UIColor.textBlack
        tf.placeholderColor = UIColor.appGrey
        tf.lineColor = UIColor.appGrey
        tf.selectedLineColor = UIColor.textBlack
        tf.selectedTitleColor = UIColor.appGrey
        tf.lineHeight = 1.0
        tf.selectedLineHeight = 1.0
        return tf
    }()
    
    lazy var phoneTextField: SkyFloatingLabelTextField = {
        let tf = SkyFloatingLabelTextField()
        tf.titleFormatter = { $0 }
        tf.selectedTitle =  "Phone Number"
        tf.placeholder =  "Phone Number"
        tf.title =  "Phone Number"
        tf.addTarget(self, action: #selector(handleInputChanged), for: .editingChanged)
        tf.textColor = UIColor.textBlack
        tf.placeholderColor = UIColor.appGrey
        tf.lineColor = UIColor.appGrey
        tf.selectedLineColor = UIColor.textBlack
        tf.selectedTitleColor = UIColor.appGrey
        tf.lineHeight = 1.0
        tf.selectedLineHeight = 1.0
        tf.autocapitalizationType = .words
        tf.keyboardType = .phonePad
        return tf
    }()
    
    lazy var maleButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(maleBtnTapped), for: .touchUpInside)
        button.setTitle("Male", for: .normal)
        button.setTitleColor(UIColor.textBlack, for: .normal)
        button.backgroundColor = UIColor.lineOffGrey
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    lazy var femaleButton: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(femaleBtnTapped), for: .touchUpInside)
        button.setTitle("Female", for: .normal)
        button.setTitleColor(UIColor.textBlack, for: .normal)
        button.backgroundColor = UIColor.lineOffGrey
        button.layer.cornerRadius = 4.0
        button.layer.masksToBounds = true
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
     */
    
    weak var delegate: TravelerInfoCellDelegate?
    
    var travelerInfo: TravelerInfo? {
        didSet {
            guard let travelerInfo = travelerInfo else { return }
            self.setFormTitle(travelerType: travelerInfo.travelerType)
        }
    }
    
    
    var gender: String? {
        didSet {
            guard let gender = gender else { return }
            if gender == "Male" {
                self.maleButton.sendActions(for: .touchUpInside)
            } else if gender == "Female" {
                self.femaleButton.sendActions(for: .touchUpInside)
            }
        }
    }
    
    var isFormValid = false
    var cellIndex = 0
    
    /*
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupViews()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    */
    
    override func awakeFromNib() {
        super.awakeFromNib()
     
        setupViews()
    }
    
    
    fileprivate func setupViews() {
        
        [firstnameTextField, lastnameTextField, emailTextField, dobTextField, phoneTextField].forEach { (field) in
            field?.addTarget(self, action: #selector(handleInputChanged), for: .editingChanged)
        }
        
        dobTextField.loadDatePicker()
        
        maleButton.addTarget(self, action: #selector(maleBtnTapped), for: .touchUpInside)
        femaleButton.addTarget(self, action: #selector(femaleBtnTapped), for: .touchUpInside)
        maleButton.makeCornerRadius(cornerRadius: 4.0)
        femaleButton.makeCornerRadius(cornerRadius: 4.0)
        /*
        addSubview(passengerTitleLabel)

        let buttonStackView = UIStackView(arrangedSubviews: [maleButton, femaleButton])
        buttonStackView.axis = .horizontal
        buttonStackView.alignment = .fill
        buttonStackView.distribution = .fill
        buttonStackView.spacing = 10

        maleButton.heightAnchor.constraint(equalToConstant: 44)
        maleButton.widthAnchor.constraint(equalToConstant: 96)
        femaleButton.heightAnchor.constraint(equalToConstant: 44)
        femaleButton.widthAnchor.constraint(equalToConstant: 96)
        
        let fieldsStackView = UIStackView(arrangedSubviews: [firstnameTextField, lastnameTextField, emailTextField, dobTextField, phoneTextField, genderTitleLabel])
        fieldsStackView.axis = .vertical
        fieldsStackView.alignment = .fill
        fieldsStackView.distribution = .fill
        fieldsStackView.spacing = 16
        
        addSubview(fieldsStackView)
        addSubview(buttonStackView)
        
        passengerTitleLabel.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 16, bottom: 0, right: 16))
        fieldsStackView.anchor(top: passengerTitleLabel.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 24, bottom: 0, right: 16))
        buttonStackView.anchor(top: fieldsStackView.bottomAnchor, leading: fieldsStackView.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 202, height: 44))
        */
    }
    
    func setFormFieldValues(traveler: TravelerInfo) {
        self.firstnameTextField.text = traveler.bio.firstname
        self.lastnameTextField.text = traveler.bio.lastname
        self.emailTextField.text = traveler.email
        self.phoneTextField.text = traveler.phone
        self.dobTextField.text = traveler.bio.dateOfBirth
        self.gender = traveler.gender
    }
    
    fileprivate func setFormTitle(travelerType: PassengerType) {
        switch travelerType {
        case .adult:
            passengerTitleLabel.text = "Adult"
        case .child:
            passengerTitleLabel.text = "Child"
        case .infant:
            passengerTitleLabel.text = "Infant"
        case .infantWithSeat:
            passengerTitleLabel.text = "Infant On Seat"
        }
    }
    
    @objc func handleInputChanged() {
        guard var travelerInfo = self.travelerInfo else { return }
        if travelerInfo.travelerType == PassengerType.adult && cellIndex == 0 {
            isFormValid = firstnameTextField.text?.count ?? 0 > 0 && lastnameTextField.text?.count ?? 0 > 0 && emailTextField.text?.count ?? 0 > 0 && dobTextField.text?.count ?? 0 > 0 && phoneTextField.text?.count ?? 0 > 0 && self.travelerInfo?.gender.count ?? 0 > 0
        } else {
            isFormValid = firstnameTextField.text?.count ?? 0 > 0 && lastnameTextField.text?.count ?? 0 > 0 && dobTextField.text?.count ?? 0 > 0
        }
        
        if isFormValid {
            travelerInfo.bio.firstname = firstnameTextField.text  ?? ""
            travelerInfo.bio.lastname = lastnameTextField.text  ?? ""
            travelerInfo.bio.dateOfBirth = dobTextField.text ?? ""
            travelerInfo.email = emailTextField.text  ?? ""
            travelerInfo.phone = phoneTextField.text  ?? ""
            self.travelerInfo = travelerInfo
            self.delegate?.didCompleteForm(self, updatedTravelerInfo: travelerInfo)
        }
    }
    
    @objc func maleBtnTapped() {
        self.travelerInfo?.gender = "Male"
        
        maleButton.backgroundColor = UIColor.appRed
        maleButton.setTitleColor(.white, for: .normal)
        
        femaleButton.backgroundColor = UIColor.lineOffGrey
        femaleButton.setTitleColor(UIColor.textBlack, for: .normal)
        
        handleInputChanged()
    }
    
    @objc func femaleBtnTapped() {
        self.travelerInfo?.gender = "Female"
        femaleButton.backgroundColor = UIColor.appRed
        femaleButton.setTitleColor(.white, for: .normal)
        
        maleButton.backgroundColor = UIColor.lineOffGrey
        maleButton.setTitleColor(UIColor.textBlack, for: .normal)
        
        handleInputChanged()
    }
    
}
