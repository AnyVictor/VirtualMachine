//
// Created by Raven on 13/11/21.
//

import Foundation


class LinkedList<T > {
    fileprivate var head: Node<T>?
    private var tail: Node<T>?
    private var globalIndex: Int = 0
    
    public var isEmpty: Bool {
        return head == nil
    }
    
    public var first: Node<T>? {
        return head
    }
    
    public var last: Node<T>? {
        return tail
    }
    
    public func setHead(el: Node<T>){ //use wisely
        head = el
    }
    
    public func nextNode(){
        var actualNode = head
        self.head = actualNode?.next as? Node<T> ?? nil
    }
    
   
    
    public func append(_ el: T) {
        self.globalIndex += 1
        let newNode = Node(el: el, n: self.globalIndex)
        if let tailNode = tail {
            newNode.previous = tailNode
            tailNode.next = newNode
        } else {
            head = newNode
        }
        tail = newNode
    }
    
    public func nodeAt(index: Int) -> Node<T>? {
        if index >= 0 {
            var node = head
            var i = index
            while node != nil {
                if i == 0 {
                    return node
                    
                }
                i -= 1
                node = node!.next
                
            }
        }
        return nil
    }
    
    public func removeAll() {
        head = nil
        tail = nil
    }
    
    // 7. Update the parameter of the remove function to take a node of type T. Update the return value to type T.
    public func remove(node: Node<T>) -> T {
        let prev = node.previous
        let next = node.next
        
        if let prev = prev {
            prev.next = next
        } else {
            head = next
        }
        next?.previous = prev
        
        if next == nil {
            tail = prev
        }
        
        node.previous = nil
        node.next = nil
        
        return node.value as! T
    }
}

extension LinkedList: CustomStringConvertible {
    public var description: String {
        var text = "["
        var node = head
        
        while node != nil {
            text += "\(node!.value)"
            node = node!.next
            if node != nil { text += ", " }
        }
        
        return text + "]"
    }
}

