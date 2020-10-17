
import UIKit

class PickerView: UIPickerView{
    
    var handlerForCustomView: ((_ data: Any, _ view: UIView?) -> UIView)?
    var handlerForTitle: ((_ data: Any) -> String)?
    var selectionHandler: ((_ selectedObject: Any) -> Void)?
    var selectionHandlerWithIndex: ((_ selectedObject: Any, _ index: Int) -> Void)?
    var data = [Any]()
    
    init(data: [Any], pickerTextField: UITextField, selectionHandler: @escaping ((_ selectedObject: Any) -> Void), handlerForCustomView: @escaping ((_ data: Any, _ view: UIView?) -> UIView)) {
        super.init(frame: CGRect.zero)
        
        self.data = data
        self.handlerForCustomView = handlerForCustomView
        self.selectionHandler = selectionHandler
        
        customize()
    }
    
    init(data: [Any], pickerTextField: UITextField, selectionHandler: @escaping ((_ selectedObject: Any) -> Void), handlerForTitle: @escaping ((_ data: Any) -> String)) {
        super.init(frame: CGRect.zero)
        
        self.data = data
        self.handlerForTitle = handlerForTitle
        self.selectionHandler = selectionHandler
        
        customize()
    }
    
    init(data: [Any], pickerTextField: UITextField, selectionHandler: @escaping ((_ selectedObject: Any, _ index: Int) -> Void), handlerForTitle: @escaping ((_ data: Any) -> String)) {
        super.init(frame: CGRect.zero)
        
        self.data = data
        self.handlerForTitle = handlerForTitle
        self.selectionHandlerWithIndex = selectionHandler
        
        customize()
    }
    
    
    func customize() {
        self.delegate = self
        self.dataSource = self
        self.backgroundColor = .white
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
}

extension PickerView: UIPickerViewDataSource {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return data.count
    }
    
    func pickerView(_ pickerView: UIPickerView, viewForRow row: Int, forComponent component: Int, reusing view: UIView?) -> UIView
    {
        if handlerForCustomView == nil {
            let record = handlerForTitle!(data[row])
            var label: UILabel
            
            if view == nil {
                label = UILabel()
                label.text = record
                label.textAlignment = .center
            }else {
                label = view as! UILabel
                label.text = record
            }
            
            return label
        }
        return handlerForCustomView!(data[row], view)
    }
}

extension PickerView: UIPickerViewDelegate {
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if data.count > 0 {
            let selct = data[row]
            
            if let handle = selectionHandler {
                handle(selct)
            } else if let handle = selectionHandlerWithIndex {
                handle(selct, row)
            }
            
        }
    }
}





