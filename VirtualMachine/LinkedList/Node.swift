//
// Created by Raven on 13/11/21.
//

import Foundation


public class Node<T> {
    
    var value: T
    var next: Node<T>?
    weak var previous: Node<T>?
    var index : Int = 0
    
    init(el: T, n: Int) {
        value = el
        index = n
    }
    
}

