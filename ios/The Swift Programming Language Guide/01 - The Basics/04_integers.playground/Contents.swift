import UIKit

/*
 Integers:
 
 Integers are whole numbers with no fractional components,
 such as 42, and -23.
 Integers are either signed (positive, zero, or negative)
 or unsigned (positive or zero).
 */

/// Swift provides signed and unsigned integers in 8, 16, 32, and 64 bit forms.
// UInt8 - 8-bit unsigned integer
// Int32 - 32-bit signed integer

// MARK: - Integer Bounds
let minValue = UInt8.min // minValue is equal to 0, and of type UInt8
let maxValue = UInt8.max // maxValue is equal to 255, and of type UInt8

// MARK: - Int
/// Swift provides an additional integer type, Int, which has the same size
/// as the current platform’s native word size:

// On a 32-bit platform, Int is the same size as Int32.
// On a 64-bit platform, Int is the same size as Int64.
let mnValue = Int32.min // Prints -2147483648
let mxValue = Int32.max // Prints 2147483647


// MARK: - UInt
/// Swift also provides an unsigned integer type, UInt, which has the same size
/// as the current platform’s native word size:
