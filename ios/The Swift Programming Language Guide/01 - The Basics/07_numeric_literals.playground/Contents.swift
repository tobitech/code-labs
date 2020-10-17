import UIKit

/*
 Numeric Literals:
 */

// Integer Literals can be written as:
    // A decimal number, with no prefix
    // A binary number, with 0b prefix
    // An octal number, with a 0o prefix
    // A hexadecimal number, with a 0x prefix

let decimalInteger = 17
let binaryInteger = 0b10001  // 17 in binary notation
let octalInteger = 0o21  // 17 in octal notation
let hexadecimalInteger = 0x11  // 17 in hexadecimal notation

// Floating-point literals can be written as:
    // A decimal, with no prefix
    // A hexadecimal, with a 0x prefix
// The must always have a number of hexadecimal on both sides of the decimal point.
let decimalFloat = 1.25e2
let decimalFloat2 = 1.25e-2

let hexadecimalFloat = 0xFp2 // 15 x 2^2, or 60.0
let hexadecimalFloat2 = 0xFp-2 // 15 x 2^-2, or 3.75

let decimalDouble = 12.1875
let exponentialDouble = 1.21875e1
let hexadecimalDouble = 0xC.3p0


/// Numeric literals can contain extra formatting to make them easier to read.
/// Both integers and floats can be padded with extra zeros
/// and can contain underscores to help with readability.
/// Neither type of formatting affects the underlying value of the literal:
let paddedDouble = 000123.456
let oneMillion = 1_000_000
let justOverOneMillion = 1_000_000.000_000_1

