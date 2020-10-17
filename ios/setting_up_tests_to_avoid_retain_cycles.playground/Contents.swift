import XCTest

protocol OptionsControllerDelegate: class {
    func didSelectOption(option: String, _ vc: OptionsController)
}

class OptionsController: UIViewController {
    
    weak var delegate: OptionsControllerDelegate?
    
    lazy var button: UIButton = {
        let button = UIButton(type: .system)
        button.addTarget(self, action: #selector(selectOption), for: .touchUpInside)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @objc func selectOption() {
        delegate?.didSelectOption(option: "2 Weeks", self)
    }
}

class FormController: UIViewController, OptionsControllerDelegate {
    func didSelectOption(option: String, _ vc: OptionsController) {
        print(option)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let optVC = OptionsController()
        optVC.delegate = self
    }
}

class DelegateMock: OptionsControllerDelegate {
    func didSelectOption(option: String, _ vc: OptionsController) {
        print("From Mock:", option)
    }
}

class SomeTests: XCTestCase {
    func testDelegateNotRetained() {
        let optionsController = OptionsController()
        
        // Assign the delegate (weak) and also retain it using a local variable
        var delegate: OptionsControllerDelegate? = DelegateMock()
        optionsController.delegate = delegate
        XCTAssertNotNil(optionsController.delegate)
        
        // Release the local var, which should also release the weak reference
        delegate = nil
        XCTAssertNil(optionsController.delegate)
    }
}

XCTestSuite.default.run()
