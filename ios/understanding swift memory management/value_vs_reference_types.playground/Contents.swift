import UIKit

/// demonstrate that structures instances
/// are passed by value
var string1 = "Hello, playground"

/// the value of string1 is copied and stored in string2
/// (i.e. is now two separate values)
/// the values are equal but in memory are different
/// that is what passing by value means.
/// when the value of string1 was assigned to string2,
/// it was passed by value
var string2 = string1

//if string1 == string2 {
//    print("\(string1) is equal to \(string2)")
//} else {
//    print("\(string1) is NOT equal to \(string2)")
//}

/// what happens if we assign a new value to string1
string1 = "Hello, world"

if string1 == string2 {
    print("\(string1) is equal to \(string2)")
} else {
    print("\(string1) is NOT equal to \(string2)")
}


class Person {
    var first: String
    var last: String
    
    init(first: String, last: String) {
        self.first = first
        self.last = last
    }
}

/// create an instance of the `Person` class
let jim = Person(first: "Jim", last: "Simmons")
jim.first
jim.last

let jane = jim
jane.first
jane.last

jane.first = "Jane"

/// the value stored in the `first` property of jim
/// is also modified
/// when we assigned jim to jane, the value was stored
/// jim wasn't copied, instead the reference of the person instance
/// stored in jim was assigned to jane
/// this means that jim and jane are pointing to the same `Person` instance
/// only one instance of the `Person` class is present in memory
jim.first
jane.first
