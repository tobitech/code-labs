import UIKit

/*
 Initializing an Empty String:
 
 To create an empty String value as the starting point for building a longer string, either assign an empty string literal to a variable, or initialize a new String instance with initializer syntax:
 */
var emptryString = ""               // empty string literal
var anotherEmptyString = String()   // initializer syntax
// these two strings are both empty, and are equivalent to each other


/// Find out whether a String value is empty by checking its Boolean isEmpty property.
if emptryString.isEmpty {
    print("Nothing to see here")
}

