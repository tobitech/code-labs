//
//  FloatingLabelTextField.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/14/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

protocol FloatingLabelTextFieldDelegate:class {
    func floatingLabelTextFieldDidChange(_ floatingLabelTextField: FloatingLabelTextField)
    func floatingLabelTextFieldDidBeginEditing(_ floatingLabelTextField: FloatingLabelTextField)
}

class FloatingLabelTextField: UIView {
    
    struct Mode {
        let textColor: UIColor
        let placeHolderColor: UIColor
        let floatingTitleColor: UIColor
        let lineColor: UIColor
        let iconTintColor: UIColor
        let errorColor: UIColor
        //        let icon: UIImage
        //        let placeHolderText: String
//        let titleText: String
        let font: UIFont
        
        static let empty: Mode = Mode(
            textColor: UIColor(hexString: "#505050"),
            placeHolderColor: UIColor(hexString: "#3F3F3F", alpha: 0.5),
            floatingTitleColor: UIColor(hexString: "#3F3F3F", alpha: 0.5),
            lineColor: UIColor(hexString: "#E5E5E5"),
            iconTintColor: UIColor(hexString: "#E5E5E5"),
            errorColor: UIColor(hexString: "#D63D41"),
            
            //            icon: UIImage(),
            //            placeHolderText: "",
//            titleText: "",
            font: UIFont(name: "PTSans-Regular", size: 16)!)
        
        static let selected: Mode = Mode(
            textColor: UIColor(hexString: "#505050"),
            placeHolderColor: UIColor(hexString: "#3F3F3F", alpha: 0.5),
            floatingTitleColor: UIColor(hexString: "#3F3F3F", alpha: 0.5),
            lineColor: UIColor(hexString: "#505050"),
            iconTintColor: UIColor(hexString: "#D63D41"),
            errorColor: UIColor(hexString: "#D63D41"),
            //            icon: UIImage(),
            //            placeHolderText: "",
//            titleText: "",
            font: UIFont(name: "PTSans-Regular", size: 16)!)
    }
    
    var normalMode: Mode = .empty {
        didSet {
            textEndEditing()
        }
    }
    var selectedMode: Mode = .selected
    weak var delegate: FloatingLabelTextFieldDelegate?
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private var iconImage: UIImageView!
    @IBOutlet var textField: UITextField!
    @IBOutlet private var bottomView: UIView!
    @IBOutlet private var textFieldImageGapConstraint: NSLayoutConstraint!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    
    @IBInspectable
    var text: String {
        get {
            return textField.text!
        }
        set {
            textField.text = newValue
            textEndEditing()
        }
    }
    
    @IBInspectable
    var lineIsHidden: Bool = false {
        didSet {
            bottomView.isHidden = lineIsHidden
        }
    }
    
    @IBInspectable
    var icon: UIImage = UIImage() {
        didSet {
            textEndEditing()
        }
    }
    
    @IBInspectable
    var placeHolderText: String = "" {
        didSet {
            textEndEditing()
        }
    }
    
    @IBInspectable
    var titleText: String = "" {
        didSet {
            textEndEditing()
        }
    }
    
    @IBInspectable
    var iconTextGap: CGFloat = 8 {
        didSet {
            textFieldImageGapConstraint.constant = iconTextGap
        }
    }
    
    var hasError: Bool = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    private func commonInit() {
        Bundle.main.loadNibNamed("FloatingLabelTextField", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.backgroundColor = .clear
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        configure(mode: normalMode)
        textField.addTarget(self, action: #selector(self.textChanged), for: UIControl.Event.editingChanged)
        textField.addTarget(self, action: #selector(self.textBeganEditing), for: UIControl.Event.editingDidBegin)
        textField.addTarget(self, action: #selector(self.textEndEditing), for: UIControl.Event.editingDidEnd)
    }
    
    @objc private func textChanged() {
        textEndEditing()
        delegate?.floatingLabelTextFieldDidChange(self)
    }
    
    @objc private func textBeganEditing() {
        textEndEditing()
        delegate?.floatingLabelTextFieldDidBeginEditing(self)
    }
    
    @objc private func textEndEditing() {
        configure(mode: textField.text!.isEmpty ? normalMode : selectedMode)
    }
    
    func configure(mode: Mode) {
        iconImage.tintColor = mode.iconTintColor
        textField.textColor = mode.textColor
        textField.font = mode.font
//        textFieldImageGapConstraint.constant = mode.iconTextGap
        
        iconImage.image = icon.withRenderingMode(.alwaysTemplate)
        textField.attributedPlaceholder = NSAttributedString(string: placeHolderText, attributes: [.foregroundColor: mode.placeHolderColor, .font: mode.font])
        
        titleLabel.text = titleText.isEmpty ? placeHolderText : titleText
        titleLabel.textColor = mode.floatingTitleColor
        titleLabel.font = mode.font.withSize(12)
        
        if hasError {
            bottomView.backgroundColor = mode.errorColor
            titleLabel.textColor = mode.errorColor
        }else if textField.isFirstResponder {
            bottomView.backgroundColor = selectedMode.lineColor
        }else {
            bottomView.backgroundColor = mode.lineColor
        }
        
        let titleShouldHide = textField.text!.isEmpty
        
        if titleShouldHide && titleLabel.isHidden {return}
        
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn, animations: {
           self.titleLabel.isHidden = titleShouldHide
            self.stackView.layoutIfNeeded()
        }) { (_) in
            self.titleLabel.isHidden = titleShouldHide
        }
    }
    
}
