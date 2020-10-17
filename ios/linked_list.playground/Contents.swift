import UIKit

// class represents a node
// enabling us to link items in a list to the next one.
class Node {
    let value: Int
    var next: Node?
    
    init(value: Int) {
        self.value = value
    }
}

let node1 = Node(value: 1)
let node2 = Node(value: 2)
node1.next = node2

// an implementation of LinkedList data structure
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

// Examples:

// Test cases

// Set up some Nodes
let n1 = Node(value: 1)
let n2 = Node(value: 2)
let n3 = Node(value: 3)
let n4 = Node(value: 4)

// Start setting up a LinkedList
let ll = LinkedList(head: n1)
ll.append(n2)
ll.append(n3)

// Test getNode(atPosition:)
print(ll.head!.next!.next!.value) // Should print 3
print(ll.getNode(atPosition: 3)!.value) // Should also print 3


// Test insert
ll.insertNode(n4, at: 3)
print(ll.getNode(atPosition: 3)!.value) // Should print 4 now

// Test delete(withValue:)
ll.deleteNode(withValue: 1)
print(ll.getNode(atPosition: 1)!.value) // Should print 2 now
print(ll.getNode(atPosition: 2)!.value) // Should print 4 now
print(ll.getNode(atPosition: 3)!.value) // Should print 3
