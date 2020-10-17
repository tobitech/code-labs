//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

extension UITextField {
    func setLeftPaddingPoints(_ amount:CGFloat){
        let paddingView = UIView(frame: CGRect(x: 0, y: 0, width: amount, height: self.frame.size.height))
        self.leftView = paddingView
        self.leftViewMode = .always
    }
}

class MintSearchBar: UIView {
    private let pikeLayer = CAShapeLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .clear
        
        layer.addSublayer(pikeLayer)
        setupSearchBar()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        setupShapLayer()
    }
    
    private func setupShapLayer() {
        pikeLayer.frame = self.bounds
        pikeLayer.path = makePath()
        pikeLayer.fillColor = UIColor(red: 0.980, green: 0.961, blue: 0.922, alpha: 1.000).cgColor
    }
    
    private func makePath() -> CGPath {
        let path = UIBezierPath()
        path.move(to: CGPoint(x: 0, y: 12))
        
        path.addLine(to: CGPoint(x: self.bounds.width - 83.5, y: 12))
        path.addLine(to: CGPoint(x: self.bounds.width - 74.43, y: 1.8))
        path.addCurve(to: CGPoint(x: self.bounds.width - 68.5, y: 1.74), controlPoint1: CGPoint(x: self.bounds.width - 72.86, y: 0.03), controlPoint2: CGPoint(x: self.bounds.width - 70.11, y: 0))
        path.addLine(to: CGPoint(x: self.bounds.width - 59, y: 12))
        path.addLine(to: CGPoint(x: self.bounds.width, y: 12))
        path.addLine(to: CGPoint(x: self.bounds.width, y: 46))
        path.addLine(to: CGPoint(x: 0, y: 46))
        path.close()
        
        
        return path.cgPath
    }
    
    private func setupSearchBar() {
        let searchField = UITextField(frame: CGRect(x: 24, y: 17, width: self.frame.width - 48, height: 26))
        searchField.attributedPlaceholder = NSAttributedString(string: "Search Transactions", attributes: [NSAttributedString.Key.foregroundColor: UIColor(red: 105/256, green: 116/256, blue: 122/256, alpha: 1.0), NSAttributedString.Key.font: UIFont.systemFont(ofSize: 12)])
        searchField.font = UIFont.systemFont(ofSize: 12)
        searchField.textColor = UIColor(red: 105/256, green: 116/256, blue: 122/256, alpha: 1.0)
        searchField.layer.cornerRadius = 12
        searchField.layer.masksToBounds = true
        searchField.layer.borderColor = UIColor(red: 234, green: 236, blue: 240, alpha: 1.0).cgColor
        searchField.layer.borderWidth = 1.0
        searchField.backgroundColor = .white
        searchField.setLeftPaddingPoints(20)
        addSubview(searchField)
    }
}

class MyViewController : UIViewController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .black

        let searchBar = MintSearchBar(frame: CGRect(x: 0, y: 200, width: 375, height: 46))
        // label.text = "Hello World!"
        // label.textColor = .black
        
        view.addSubview(searchBar)
        self.view = view
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
