//
// Created by Raven on 13/11/21.
//

import Foundation

struct code {
    var linha: Int
    var inst: String
    var atrib1: Int
    var atrib2: Int
    var com: String
}

// 1
public class Node<T> {
    // 2
    var value: T
    var next: Node<T>?
    weak var previous: Node<T>?
    var index : Int = 0
    // 3
    init(el: T, n: Int) {
        self.value = el
        self.index = n
    }
}

