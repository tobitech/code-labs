import UIKit

// How to use compactMap.

// Store
struct Store {
    let name: String
    var electronicHardware: [String]?
}



// Find all of the electronic items sold in the area.

let target = Store(name: "Target", electronicHardware: [
    "iPhone", "iPad", "FlatScreen TVs"
    ])

let bestBuys = Store(name: "Best Buys", electronicHardware: [
    "Laptops", "Big Fridges"
    ])

let bedBathAndBeyond = Store(name: "Bed Bath & Beyond", electronicHardware: nil)

//let items = target.electronicHardware! + bestBuys.electronicHardware! + bedBathAndBeyond.electronicHardware!

let items2 = [target, bestBuys, bedBathAndBeyond].compactMap{$0.electronicHardware}.flatMap{$0}

//print(items2)

extension Sequence where Iterator.Element: Hashable {
    func unique() -> [Iterator.Element] {
        var seen: [Iterator.Element: Bool] = [:]
        return self.filter { seen.updateValue(true, forKey: $0) == nil }
    }
}

let participants = [target.electronicHardware, bestBuys.electronicHardware]
var result = participants.compactMap {
    $0
}
result
print(result)
