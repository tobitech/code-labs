import UIKit

/*
 Declaring Constants and Variables
 */
let maximumNumberOfLoginAttempts = 10
var currentLoginAttempt = 0

/// You can declare multiple constants or multiple variables
/// on a single line, separated by commas:
var x = 0.0, y = 0.0, z = "ball"


// MARK: - Type annotations
/// This example provides a type annotation for a variable called welcomeMessage,
/// to indicate that the variable can store String values:
var welcomeMessage: String

welcomeMessage = "Hello" // set variable to a string value

/// You can define multiple related variables of the same type on a single line,
/// separated by commas, with a single type annotation after the final variable name:
var red, green, blue: Double


// MARK: - Naming Constants and Variables
/// Constant and variable names can contain almost any character,
/// including Unicode characters:
let π = 3.14159
let 你好 = "你好世界"
let 🐶🐮 = "dogcow"

var friendlyWelcome = "Hello!"

// change an existing variable to another value of compatible type
friendlyWelcome = "Bonjour!"

// the value of constant can't be changed after it's set
let languageName = "Swift"
// languageName = "Swift++" // You get a compile-time error:



// MARK: - Printing Constants and Variables
print(friendlyWelcome) // Prints "Bonjour!" in the console

// print a value without a line break after it
print(friendlyWelcome, terminator: "")
print("something else")  // Prints "Bonjour!something else"

