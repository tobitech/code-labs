import UIKit

/*
 Optionals:
 
 You use optionals in situations where a value may be absent.
 Swift’s optionals let you indicate the absence of a value for any type at all, without the need for special constants.
 */

let possibleNumber = "123"
let convertedNumber = Int(possibleNumber)
// convertedNumber is inferred to be of type "Int?", or "optional Int"

// MARK: - nil
/// You set an optional variable to a valueless state by assigning it the special value nil:
var serverResponse: Int? = 404
// serverResponse contains an actual Int value of 404
serverResponse = nil
// serverResponse now contains no value

/// If you define an optional variable without providing a default value,
/// the variable is automatically set to nil for you:

var surveyAnswer: String?
// surveyAnswer is automatically set to nil


// MARK: - If Statements and Forced Unwrapping
/// You can use an if statement to find out whether an optional contains a value by comparing the optional against nil
if convertedNumber != nil {
    print("convertedNumber contains some integer value")
}

/// Once you’re sure that the optional does contain a value,
/// you can access its underlying value by adding an exclamation point (!) to the end of the optional’s name.
/// This is known as forced unwrapping of the optional’s value:
if convertedNumber != nil {
    print("convertedNumber has an integer value of \(convertedNumber!)")
}

/// Trying to use ! to access a nonexistent optional value triggers a runtime error.
/// Always make sure that an optional contains a non-nil value before using ! to force-unwrap its value.

// MARK: - Optional Binding
/// You use optional binding to find out whether an optional contains a value, and if so,
/// to make that value available as a temporary constant or variable.
/// Optional binding can be used with if and while statements to check for a value inside an optional,
/// and to extract that value into a constant or variable, as part of a single action.

// You can rewrite the possibleNumber example from the Optionals section
// to use optional binding rather than forced unwrapping:
if let actualNumber = Int(possibleNumber) {
    print("The string \"\(possibleNumber)\" has an integer value of \(actualNumber)")
} else {
    print("The string \"\(possibleNumber)\" could not be converted to an integer")
}

/// You can use both constants and variables with optional binding.
/// If you wanted to manipulate the value of actualNumber within the first branch of the if statement,
/// you could write if var actualNumber instead,
/// and the value contained within the optional would be made available as a variable rather than a constant.


/// You can include as many optional bindings and Boolean conditions in a single if statement as you need to,
/// separated by commas. If any of the values in the optional bindings are nil or any Boolean condition evaluates to false,
///  the whole if statement’s condition is considered to be false.
if let firstNumber = Int("4"), let secondNumber = Int("42"), firstNumber < secondNumber && secondNumber < 100 {
    print("\(firstNumber) < \(secondNumber) < 100")
}

// this statement is equivalent to the one above
if let firstNumber = Int("4") {
    if let secondNumber = Int("42") {
        if firstNumber < secondNumber && secondNumber < 100 {
            print("\(firstNumber) < \(secondNumber) < 100")
        }
    }
}


// MARK: Implicitly Unwrapped Optionals
/*
Sometimes it’s clear from a program’s structure that an optional will always have a value, after that value is first set. In these cases, it’s useful to remove the need to check and unwrap the optional’s value every time it’s accessed, because it can be safely assumed to have a value all of the time.

These kinds of optionals are defined as implicitly unwrapped optionals. You write an implicitly unwrapped optional by placing an exclamation point (String!) rather than a question mark (String?) after the type that you want to make optional. Rather than placing an exclamation point after the optional’s name when you use it, you place an exclamation point after the optional’s type when you declare it.

Implicitly unwrapped optionals are useful when an optional’s value is confirmed to exist immediately after the optional is first defined and can definitely be assumed to exist at every point thereafter. The primary use of implicitly unwrapped optionals in Swift is during class initialization.
 
 An implicitly unwrapped optional is a normal optional behind the scenes, but can also be used like a non-optional value, without the need to unwrap the optional value each time it’s accessed.
*/
/// The following example shows the difference in behavior between an optional string
/// and an implicitly unwrapped optional string when accessing their wrapped value as an explicit String:
let possibleString: String? = "An optional string."
let forcedString: String = possibleString! // requires an exclammation poit.

let assumedString: String! = "An implicitly unwrapped optional string."

// implicitString has an explicit non-optional type `String`
let implicitString: String = assumedString // no need for an exclammation point

let optionalString = assumedString
// The type of optionalString is "String?" and assumedString isn't forced-unwrapped


/// You can check whether an implicitly unwrapped optional is nil the same way you check a normal optional:
if assumedString != nil {
    print(assumedString!)
}
// Prints "An implicitly unwrapped optional string."

/// You can also use an implicitly unwrapped optional with optional binding,
/// to check and unwrap its value in a single statement:
if let definiteString = assumedString {
    print(definiteString)
    // Prints "An implicitly unwrapped optional string."
}

