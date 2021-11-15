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
    
    func machineCode(fileContent: String) {
        
        let string = fileContent.components(separatedBy: .newlines)
        //print(string)
        var partial: String
        var i = 0
        let result: String = string.reduce(into: "") { partial, toTrim in
            guard
                    let range = toTrim.range(of:"\t"),
                    range.upperBound < toTrim.endIndex
                    else { return }
            
            if(!"\(toTrim[range.upperBound..<toTrim.endIndex]) ".components(separatedBy: .whitespaces).contains("NULL")) {
                
                var command = "\(toTrim[range.upperBound..<toTrim.endIndex]) ".components(separatedBy: .whitespaces)
                line.append(code(linha: i, inst: command[0], atrib1: command[1], atrib2: command[2]))
                
            }
            if range.lowerBound > toTrim.startIndex  {
                //Pega valor antes do NULL
                print("\(toTrim[toTrim.startIndex..<range.lowerBound])")
                line.append(code(linha: i, inst: "NULL", atrib1: "\(toTrim[toTrim.startIndex..<range.lowerBound])"))
            }
            
            i+=1
        }
        
        for number in 0..<(i) {
            var linha = " "
            var commandLine = 0
            if(line.nodeAt(index: number)?.value.inst == "JMP" || line.nodeAt(index: number)?.value.inst == "JMPF" || line.nodeAt(index: number)?.value.inst == "CALL" || line.nodeAt(index: number)?.value.inst == "NULL") {
                
                if(line.nodeAt(index: number)?.value.inst == "JMP" || line.nodeAt(index: number)?.value.inst == "JMPF" || line.nodeAt(index: number)?.value.inst == "CALL") {
                    linha = line.nodeAt(index: number)?.value.getAtrib1() ?? ""
                    //print("LINHA: ", linha)
                    commandLine = line.nodeAt(index: number)?.value.getLine() ?? 0
                }
                
                for number2 in 0..<(i) {
                    //print("NULL? ", line.nodeAt(index: number2)?.value.inst == "NULL", linha != " ", line.nodeAt(index: number2)?.value.atrib1)
                    if(line.nodeAt(index: number2)?.value.inst == "NULL" && linha != " " && String(line.nodeAt(index: number2)?.value.atrib1?.trimmingCharacters(in: .whitespaces) ?? " ") == linha) {
                        line.nodeAt(index: commandLine)?.value.setAtrib1(atrib1: String(line.nodeAt(index: number2)?.value.getLine() ?? 0))
                    }
                }
                
            }
            
        }
        
        for number in 0..<(i) {
            if(line.nodeAt(index: number)?.value.inst == "NULL") {
                line.nodeAt(index: number)?.value.setAtrib1(atrib1: String(line.nodeAt(index: number)?.value.getLine() ?? 0))
            }
        }
        
        print(line)
    }
}
