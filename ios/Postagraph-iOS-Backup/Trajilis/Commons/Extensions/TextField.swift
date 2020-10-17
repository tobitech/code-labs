import UIKit

extension UITextField {
    
    func loadPickerViewForCustomView(data: [Any], onSelect selectionHandler: @escaping ((_ selectedObject: Any?) -> Void), onDisplay  handlerForCustomView: @escaping ((_ data: Any?, _ view: UIView?) -> UIView)) {
        
        self.inputView = PickerView(data: data, pickerTextField: self, selectionHandler: selectionHandler, handlerForCustomView: handlerForCustomView)
    }
    
    func loadPickerViewString(data: [Any], onSelect selectionHandler: @escaping ((_ selectedObject: Any) -> Void), onDisplay handlerForTitle: @escaping ((_ data: Any) -> String)) {
        let piker = PickerView(data: data, pickerTextField: self, selectionHandler: selectionHandler, handlerForTitle: handlerForTitle)
        self.inputView = piker
    }
    
    func loadPickerViewString(data: [Any], onSelect selectionHandler: @escaping ((_ selectedObject: Any, _ index: Int) -> Void), onDisplay handlerForTitle: @escaping ((_ data: Any) -> String)) {
        let piker = PickerView(data: data, pickerTextField: self, selectionHandler: selectionHandler, handlerForTitle: handlerForTitle)
        self.inputView = piker
    }
    
    func loadDatePicker() {
        let picker = UIDatePicker()
        picker.datePickerMode = .date
        picker.addTarget(self, action: #selector(dateChange(value:)), for: .valueChanged)
        self.inputView = picker
    }
    
    @objc private func dateChange(value: UIDatePicker) {
        if value.date >= Date() {
            if var topController = UIApplication.shared.keyWindow?.rootViewController {
                while let presentedViewController = topController.presentedViewController {
                    topController = presentedViewController
                }
                    topController.showAlert(message: "Invalid date selected")
            }
            return
        }else {
            self.text = value.date.toString(dateFormat: "yyyy-MM-dd", dateStyle: DateFormatter.Style.medium)
        }
    }
}


extension UITextField {
    
    func setLeftPaddingPoints(_ value: CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width:  value, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
    func setRightPaddingPoints(_ value: CGFloat) {
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: value, height: self.frame.size.height))
        self.rightView = paddingView
        self.rightViewMode = .always
    }
    
    @IBInspectable var placeholderColour: UIColor? {
        get {
            return self.placeholderColour
        }
        set {
            self.attributedPlaceholder = NSAttributedString(string: self.placeholder != nil ? self.placeholder! : "", attributes: [NSAttributedString.Key.foregroundColor: newValue!])
        }
    }
}
