import UIKit

/*
 Arithmetic Operators:
 */

/// Swift supports the four standard arithmetic operators for all number types:

// Addition (+)
// Subtraction (-)
// Multiplication (*)
// Division (/)

1 + 2 // equals 3
5 - 3 // equals 2
2 * 3 // equals 6
10.0 / 2.5 // equals 4.0


// The addition operator is also supported for String concatenation:

"hello, " + "world"  // equals "hello, world"

/// Unlike the arithmetic operators in C and Objective-C,
/// the Swift arithmetic operators don’t allow values to overflow by default.
/// You can opt in to value overflow behavior by using Swift’s overflow operators (such as a &+ b).
/// See Overflow Operators.


// MARK: - Remainder Operator
/// The remainder operator (a % b) works out how many multiples of b will fit inside a
/// and returns the value that is left over (known as the remainder).

/// NOTE
/// The remainder operator (%) is also known as a `modulo operator` in other languages.
/// However, its behavior in Swift for negative numbers means that, strictly speaking,
/// it’s a remainder rather than a modulo operation.

9 % 4 // equals 1

/// The sign of b is ignored for negative values of b.
/// This means that a % b and a % -b always give the same answer.
9 % -4 // equals 1

// but
-9 % 4 // equals -1


// MARK: - Unary Minus Operator
/// The sign of a numeric value can be toggled using a prefixed -,
/// known as the unary minus operator:
let three = 3
let minusThree = -three  // minusThree equals -3
let plusThree = -minusThree // plusThree equals 3, or "minus minus three"

// MARK: - Unary Plus Operator
/// The unary plus operator (+) simply returns the value it operates on, without any change:

let minusSix = -6
let alsoMinusSix = +minusSix  // alsoMinusSix equals -6
/// Although the unary plus operator doesn’t actually do anything,
/// you can use it to provide symmetry in your code for positive numbers when also using the unary minus operator for negative numbers.
