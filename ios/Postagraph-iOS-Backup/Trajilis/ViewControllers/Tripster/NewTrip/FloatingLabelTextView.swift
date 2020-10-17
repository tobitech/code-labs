//
//  FloatingLabelTextView.swift
//  Trajilis
//
//  Created by bibek timalsina on 8/14/19.
//  Copyright © 2019 Perfect Aduh. All rights reserved.
//

import UIKit

protocol FloatingLabelTextViewDelegate:class {
    func floatingLabelTextViewDidChange(_ FloatingLabelTextView: FloatingLabelTextView)
    func floatingLabelTextViewShouldChangeHeight(_ FloatingLabelTextView: FloatingLabelTextView, toHeight height: CGFloat)
}

class FloatingLabelTextView: UIView {
    
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
    
    var mode: Mode = .empty {
        didSet {
            textEndEditing()
        }
    }
    var selectedMode: Mode = .selected
    
    weak var delegate: FloatingLabelTextViewDelegate?
    
    @IBOutlet private var contentView: UIView!
    @IBOutlet private weak var iconImage: UIImageView!
    @IBOutlet private weak var textView: UITextView!
    @IBOutlet private weak var bottomView: UIView!
    @IBOutlet private weak var textViewImageGapConstraint: NSLayoutConstraint!
    @IBOutlet private weak var titleLabel: UILabel!
    @IBOutlet private weak var stackView: UIStackView!
    @IBOutlet private weak var placeHolderLabel: UILabel!
    
    @IBInspectable
    var text: String {
        get {
            return textView.text
        }
        set {
            textView.text = newValue
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
            textViewImageGapConstraint.constant = iconTextGap
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
        Bundle.main.loadNibNamed("FloatingLabelTextView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = bounds
        contentView.backgroundColor = .clear
        contentView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        configure(mode: mode)
        textView.delegate = self
    }
    
    @objc private func textBeganEditing() {
        textEndEditing()
    }
    
    @objc private func textEndEditing() {
        let isEmpty = text.isEmpty
        placeHolderLabel.isHidden = !isEmpty
        configure(mode: isEmpty ? mode : selectedMode)
    }
    
    func configure(mode: Mode) {
        iconImage.tintColor = mode.iconTintColor
        textView.textColor = mode.textColor
        textView.font = mode.font
//        textViewImageGapConstraint.constant = mode.iconTextGap
        
        iconImage.image = icon.withRenderingMode(.alwaysTemplate)
        
        placeHolderLabel.text = placeHolderText
        placeHolderLabel.textColor = mode.placeHolderColor
        placeHolderLabel.font = mode.font
        
        titleLabel.text = titleText.isEmpty ? placeHolderText : titleText
        titleLabel.textColor = mode.floatingTitleColor
        titleLabel.font = mode.font.withSize(12)
        
        if hasError {
            bottomView.backgroundColor = mode.errorColor
            titleLabel.textColor = mode.errorColor
        }else if textView.isFirstResponder {
            bottomView.backgroundColor = selectedMode.lineColor
        }else {
            bottomView.backgroundColor = mode.lineColor
        }
        
        let titleShouldHide = textView.text.isEmpty
        
        if titleShouldHide && titleLabel.isHidden {return}
        
        UIView.animate(withDuration: 0.22, delay: 0, options: .curveEaseIn, animations: {
           self.titleLabel.isHidden = titleShouldHide
            self.stackView.layoutIfNeeded()
        }) { (_) in
            self.titleLabel.isHidden = titleShouldHide
        }
    }
    
    private var initialTextViewHeight: CGFloat?
    
}

extension FloatingLabelTextView: UITextViewDelegate {
    
    func textViewDidBeginEditing(_ textView: UITextView) {
        textBeganEditing()
    }
    
    func textViewDidEndEditing(_ textView: UITextView) {
        textEndEditing()
    }
    
    func textViewDidChange(_ textView: UITextView) {
        initialTextViewHeight = initialTextViewHeight ?? textView.frame.height
        textEndEditing()
        delegate?.floatingLabelTextViewDidChange(self)

        
        let textHeight = (textView.text as NSString).boundingRect(with: CGSize(width: textView.frame.width, height: 150), options: NSStringDrawingOptions.usesLineFragmentOrigin, attributes: [.font: textView.font!], context: nil).height
        let height = max(min(textHeight, 100), initialTextViewHeight!) + (lineIsHidden ? 0 : 1) + (text.isEmpty ? 0 : 14)
        
        delegate?.floatingLabelTextViewShouldChangeHeight(self, toHeight: height)
    }
    
}
