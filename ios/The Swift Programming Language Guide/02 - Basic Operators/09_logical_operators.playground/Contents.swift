import UIKit

/*
 Logical Operators:
 
 Logical operators modify or combine the Boolean logic values `true` and `false`.
 */

// Swift supports three standard logical operators found in C-based languages
// Logical NOT (!a)
// Logical AND (a && b)
// Logical OR (a || b)

// MARK: Logical NOT Operator
/// The logical NOT operator (!a) inverts a Boolean value so that true becomes false,
/// and false becomes true.
let allowedEntry = false
if !allowedEntry {
    print("ACCESS DENIED")
}
// print("ACCESS DENIED")


// MARK: Logical AND Operator
/// The logical AND operator (a && b) creates logical expressions
/// where both values must be true for the overall expression to also be true.

// Example:
let enteredDoorCode = true
let passedRetinaScan = false
if enteredDoorCode && passedRetinaScan {
    print("Welcome!")
} else {
    print("ACCESS DENIED")
}
// print("ACCESS DENIED")


// MARK: Logical OR Operator
/// The logical OR operator (a || b) is an infix operator made from two adjacent pipe characters.
/// You use it to create logical expressions in which only one of the two values has to be true for the overall expression to be true.

// Example
let hasDoorKey = false
let knowsOverridePassword = true
if hasDoorKey || knowsOverridePassword {
    print("Welcome!")
} else {
    print("ACCESS DENIED")
}
// Prints "Welcome!"


// MARK: - Combining Logical Operators
/// You can combine multiple logical operators to create longer compound expressions:
if enteredDoorCode && passedRetinaScan || hasDoorKey || knowsOverridePassword {
    print("Welcome!")
} else {
    print("ACCESS DENIED")
}
// Prints "Welcome!"

// MARK: - Explicit Parentheses
/// It’s sometimes useful to include parentheses when they’re not strictly needed,
/// to make the intention of a complex expression easier to read.
if (enteredDoorCode && passedRetinaScan) || hasDoorKey || knowsOverridePassword {
    print("Welcome!")
} else {
    print("ACCESS DENIED")
}
// Prints "Welcome!"
