import UIKit
import PlaygroundSupport

/** Bindable values in Swift **/
// Constant Update.

struct User {
    let name: String
    let followersCount: Int
    let colors: Color
}

struct Color {
    let primary: UIColor
    let secondary: UIColor
}

class UserLoader {
    func load(closure: (_ user: User) -> ()) {
        let user = User(name: "Tobi Omotayo", followersCount: 235, colors: Color(primary: .black, secondary: .yellow))
        closure(user)
    }
}

class HeaderView: UIView {
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .blue
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ProfileViewController: UIViewController {
    
    private let userLoader: UserLoader
    private lazy var nameLabel = UILabel()
    private lazy var headerView = HeaderView()
    private lazy var followersLabel = UILabel()
    
    init(userLoader: UserLoader) {
        self.userLoader = userLoader
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white
        
        view.addSubview(nameLabel)
        nameLabel.text = "User's name"
        nameLabel.center = view.center
        
        self.view = view
    }
    
    override func viewWillAppear(_ animated: Bool) {
        userLoader.load { [weak self] user in
            self?.nameLabel.text = user.name
            self?.headerView.backgroundColor = user.colors.primary
            self?.followersLabel.text = String(user.followersCount)
        }
    }
    
    
}

let userLoader = UserLoader()
PlaygroundPage.current.liveView = ProfileViewController(userLoader: userLoader)
