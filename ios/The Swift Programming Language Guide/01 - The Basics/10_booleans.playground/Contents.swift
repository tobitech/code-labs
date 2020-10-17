import UIKit

/*
 Booleans:
 
 Boolean values are referred to as logical, because they can only ever be true or false.
 */

let orangesAreOrange = true
let turnipsAreDelicious = false

/// Boolean values are particularly useful when you work with conditional statements
/// such as if statement:
if turnipsAreDelicious {
    print("Mmm, tasty turnips")
} else {
    print("Eww, turnips are horrible")
}

/// Swift’s type safety prevents non-Boolean values from being substituted for Bool.
/// The following example reports a compile-time error
let i = 1
// if i {
    // this example will not compile, and will report an error
// }

// this is valid
if i == 1 {
    // this example will compile successfully
}

