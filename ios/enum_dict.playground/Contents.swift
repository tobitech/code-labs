import UIKit

// source: - https://www.swiftbysundell.com/posts/enum-iterations-in-swift-42

// instead of doing this
// var dict: Dictionary<String, Any> = [:]
// dict["name"] = "Marcin"

// do this if it's closed set
enum Keys: String, CaseIterable {
    case name, address
}

// or this if it's open set
//struct Keys: Hashable {
//    private let rawValue: String
//    static let name = Keys(rawValue: "name")
//    static let address = Keys(rawValue: "address")
//}

// and you're safer
var dict: Dictionary<Keys, Any> = [:]
dict[.name] = "Marcin"


/* Enum Iterations in Swift 4.2 */
// Enum dictionaries
// e.g. 1
let string = NSAttributedString(
    string: "Hello, world!",
    attributes: [
        .foregroundColor: UIColor.red,
        .font: UIFont.systemFont(ofSize: 20)
    ])

// e.g. 2
enum TextType: CaseIterable {
    case title
    case subtitle
    case sectionTitle
    case body
    case comment
}

/*
let fonts: [TextType: UIFont] = [
    .title: .preferredFont(forTextStyle: .headline),
    .subtitle: .preferredFont(forTextStyle: .subheadline),
    .sectionTitle: .preferredFont(forTextStyle: .title2),
    .comment: .preferredFont(forTextStyle: .footnote)
]
 
we introduced a bug above since we missed out a text type case 'body'
*/

// after adding CaseIterable to the enum
// we can build our font dictionary without risk or missing out.
/*
var fonts = [TextType: UIFont]()

for type in TextType.allCases {
    switch type {
    case .title:
        fonts[type] = .preferredFont(forTextStyle: .headline)
    case .subtitle:
        fonts[type] = .preferredFont(forTextStyle: .subheadline)
    case .sectionTitle:
        fonts[type] = .preferredFont(forTextStyle: .title2)
    case .body:
        fonts[type] = .preferredFont(forTextStyle: .body)
    case .comment:
        fonts[type] = .preferredFont(forTextStyle: .footnote)
    }
}
*/

// This will be of type UIFont?, which is not always convenient
// let titleFont = fonts[.title]
// print(titleFont?.pointSize)

struct EnumMap<Enum: CaseIterable & Hashable, Value> {
    private let values: [Enum: Value]
    
    init(resolver: (Enum) -> Value) {
        var values = [Enum: Value]()
        
        for key in Enum.allCases {
            values[key] = resolver(key)
        }
        
        self.values = values
    }
    
    subscript(key: Enum) -> Value {
        // Here we have to force-unwrap, since there's no way
        // of telling the compiler that a value will always exist
        // for any given key. However, since it's kept private
        // it should be fine - and we can always add tests to
        // make sure things stay safe.
        return values[key]!
    }
}

let fonts = EnumMap<TextType, UIFont> { type in
    switch type {
    case .title:
        return .preferredFont(forTextStyle: .headline)
    case .subtitle:
        return .preferredFont(forTextStyle: .subheadline)
    case .sectionTitle:
        return .preferredFont(forTextStyle: .title2)
    case .body:
        return .preferredFont(forTextStyle: .body)
    case .comment:
        return .preferredFont(forTextStyle: .footnote)
    }
}

// This will be of type UIFont?, which is not always convenient
 let titleFont = fonts[.title]
let subtitle = fonts[.subtitle]
 print(titleFont.pointSize)


// Many cases for iterations
class ProductListViewController: UIViewController {
    
    private var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}

extension ProductListViewController {
    enum Section: String, CaseIterable {
        case featured
        case onSale
        case categories
        case saved
    }
}

class FeaturedProductCell: UITableViewCell {
}

class ProductCell: UITableViewCell {
}

class CategoryCell: UITableViewCell {
}

class BookmarkCell: UITableViewCell {
}

extension ProductListViewController {
    func registerCellClasses() {
        let resolver: (Section) -> UITableViewCell.Type = { section in
            switch section {
            case .featured:
                return FeaturedProductCell.self
            case .onSale:
                return ProductCell.self
            case .categories:
                return CategoryCell.self
            case .saved:
                return BookmarkCell.self
            }
        }
        
        for section in Section.allCases {
            tableView.register(resolver(section),
                               forCellReuseIdentifier: section.rawValue)
        }
    }
}

extension UITableView {
    func registerCellClasses<T: CaseIterable & RawRepresentable>(
        for sectionType: T.Type,
        using resolver: (T) -> UITableViewCell.Type
        ) where T.RawValue == String {
        for section in sectionType.allCases {
            register(resolver(section), forCellReuseIdentifier: section.rawValue)
        }
    }
}
