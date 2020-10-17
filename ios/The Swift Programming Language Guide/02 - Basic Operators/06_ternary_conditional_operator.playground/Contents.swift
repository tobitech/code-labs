import UIKit

/*
 Ternary Conditional Operator:
 
 The ternary conditional operator is a special operator with three parts,
 which takes the form question ? answer1 : answer2
 */

//  The ternary conditional operator is shorthand for the code below:

/*
if question {
    answer1
} else {
    answer2
}
*/

// Example:
let contentHeight = 40
let hasHeader = true
let rowHeight = contentHeight + (hasHeader ? 50 : 20)
// rowHeight is equal to 90

/// PS:
/// Avoid combining multiple instances of the ternary conditional operator into one compound statement.
