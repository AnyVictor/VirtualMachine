//
// Created by Raven on 13/11/21.
//

import Foundation
import Cocoa

class MachineCodeInterpreter {
    
    var line = LinkedList<code>();
    var fileContent: String;
    
    init(fileContent: String) {
        self.fileContent = fileContent
    }
    //            if let range = chars.range(of: "JMP ") {
//                let jmp = chars[range.upperBound...]
//                print("JMP: ", jmp)
//            }
    
    func machine(fileContent: String) {
        
        let string = fileContent.components(separatedBy: .newlines)
        //print(string)
        var partial: String
        var i = 0
        let result: String = string.reduce(into: "") { partial, toTrim in
            guard
                    let range = toTrim.range(of:"\t"),
                    range.upperBound < toTrim.endIndex
                    else { return }
            
            
            partial.append("\(toTrim[range.upperBound..<toTrim.endIndex]) ")
            //print("\(toTrim[range.upperBound..<toTrim.endIndex]) ")
            
            if range.lowerBound > toTrim.startIndex  {
                //Pega valor antes do NULL
                line.append(code(linha: i, inst: "NULL", atrib1: "\(toTrim[toTrim.startIndex..<range.lowerBound])"))
            }
            
            i+=1
        }
        
        print(line)
        
        //print(result)
    }
}
