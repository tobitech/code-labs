//
//  CustomSegmentedControl.swift
//  Trajilis
//
//  Created by Oluwatobi Omotayo on 06/09/2019.
//  Copyright © 2019 Oluwatobi Omotayo. All rights reserved.
//

import UIKit

@IBDesignable
class CustomSegmentedControl: UIControl {
    
    var buttons = [UIButton]()
    let selector = UIView()
    
    var selectedSegmentIndex = 0 {
        didSet {
            if selectedSegmentIndex <= buttons.count - 1 {
                let button = self.buttons[selectedSegmentIndex]
                animateButton(button: button)
            }
        }
    }
    
    /// This is to cater for table view headers.
    /// Inconsistence issues with frame after table view reloads
    /// When setting this property, make sure to subtract any layout margins
    /// added to the control.
    var initialWidth: CGFloat?
    
    @IBInspectable
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable
    var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable
    var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    var selectorCornerRadius: CGFloat = 0 {
        didSet {
            selector.layer.cornerRadius = cornerRadius
            selector.layer.masksToBounds = true
        }
    }
    
    @IBInspectable
    var titles: String = "" {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var images: String = "" {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var subtitles: String = "" {
        didSet {
            updateView()
        }
    }
    
    // MARK: - Colors
    
    @IBInspectable
    var textColor: UIColor = .lightGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var selectorColor: UIColor = .darkGray {
        didSet {
            updateView()
        }
    }
    
    @IBInspectable
    var selectedTextColor: UIColor = .white {
        didSet {
            updateView()
        }
    }
    
    var selectorViewLeftAnchorConstraint: NSLayoutConstraint?
    
    func updateView() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        let buttonTitles = titles.components(separatedBy: ",").filter { !$0.isEmpty }
        let buttonSubtitles = subtitles.components(separatedBy: ",").filter { !$0.isEmpty }
        let buttonImages = images.components(separatedBy: ",").filter { !$0.isEmpty }
        
        for (titleIndex, buttonTitle) in buttonTitles.enumerated() {
            let button = UIButton(type: .system)
            button.titleLabel?.font = UIFont.ptSansRegular(with: 16)
            if buttonSubtitles.count > 0, buttonTitles.count == buttonSubtitles.count {
                self.setAttributedTextTitle(button: button, index: titleIndex)
            } else {
                button.setTitle(buttonTitle, for: .normal)
                button.setTitleColor(titleIndex == selectedSegmentIndex ? selectedTextColor : textColor, for: .normal)
            }
            
            if buttonImages.count > 0, buttonImages.count == buttonTitles.count {
                let imageName = buttonImages[titleIndex]
                let image = UIImage(named: imageName)
                button.setImage(image, for: .normal)
                button.tintColor = titleIndex == selectedSegmentIndex ? selectedTextColor : textColor
                button.imageView?.contentMode = .scaleToFill
                button.imageEdgeInsets = .init(top: 0, left: 0, bottom: 0, right: 16)
                button.titleEdgeInsets = .init(top: 0, left: 16, bottom: 0, right: 0)
            }
            
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        addSubview(selector)
        selector.translatesAutoresizingMaskIntoConstraints = false
        
        selectorViewLeftAnchorConstraint = selector.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 2)
        selectorViewLeftAnchorConstraint?.isActive = true
        selector.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        selector.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        let multiplier = 1/CGFloat(buttonTitles.count)
        selector.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: multiplier).isActive = true
        
        selector.layer.cornerRadius = selectorCornerRadius
        selector.backgroundColor = selectorColor
        
        
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillEqually
        sv.spacing = 0
        
        addSubview(sv)
        sv.backgroundColor = .clear
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = self.cornerRadius
    }
    
    fileprivate func animateSelectorAndFormatTitle(_ buttonIndex: Int, _ btn: UIButton) {
        let width = initialWidth ?? frame.width
        let count = CGFloat(buttons.count)
        let selectorStartPosition = (width / count) * CGFloat(buttonIndex)
        
        UIView.animate(withDuration: 0.3) {
            // self.selector.frame.origin.x = selectorStartPosition + 4
            self.selectorViewLeftAnchorConstraint?.constant = selectorStartPosition
        }
    }
    
    @objc func buttonTapped(button: UIButton) {
        selectedSegmentIndex = buttons.index(of: button) ?? 0
        sendActions(for: .valueChanged)
    }
    
    private func animateButton(button: UIButton) {
        animateSelectorAndFormatTitle(selectedSegmentIndex, button)
        
        for (buttonIndex, btn) in buttons.enumerated() {
            // change tint color of the buttons, this will affect button image
            btn.tintColor = buttonIndex == selectedSegmentIndex ? selectedTextColor : textColor
            self.setAttributedTextTitle(button: btn, index: buttonIndex)
        }
    }
    
    private func setAttributedTextTitle(button: UIButton, index: Int) {
        let color = index == selectedSegmentIndex ? selectedTextColor : textColor
        let paragraph = NSMutableParagraphStyle()
        paragraph.alignment = .center
        button.titleLabel?.numberOfLines = 2
        let buttonTitles = titles.components(separatedBy: ",")
        let buttonSubtitles = subtitles.components(separatedBy: ",")
        if buttonSubtitles.count > 0, buttonTitles.count == buttonSubtitles.count {
            let titleAttributedText = NSMutableAttributedString(string: buttonTitles[index] + "\n", attributes: [NSAttributedString.Key.font: UIFont(name: "PTSans-Bold", size: 16) ?? UIFont.boldSystemFont(ofSize: 16), NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.paragraphStyle: paragraph])
            titleAttributedText.append(NSAttributedString(string: buttonSubtitles[index], attributes: [NSAttributedString.Key.font: UIFont(name: "PTSans-Regular", size: 10) ?? UIFont.systemFont(ofSize: 10), NSAttributedString.Key.foregroundColor: color, NSAttributedString.Key.paragraphStyle: paragraph]))
            button.setAttributedTitle(titleAttributedText, for: .normal)
        } else {
            button.setTitleColor(index == selectedSegmentIndex ? selectedTextColor : textColor, for: .normal)
            button.tintColor = index == selectedSegmentIndex ? selectedTextColor : textColor
        }
    }
    
    func setEnabled(_ enabled: Bool, forSegmentAt: Int) {
        if forSegmentAt <= buttons.count - 1 {
            let button = buttons[forSegmentAt]
            button.isEnabled = enabled
        } else {
            fatalError ("Index out of range")
        }
    }
    
}
