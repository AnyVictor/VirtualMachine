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
        
        return items[index-1]
    }
    
    mutating func inserAtPosition(_ index: Int, _ value: Element){
        
        items[index-1] = value
    }
    
    mutating func initStack(_ value:Int){
        items = []
    }
    
    mutating func getElements () -> [Element]{
        return items
    }
    



}
