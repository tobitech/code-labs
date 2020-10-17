import UIKit

/*
 String Literals:
 
 A string literal is a sequence of characters surrounded by double quotation marks(").
 */

// Use a string literal as an intial value for a constant or variable.
let someString = "Some string literal value"
/// Note that Swift infers a type of String for the someString constant because it’s initialized with a string literal value.


// MARK: Multiline String Literals
/// If you need a string that spans several lines,
/// use a multiline string literal—a sequence of characters surrounded by three double quotation marks:
let quotation = """
The White Rabbit put on his spectacles. "Where shall I begin,
please your Majesty?" he asked.

"Begin at the beginning," the King said gravely, "and go on
till you come to the end; the stop."
"""

/// When your source code includes a line break inside of a multiline string literal, that line break also appears in the string's value. If you want to use line breaks to make your souce code easier to read, but you don't want the line breaks to be part of the string's valu, write a backslash (\) at the end of those lines:
let softWrapQuotation = """
The White Rabbit put on his spectacles. "Where shall I begin, \
please your Majesty?" he asked

"Begin at the beginning," the King said gravely, "and go on \
till you come to the end; the stop."
"""


/// To make a multiline string literal that begins or ends with a line feed, write a blank line as the first or last. For example.
let lineBreaks = """

This string starts with a line break.
It also ends with a line break.

"""


/// The whitespace before the closing quotation marks (""") tells Swift what whitespace to ignore before all of the other lines.
/// However, if you write whitespace at the beginning of a line in addition to what’s before the closing quotation marks, that whitespace is included.
let linesWithIndentation = """
    This line doesn't begin with whitespace.
        This line begins with four spaces.
    This line doesn't begin with whitespace.
    """

// MARK: - Special Characters in String Literals
/// String literals can include the following special characters:
/// The escaped characters:
//  \0 - (null character)
//  \\ - (backslash character)
//  \t - (horizontal tab)
//  \n - (line feed)
//  \r - (carriage return)
//  \" - (double quotation mark)
//  \' - (single quotation mark)
/// An arbitrary unicode character \u{n}, where n is a 1-8 digit hexadecimal number
// Examples:
let wiseWords = "\"Imagination is more important than knowledge\" - Einstein"

let dollarSign = "\u{24}"  // $,  Unicode scalar U+0024
let blackHeart = "\u{2665}" // ♥,  Unicode scalar U+2665
let sparklingHeart = "\u{1F496}"  // 💖, Unicode scalar U+1F496

/// To include the text """ in a multiline string, escape at least one of the quotation marks.
/// For example:
let threeDoubleQuotationMarks = """
Escaping the first quotation mark \"""
Escaping all three quotation marks \"\"\"
"""

// MARK: - Extended String Delimiters
/// You can place a string literal within extended delimiters to include special characters in a string without invoking their effect.
print(#"Line 1\nLine 2"#)  // Prints "Line 1\nLine 2"

// print("Line 1\nLine 2")
// Prints   // Line 1
            // Line 2


/// If you need the special effects of a character in a string literal, match the number of number signs within the string following the escape character (\).
// print(#"Line 1\#nLine 2"#)
print(###"Line1\###nLine2"###) // does the same as above


/// String literals created using extended delimiters can also be multiline string literals.
let threeMoreDoubleQuotationMarks = #"""
Here are three more double quotes: """
"""#

