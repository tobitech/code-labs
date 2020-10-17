import UIKit

/*
 Range Operators:
 
 Swift includes several range operators, which are shortcuts for expressing a range of values.
 */

// MARK: - Closed Range Operator
/// (a...b), useful when interating over a range in which you want all the values to be used,
/// such as with a for-in loop
for index in 1...5 {
    print("\(index) times 5 is \(index * 5)")
}

//1 times 5 is 5
//2 times 5 is 10
//3 times 5 is 15
//4 times 5 is 20
//5 times 5 is 25

// MARK: - Half-Open Range Operator
/// (a..<b), are particularly useful when you work with zero-based lists such as arrays,
/// where it's useful to count up to (but not including) the length of the list
let names = ["Anna", "Alex", "Brian", "Jack"]
let count = names.count
for i in 0..<count {
    print("Person \(i + 1) is called \(names[i])")
}

//Person 1 is called Anna
//Person 2 is called Alex
//Person 3 is called Brian
//Person 4 is called Jack

// MARK: One-Side Ranges
/// This kind of range is called a one-sided range because the operator has a value on only one side.
for name in names[2...] {
    print(name)
}

//Brian
//Jack

for name in names[...2] {
    print(name)
}

//Anna
//Alex
//Brian

/// The half-open range operator also has a one-sided form that’s written with only its final value.
for name in names[..<2] {
    print(name)
}

//Anna
//Alex


/// One-sided ranges can be used in other contexts, not just in subscripts.
/// You can’t iterate over a one-sided range that omits a first value, because it isn’t clear where iteration should begin.
/// You can iterate over a one-sided range that omits its final value; however, because the range continues indefinitely, make sure you add an explicit end condition for the loop.

/// You can check whether a one-sided range contains a particular value
let range = ...5
range.contains(7) // false
range.contains(4) // true
range.contains(-1) // true
