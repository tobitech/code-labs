import UIKit

/*
 Assignment Operator
 */

/// The assignment operator (a = b) initializes or updates the value of a with the value of b:
let b = 10
var a = 5
a = b
// a is now equal to b

/// If the right side of the assignment is a tuple with multiple values, its elements can be decomposed into multiple constants or variables at once:
let (x, y) = (1, 2)
// x is equal to 1, and y is equal to 2


/// Unlike the assignment operator in C and Objective-C, the assignment operator in Swift does not itself return a value.
// if x = y {
    // This is not valid, because x = y does not return a value.
// }
