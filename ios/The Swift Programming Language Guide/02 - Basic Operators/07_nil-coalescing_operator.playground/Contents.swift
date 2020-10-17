import UIKit

/*
 Nil-Coalescing Operator:
 
 The nil-coalescing operator (a ?? b) unwraps an optional `a` if it contains a value, or returns a default `b` if `a` is nil.
 */

// The nil-coalescing operator is a shorthand for the code below:
// a != nil ? a! : b

// Example:
let defaultColorName = "red"
var userDefinedColorName: String? // defaults to nil

var colorNameToUse = userDefinedColorName ?? defaultColorName
// userDefinedColorName is nil, so colorNameToUse is set to the default of "red"

userDefinedColorName = "green"
var colorNameToUse = userDefinedColorName ?? defaultColorName
// useDefinedColorName is not nil, so colorNameToUse is set to "green"

