//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class CustomSegmentedControl: UIControl {
    
    var buttons = [UIButton]()
    var selector: UIView!
    var selectedSegmentedIndex = 0
    
    var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    var commaSeparatedButtonTitles: String = "" {
        didSet {
            updateView()
        }
    }
    
    var textColor: UIColor = .lightGray {
        didSet {
            updateView()
        }
    }
    
    var selectorColor: UIColor = .darkGray {
        didSet {
            updateView()
        }
    }
    
    var selectorTextColor: UIColor = .white {
        didSet {
            updateView()
        }
    }
    
    func updateView() {
        buttons.removeAll()
        subviews.forEach { $0.removeFromSuperview() }
        
        let buttonTitles = commaSeparatedButtonTitles.components(separatedBy: ",")
        for buttonTitle in buttonTitles {
            let button = UIButton(type: .system)
            button.setTitle(buttonTitle, for: .normal)
            button.setTitleColor(textColor, for: .normal)
            button.addTarget(self, action: #selector(buttonTapped(button:)), for: .touchUpInside)
            buttons.append(button)
        }
        
        buttons[0].setTitleColor(selectorTextColor, for: .normal)
        
        let selectorWidth = frame.width / CGFloat(buttonTitles.count)
        selector = UIView(frame: CGRect(x: 0, y: 0, width: selectorWidth, height: frame.height))
        selector.layer.cornerRadius = frame.height / 2
        selector.backgroundColor = selectorColor
        addSubview(selector)
        
        let sv = UIStackView(arrangedSubviews: buttons)
        sv.axis = .horizontal
        sv.alignment = .fill
        sv.distribution = .fillProportionally
        
        addSubview(sv)
        sv.translatesAutoresizingMaskIntoConstraints = false
        sv.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
        sv.bottomAnchor.constraint(equalTo: self.bottomAnchor).isActive = true
        sv.leftAnchor.constraint(equalTo: self.leftAnchor).isActive = true
        sv.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
    }
    
    override func draw(_ rect: CGRect) {
        layer.cornerRadius = frame.height / 2
    }
    
    @objc func buttonTapped(button: UIButton) {
        for (buttonIndex, btn) in buttons.enumerated() {
            btn.setTitleColor(textColor, for: .normal)
            
            if btn == button {
                selectedSegmentedIndex = buttonIndex
                let selectorStartPosition = frame.width / CGFloat(buttons.count) * CGFloat(buttonIndex)
                UIView.animate(withDuration: 0.3) {
                    self.selector.frame.origin.x = selectorStartPosition
                }
                
                btn.setTitleColor(selectorTextColor, for: .normal)
            }
        }
        
        sendActions(for: .valueChanged)
    }
    
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .gray

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        let segmentedControl = CustomSegmentedControl()
        segmentedControl.backgroundColor = .clear
        segmentedControl.borderColor = .red
        segmentedControl.frame = CGRect(x: 50, y: 250, width: 300, height: 55)
        segmentedControl.borderWidth = 2.0
        segmentedControl.commaSeparatedButtonTitles = "Public,Followers,Private"
        
        view.addSubview(label)
        view.addSubview(segmentedControl)
        
        self.view = view
    }
    
    @objc func customSegmentValueChanged(_ sender: CustomSegmentedControl) {
        switch sender.selectedSegmentedIndex {
        case 0:
            print("I am the first")
        case 1:
            print("I am the second")
        case 2:
            print("I am the third")
        default:
            print("anything")
        }
    }
    
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()


