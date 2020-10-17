import UIKit

let scope = 0..<119147
let contacts = Array([1])
print("Contacts count:", contacts.count)

let multiples: Double = (Double(contacts.count) / Double(1000))
let multipleInt = Int(multiples.rounded(.up))
for i in 0..<multipleInt {
    
    let startIndex = i*1000
    var endIndex = min(contacts.count - 1, (i+1)*1000)
    // var endIndex = min(contacts.count, (i+1)*1000) // another version without the -1
    
    print("Multiple Int:", multipleInt)
    
    if endIndex == multipleInt - 1 {
        if contacts.count > 1 {
            endIndex = endIndex + 1
        }
    }
    
    print("Start Index:", startIndex)
    print("End Index:", endIndex)
    
    let batch = contacts[startIndex...endIndex]
    
    let batchContacts: [Int] = Array(batch)
    
    print("batch (\(i)) \(batchContacts)")
    print("count \(batchContacts.count)")
}
