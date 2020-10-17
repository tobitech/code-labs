//: A UIKit based Playground for presenting user interface
  
import UIKit
import PlaygroundSupport
import SwiftSpinner
import Alamofire

class LoadingViewController: UIViewController {
    
    private lazy var activityIndicator = UIActivityIndicatorView(style: .gray)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .white
    activityIndicator.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(activityIndicator)

        NSLayoutConstraint.activate([
            activityIndicator.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            activityIndicator.centerYAnchor.constraint(equalTo: view.centerYAnchor)
            ])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) { [weak self] in
            self?.activityIndicator.startAnimating()
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // We use a 0.5 second delay to not show an activity indicator
        // in case our data loads very quickly.
//        DispatchQueue.main.asyncAfter(deadline: .now() + 0.0) { [weak self] in
//            self?.activityIndicator.startAnimating()
//        }
    }
    
}

// methods for adding and removing child view controllers.

@nonobjc extension UIViewController {
    func add(_ child: UIViewController, frame: CGRect? = nil) {
        addChild(child)
        
        if let frame = frame {
            child.view.frame = frame
        }
        
        view.addSubview(child.view)
        child.didMove(toParent: self)
    }
    
    func remove() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}

/*
extension UIViewController {
    func add(_ child: UIViewController) {
        addChild(child)
        view.addSubview(child.view)
        child.view.frame = view.frame
        child.didMove(toParent: self)
    }
    
    func remove() {
        // Just to be safe, we check that this view controller
        // is actually added to a parent before removing it.
        guard parent != nil else {
            return
        }
        
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
*/

class MyViewController : UITabBarController {
    override func loadView() {
        let view = UIView()
        view.backgroundColor = .white

        let label = UILabel()
        label.frame = CGRect(x: 150, y: 200, width: 200, height: 20)
        label.text = "Hello World!"
        label.textColor = .black
        
        view.addSubview(label)
        self.view = view
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        let loadingViewController = LoadingViewController()
        add(loadingViewController, frame: view.frame)
        AF.request("http://www.youtube.com").response { response in
            print(String(describing: response.response))
            loadingViewController.remove()
        }
    }
    
}
// Present the view controller in the Live View window
PlaygroundPage.current.liveView = MyViewController()
