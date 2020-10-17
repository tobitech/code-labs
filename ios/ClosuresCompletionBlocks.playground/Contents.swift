import UIKit

func filterGreaterThanValue(value: Int, numbers: [Int]) -> [Int] {
    
    var filteredSetOfNumbers = [Int]()
    
    for num in numbers {
        if num > value {
            filteredSetOfNumbers.append(num)
        }
    }
    return filteredSetOfNumbers
}

func filterWithPredicateClosure(closure: (Int) -> Bool, numbers: [Int]) -> [Int] {
    
    var filteredSetOfNumbers = [Int]()
    
    for num in numbers {
        // perform some condition check
        if closure(num) {
            filteredSetOfNumbers.append(num)
        }
    }
    
    return filteredSetOfNumbers
}

func greaterThanThree(value: Int) -> (Bool) {
    return value > 3
}

func divisibleByFive(value: Int) -> Bool {
    return value % 5 == 0
}

//let filteredList = filterWithPredicateClosure(closure: greaterThanThree, numbers: [1, 2, 3, 4, 5, 10])
let filteredList = filterWithPredicateClosure(closure: divisibleByFive, numbers: [20, 30, 1, 2, 9, 15])
// print(filteredList)

//let filteredList = filterWithPredicateClosure(closure: { (num) -> Bool in
//    return num > 2
//}, numbers: [1, 2, 3, 4, 5, 10])

//let filteredList = filterGreaterThanValue(value: 3, numbers: [1, 2, 3, 4, 5, 10])
//print(filteredList)
