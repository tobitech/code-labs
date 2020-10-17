import UIKit

/*
 Assertions and Preconditions:
 
 Assertions and preconditions are checks that happen at runtime.
 You use them to make sure an essential condition is satisfied
 before executing any further code. If the Boolean condition in the assertion or
 precondition evaluates to true, code execution continues as usual.
 If the condition evaluates to false, the current state of the program is invalid;
 code execution ends, and your app is terminated.
 
 Assertions help you find mistakes and incorrect assumptions during development,
 and preconditions help you detect issues in production.
 
 Stopping execution as soon as an invalid state is detected also helps limit the damage caused by that invalid state.
 
 The difference between assertions and preconditions is in when they’re checked:
 Assertions are checked only in debug builds, but preconditions are checked in both debug and production builds
 */

// MARK: - Debugging with Assertions
/// You write an assertion by calling the assert(_:_:file:line:) function from the Swift standard library.
let age = -3
assert(age >= 0, "A person's age can't be less than zero.")
// This assertion fails because -3 is not >= 0.

/// If the code already checks the condition,
/// you use the assertionFailure(_:file:line:) function to indicate that an assertion has failed
if age > 10 {
    print("You can ride the roller-coaster or the ferris wheel.")
} else if age >= 0 {
    print("You can ride the ferris wheel.")
} else {
    assertionFailure("A person's age can't be less than zero.")
}


// MARK: - Enforcing Preconditions
/// Use a precondition whenever a condition has the potential to be false,
/// but must definitely be true for your code to continue execution.
/// For example, use a precondition to check that a subscript is not out of bounds,
/// or to check that a function has been passed a valid value.
/// You write a precondition by calling the precondition(_:_:file:line:) function.
// In the implementation of a subscript...
let index = 10
precondition(index > 0, "Index must be greater than zero.")

/// NOTE
/// If you compile in unchecked mode (-Ounchecked), preconditions aren’t checked.
/// However, the fatalError(_:file:line:) function always halts execution, regardless of optimization settings.


