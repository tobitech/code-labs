import UIKit

// Designing Swift APIs
// Ref: https://www.swiftbysundell.com/posts/designing-swift-apis

/** Context and call sites **/

struct ShoppingCart {
    // appropriate use of "removing parameter label"
    mutating func add(_ product: Product) {
        //...
    }
}

struct Product {
    
}

var cart = ShoppingCart()

// example
let product = Product()
cart.add(product)

struct Address {
    let city: String
}

struct Price {
    let value: Double
    let currency: String
}

struct User {
    let address: Address
}

extension ShoppingCart {
    // parameter name is need here
    func calculateTotalPrice(shippingTo address: Address) -> Price {
        let price = Price(value: 5.99, currency: "$")
        return price
    }
}

let address = Address(city: "Ikeja")
let user = User(address: address)

let price = cart.calculateTotalPrice(shippingTo: user.address)
print(price.value)


/** Nested Types and Overloads **/

// defining context for types
extension Product {
    struct Bundle {
        var name: String
        var products: [Product]
    }
}

// overload method here.
extension ShoppingCart {
    mutating func add(_ bundle: Product.Bundle) {
        bundle.products.forEach { add($0) }
    }
}


/** Strong typing **/
"""
let’s instead introduce a dedicated Coupon type — which will in turn contain the string-based code as a property.
"""

struct Coupon {
    let code: String
}

extension ShoppingCart {
    mutating func apply(_ coupon: Coupon) {
        print(coupon.code)
    }
}

cart.apply(Coupon(code: "spring-sale"))


/** Scalable APIs **/
// Image transformer
/*
struct ImageTransformer {
    func transform(
        _ image: UIImage,
        scaleBy scale: CGVector = .zero,
        rotateBy angle: Measurement<UnitAngle> = .zero,
        tintWith color: UIColor? = nil
        ) -> UIImage {
        ...
    }
}
*/

struct ImageTransformer {
    func transform(_ image: UIImage, scaleBy scale: CGVector = .zero, rotateBy angle: Measurement<UnitAngle> = .zero, tintWith color: UIColor? = nil) -> UIImage {
        // ...
        return UIImage()
    }
}

// To enable us to simply use '.zero' to create a
// Mesaurement instance above, we'll add this extension:
extension Measurement where UnitType: Dimension {
    static var zero: Measurement {
        return Measurement(value: 0, unit: .baseUnit())
    }
}


// rotate an image
let image = UIImage()
let transformer = ImageTransformer()
let angle = Measurement<UnitAngle>(value: 180, unit: .degrees)
transformer.transform(image, rotateBy: angle)

// scale and tint image.
let scale = CGVector(dx: 0.5, dy: 1.2)
transformer.transform(image, scaleBy: scale, tintWith: .blue)

// Apply all supported transforms to an image.
transformer.transform(image,
                      scaleBy: scale,
                      rotateBy: angle,
                      tintWith: .blue
)


/** Convinience Wrappers **/

enum DialogKind {
    case alert
    case confirmation
}

enum DialogAction {
    case cancel
    case confirm
}

class DialogViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension UIViewController {
    func presentDialog(ofKind kind: DialogKind, title: String, text: String, actions: [DialogAction]) {
        let dialog = DialogViewController()
        // ...
        present(dialog, animated: true)
    }
}

struct DialogQuestion {
    let title: String
    let explanation: String
    let actions: [DialogAction]
}

extension UIViewController {
    func presentConfirmation(for question: DialogQuestion) {
        presentDialog(ofKind: .confirmation,
                      title: question.title,
                      text: question.explanation,
                      actions: [
                        [
                            question.actions.cancel,
                            question.actions.confirm,
                        ]
        )
    }
}
