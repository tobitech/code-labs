import UIKit

// What is linked list?
// 1->2->3->nil

// Define a data structure that supports this list
class Node {
    let value: Int
    var next: Node?
    
    init(value: Int, next: Node?) {
        self.value = value
        self.next = next
    }
}

let threeNode = Node(value: 3, next: nil)
let twoNode = Node(value: 2, next: threeNode)
let oneNode = Node(value: 1, next: twoNode)

func printList(head: Node?) {
    print("Printing out list of nodes")
    var currentNode = head
    while currentNode != nil {
        print(currentNode?.value ?? -1)
        currentNode = currentNode?.next
    }
}

printList(head: oneNode)

// this returns a node which is the head of our reversed list.
// 1->2->3->nil
func reverseList(head: Node?) -> Node? {
    var currentNode = head
    var prev: Node?
    var next: Node?
    
    while currentNode != nil {
        next = currentNode?.next
        currentNode?.next = prev
        
        prev = currentNode
        currentNode = next
    }
    
    
    return prev
}

let myReversedList = reverseList(head: oneNode)

printList(head: myReversedList) // need to print out 3,2,1



