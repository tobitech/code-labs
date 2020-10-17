import UIKit
/*
class Vehicle {
    var wheels: Int = 0
    var seats: Int = 0
    
    required init(wheels: Int, seats: Int) {
        self.wheels = wheels
        self.seats = seats
    }
}

class Car: Vehicle {
    
}

var aCar = Car(wheels: 4, seats: 0)
print(aCar.wheels)
*/

func someFunction(_ someValue: Int) -> (Int) -> Int {
    func doSomethingWithInt(_ value: Int) -> Int {
        someValue = someValue * value
        
        return someValue
    }
    
    return doSomethingWithInt
}

var someFunction1 = someFunction(2)
someFunction1(2)

var someFunction2 = someFunction1
someFunction2(4)
