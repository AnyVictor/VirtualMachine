//
// Created by Raven on 13/11/21.
//

import Foundation
import Cocoa

struct codeLine {
    var linha: Int
    var inst: String
    var atrib1: String
    var atrib2: String
    var com: String
}




class MachineCodeInterpreter {
    
    var fileContent: String
    var linkedCodeLines: LinkedList<codeLine> = LinkedList<codeLine>()
    var lineCounter : Int
    
    init(fileContent: String) {
        self.fileContent = fileContent
    }
    
 
    
    func analyser() {
        self.extractCommands()
        
        //print(string)
    }
    
    
    func extractCommands(){
        
        let array = self.fileContent.components(separatedBy: .newlines)

        
        
        for item in array {
            
            var i = 0
            let arrChar = Array(item)
            // remove espaços iniciais
            while(arrChar[i] == " "){
                i+=1
            }
            
            
            
            
            self.lineCounter+=1
        }
        
    }
    
    func matchWithCommand(_ value: Array<Character>){
        
        //var i = 0
        
        if(value[0].isNumber){ // indica marcado de NULL
            
            linkedCodeLines.append(codeLine(linha: self.lineCounter, inst: "NULL", atrib1: "", atrib2: "", com: ""))
            
            
        }else{
            if(value[0] == "S"){
                if(value[1] == "T"){
                    
                }
            }
        }
        
        
    }
    
    
}
