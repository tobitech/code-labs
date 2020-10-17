import UIKit

/*
 String Mutability:
 
 You indicate whether a particular String can be modified (or mutated) by assigning it to a variable, or to a constant
 */
var variableString = "Horse"
variableString += " and carriage"

let constantString = "Highlander"
constantString += " and another Highlander"
// compile time error: Left side of mutating operator isn't mutable: 'constantString' is a 'let' constant
