import UIKit

/*
 Error Handling:
 
 You use error handling to respond to error conditions
 your program may encounter during execution.
 */

func canThrowError() throws {
    // this function may or may not throw an error
}

/// When you call a function that can throw an error, you prepend the try keyword to the expression.
do {
    try canThrowError()
    // no error was thrown
} catch {
    // an error was thrown
}

/// A do statement creates a new containing scope, which allows errors to be propagated to one or more catch clauses.
/// Here’s an example of how error handling can be used to respond to different error conditions:

enum SandwichError: Error {
    case outOfCleanDishes
    case missingIngredients(ingredients: [String])
}

func eatASandwich() {
    // ...
}

func washDishes() {
    // ...
}

func buyGroceries(_ ingredients: [String]) {
    // ...
}

func makeASandwich() throws {
    // ...
}

do {
    try makeASandwich()
    eatASandwich()
} catch SandwichError.outOfCleanDishes {
    // if error thrown by makeASandwich() matches ".outOfCleanDishes"
    washDishes()
} catch SandwichError.missingIngredients(let ingredients) {
    // if error thrown by makeASandwich() matches ".missingIngredients"
    buyGroceries(ingredients)
}


