//
//  Stack.swift
//  salsa20-compiler
//
//  Created by Luiz Vinicius Ruoso on 30/10/21.
//

import Foundation


struct Stack<Element> {

    var items: [Element] = []

    func peek() -> Element? {

        if (items.count == 0) {
            return nil

        }
        return items.last
    }

    mutating func pop() -> Element? {
        if (items.count == 0) {
            return nil

        }
        return items.removeLast()
    }
    
    
    mutating func push(_ element: Element) {
           items.append(element)
    }
    
    mutating func itemAtPosition(_ index: Int) -> Element{

        items[index]
    }

    func peekTwoElements() -> [Element]? {
        let length = items.count
        return (length >= 2 ? [items[length - 1], items[length - 2]] : nil)
    }

    mutating func getElement(index: Int) -> [Element]? {
        let length = items.count
        return (length >= index ? [items[index]] : nil)
    }



}
