import UIKit

/*
 Comparison Operator:
 */

/// Swift supports the following comparison operators:
// * equal to (a == b)
// * not equal to (a != b)
// * greater than (a > b)
// * less than (a < b)
// * greater than or equal to (a >= b)
// * less than or equal to (a <= b)


/// NOTE
/// Swift also provides two identity operators (=== and !==),
/// which you use to test whether two object references both refer to the same object instance.
/// For more information, see  `Identity Operators`.

// Each of the comparison operators returns a Bool value
// to indicate whether or not the statement is true
1 == 1 // true
2 != 1 // true
2 > 1 // true
1 < 2  // true
1 >= 1 // true
2 <= 1 // false

// Comparison operators are often use in conditional statements,
// such as the if statement
let name = "world"
if name == "world" {
    print("hello, world")
} else {
    print("I'm sorry \(name) but I don't recognize you")
}


/// You can compare two tuples if they have the same type and the same number of values.
/// Tuples are compared from left to right, one value at a time,
/// until the comparison finds two values that aren’t equal.
/// Those two values are compared, and the result of that comparison determines the overall result of the tuple comparison.
/// If all the elements are equal, then the tuples themselves are equal.
/// For example:
(1, "zebra") < (2, "apple") // true because 1 is less than 2; "zebra" and "apple" are no compared
(3, "apple") < (3, "bird") // true because "apple" is less than "bird", the first element in each are equal so they are skipped by the comparison.

(4, "dog") == (4, "dog") // true because 4 is equal to 4, and "dog" is equal to "dog"


/// Tuples can be compared with a given operator only if the operator can be applied to each value in the respective tuples.
("blue", -1) < ("purple", 1) // OK, evaluates to true
("blue", false) < ("purple", true) // Error because < can't comapare Boolean values
