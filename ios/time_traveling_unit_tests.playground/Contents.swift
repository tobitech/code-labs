import UIKit
import XCTest

class Cache<T> {
    private let dateGenerator: () -> Date
    private var registrations = [String: Registration<T>]()
    
    init(dateGenerator: @escaping () -> Date = Date.init) {
        self.dateGenerator = dateGenerator
    }
    
    func cache(_ object: T, forKey key: String) {
        let currentDate = dateGenerator()
        let endDate = currentDate.addingTimeInterval(60 * 60 * 24)
        registrations[key] = Registration(object: object, endDate: endDate)
    }
    
    func object(forKey key: String) -> T? {
        guard let registration = registrations[key] else {
            return nil
        }
        
        let currentDate = dateGenerator()
        
        guard registration.endDate >= currentDate else {
            registrations[key] = nil
            return nil
        }
        
        return registration.object
    }
}

struct Registration<T> {
    var endDate: Date
    var object: T
    
    init(object: T, endDate: Date) {
        self.endDate = endDate
        self.object = object
    }
}
// ---- Let's test this ----
// * Add an object to the cache.
// * Verify that the object is indeed cached.
// * Time travel 24 hours into the future.
// * Verify that the object is no longer cached.

class TimeTraveler {
    private var date = Date()
    
    func travel(by timeInterval: TimeInterval) {
        date = date.addingTimeInterval(timeInterval)
    }
    
    func generateDate() -> Date {
        return date
    }
}

// Setup a simple object class that we can insert into the cache
class Object: Equatable {
    static func == (lhs: Object, rhs: Object) -> Bool {
        // For equality, check that two objects are the same instance
        return lhs === rhs
    }
}

class CacheTests: XCTestCase {
    func testValidation() {
        // Setup time traveler, cache and object instances
        let timeTraveler = TimeTraveler()
        let cache = Cache<Object>(dateGenerator: timeTraveler.generateDate)
        let object = Object()
        
        // Verify that the object is indeed cached when inserted
        cache.cache(object, forKey: "key")
        XCTAssertEqual(cache.object(forKey: "key"), object)
        
        // Time travel 24 hours (+ 1 second) into the future
        timeTraveler.travel(by: 60 * 60 * 24 + 1)
        
        // Verify that the object is now discarded
        XCTAssertNil(cache.object(forKey: "key"))
    }
}

XCTestSuite.default.run()
