import UIKit

/// The case below shows when two classes depend on each other

class Account {
    
    // MARK: - Properties
    /// force unwrapping here is for convenience
    /// don't do it in production
    var plan: Plan!
}

/*
class Plan {
    
    // MARK: - Properties
    
    let account: Account
    
    // MARK: - Initialization
    
    init(account: Account) {
        self.account = account
    }
}
*/


/// use a weak reference to break reference cycle
/*
class Plan {
    
    // MARK: - Properties
    
    weak var account: Account?
    
    // MARK: - Initialization
    
    init(account: Account) {
        self.account = account
    }
}
*/

/// weak can become incovenient to use because it has to use an optional type.
/// we can use `unowned` instead
/// Note that unowned can be nil as well if the reference has been deallocated.
class Plan {
    
    // MARK: - Properties
    
    private(set) unowned var account: Account
    
    // MARK: - Initialization
    
    init(account: Account) {
        self.account = account
    }
}

