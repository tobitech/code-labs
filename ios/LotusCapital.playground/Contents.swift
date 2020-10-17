//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport

class CreateSubAccountView: BaseView {
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.text = "Sub Accounts"
        label.font = UIFont.systemFont(ofSize: 24)
        label.textColor = UIColor.primaryColor
        return label
    }()
    
    let subtitleLabel: UILabel = {
        let label = UILabel()
        label.text = "Currently, you have two account created. Click on the icon below to create another sub-account."
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = UIColor.deepGrayColor
        label.numberOfLines = 0
        return label
    }()
    
    override func configure() {
        super.configure()
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(subtitleLabel)
        
        titleLabel.anchor(top: contentView.topAnchor, leading: contentView.leadingAnchor, bottom: nil, trailing: contentView.trailingAnchor, padding: .init(top: 8, left: 40, bottom: 0, right: 8))
        subtitleLabel.anchor(top: titleLabel.bottomAnchor, leading: titleLabel.leadingAnchor, bottom: nil, trailing: titleLabel.trailingAnchor, padding: .init(top: 12, left: 0, bottom: 0, right: 0))
    }
    
}

class MyViewController : UIViewController {
    override func loadView() {
        self.view = CreateSubAccountView()
    }
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
