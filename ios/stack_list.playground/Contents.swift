import UIKit

class Stack {
    
    var ll: LinkedList
    
    init(top: Node?) {
        self.ll = LinkedList(head: top)
    }
    
    // add a node to the top of the stack
    func push(_ node: Node) {
        ll.insertNode(node, at: 1)
    }
    
    // remove and return the topmost node from the stack
    func pop() -> Node? {
        let deletedNode = ll.getNode(atPosition: 1)
        if let value = deletedNode?.value {
            ll.deleteNode(withValue: value)
        }
        
        return deletedNode
    }
    
}

class Node {
    let value: Int
    var next: Node?
    
    init(value: Int) {
        self.value = value
    }
}


class LinkedList {
    var head: Node?
    
    init(head: Node?) {
        self.head = head
    }
    
    // append new node to list.
    func append(_ node: Node) {
        guard head != nil else {
            head = node
            return
        }
        
        var current = head
        while let _ = current?.next {
            current = current?.next
        }
        current?.next = node
    }
    
    // Get a node from a particular position.
    // Assume the first position is "1".
    // Return "nil" if position is not in the list.
    func getNode(atPosition position: Int) -> Node? {
        guard position > 0 else {
            return nil
        }
        
        var counter = 1
        var current = head
        
        while current != nil && counter <= position {
            if counter == position {
                return current
            }
            current = current?.next
            counter += 1
        }
        return nil
    }
    
    // Insert a new node at the given position.
    // Assume the first position is "1".
    // Inserting at position 3 means between
    // the 2nd and 3rd nodes.
    func insertNode(_ node: Node, at position: Int) {
        guard position > 0 else {
            return
        }
        
        var counter = 1
        var current = head
        
        if position > 1 {
            while current != nil && counter < position {
                if counter == position - 1 {
                    node.next = current?.next
                    current?.next = node
                    break
                }
                current = current?.next
                counter += 1
            }
        } else if position == 1 {
            node.next = head
            head = node
        }
        
    }
    
    // Delete the first node with a given value.
    func deleteNode(withValue value: Int) {
        var current = head
        var previous: Node?
        
        while current?.value != value && current?.next != nil {
            previous = current
            current = current?.next
        }
        
        if current?.value == value {
            if previous != nil {
                previous?.next = current?.next
            } else {
                head = current?.next
            }
        }
    }
    
}





// Test cases
// Set up some nodes
let n1 = Node(value: 1)
let n2 = Node(value: 2)
let n3 = Node(value: 3)
let n4 = Node(value: 4)

// Start setting up a Stack
let stack = Stack(top: n1)

// Test stack functionality

 stack.push(n2)
 stack.push(n3)
 print(stack.pop()!.value) // Should be 3
 print(stack.pop()!.value) // Should be 2
 print(stack.pop()!.value) // Should be 1
 print(stack.pop()?.value) // Should be nil
 stack.push(n4)
 print(stack.pop()!.value) // Should be 4








