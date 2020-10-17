import UIKit

/*
 Numeric Type Conversion:
 
 Use the Int type for all general-purpose integer constants and
 variables in your code, even if they’re known to be nonnegative
 
 Use other integer types only when they’re specifically
 needed for the task at hand,
 because of explicitly sized data from an external source, or
 for performance,
 memory usage, or
 other necessary optimization.
 */

// MARK: - Integer Conversion

// let cannotBeNegative: UInt8 = -1
// UInt8 cannot store negative numbers, and so this will report an error

// Arithmetic operation '127 + 1' (on type 'Int8') results in an overflow
// let tooBig: Int8 = Int8.max + 1
// Int8 cannot store a number larger than its maximum value,
// and so this will also report an error

let twoThousand: UInt16 = 2_000
let one: UInt8 = 1

/// They can’t be added together directly, because they’re not of the same type.
/// so we convert UInt8 to type UInt16 to be able to add them together
let twoThousandAndOne = twoThousand + UInt16(one)


// MARK: - Integer and Floating-point conversion
/// Conversions between integer and floating-point numeric types must be made explicit:
let three = 3
let pointOneFourOneFiveNine = 0.14159

/// Without this conversion in place, the addition would not be allowed.
let pi = Double(three) + pointOneFourOneFiveNine
// pi equals 3.14159, and is inferred to be of type Double

/// An integer type can be initialized with a Double or Float value:
let integerPi = Int(pi)
// integerPi equals 3, and is inferred to be of type Int

/// Floating-point values are always truncated
/// when used to initialize a new integer value in this way.
/// This means that 4.75 becomes 4, and -3.9 becomes -3.
