//
// Created by Raven on 13/11/21.
//

import Foundation

struct code {
    var linha: Int
    var inst: String
    var atrib1: String?
    var atrib2: String?
    var com: String?
    
    init(linha: Int, inst: String, atrib1: String? = nil, atrib2: String? = nil, com: String? = nil) {
        self.linha = linha
        self.inst = inst
        self.atrib1 = atrib1
        self.atrib2 = atrib2
        self.com = com
    }
    
}

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

