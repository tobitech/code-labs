import UIKit

func swaps(input1: String) -> Int {
    var steps = 0
    
    var processedWord = input1
    var i = 0
    while !isPalindrome(word: processedWord) {
        processedWord = swapCharacters(word: input1, i: i)
        print("Processed Word: \(processedWord)")
        steps += 1
        i += 1
    }
    
    if steps > 1 {
        return steps - 1
    }
    
    return steps
}

func swapCharacters(word: String, i: Int) -> String {
    var characters = Array(word.lowercased())
    print("Characters: \(characters)")
    
    let j = i + 1
    
    print("i: \(i), j: \(j)")
    if j < characters.count {
        characters.swapAt(i, j)
    }
    
    let newWord = String(characters)
    return newWord
}

func isPalindrome(word: String) -> Bool {
    let characters = Array(word.lowercased())
    var currentIndex = 0

    while currentIndex < characters.count / 2 {
        if characters[currentIndex] != characters[characters.count - currentIndex - 1] {
            return false
        }
        currentIndex += 1
    }

    return true
}

print(swaps(input1: "lleve"))
