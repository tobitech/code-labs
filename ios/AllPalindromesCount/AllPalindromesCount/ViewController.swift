import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let sentence = "madam anna kayak notapalindrome anna Civic racecar Civic anna"
        
        //Implement a function that will tell me for each palindrome, how many times it occurs. For example:
        //["Civic": 1, "madam": 1, "kayak": 1, "anna": 2, "racecar": 1]
        
        let counts = allPalindromeCounts(sentence: sentence)
        print("Counts:", counts)
    }
    
    func allPalindromeCounts(sentence: String) -> [String: Int] {
        var counts = [String: Int]()
        
        let words = sentence.components(separatedBy: " ")
        words.forEach { (word) in
            
            if isPalindrome(word: word) {
                let count = counts[word] ?? 0
                counts[word] = count + 1
//                print("Found palindrome:", word)
            }
            
        }
        
        return counts
    }
    
    fileprivate func isPalindrome(word: String) -> Bool {
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
    
}
