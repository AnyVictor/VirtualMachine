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
    var linkedCodeLines: LinkedList<codeLine>
    var lineCounter : Int
    
    
    init(fileContent: String) {
        self.fileContent = fileContent
        self.linkedCodeLines = LinkedList<codeLine>()
        self.lineCounter = 0
    }
    
 
    
    func analyser() {
        self.extractCommands()
        
        //print(string)
    }
    
    
    func extractCommands(){
        
        let array = self.fileContent.components(separatedBy: .newlines)

        
        
        for item in array {
            
            var i = 0
            let arrChar = Array<Character>(item)
            // remove espaços iniciais
            if(arrChar.count != 0){
                while(arrChar[i] == " "){
                    i+=1
                }
                self.matchWithCommand(Array<Character>(arrChar[i..<arrChar.count]))
                
                self.lineCounter+=1
            }
            
           
        }
        print(linkedCodeLines)
        
    }
    
    func matchWithCommand(_ value: Array<Character>){
        
        var crtlCommand = 0
        var ctrlAtrib1 = 0
        var ctrlAtrib2 = 0
        
        var auxCommand = ""
        var auxAtrib1 = ""
        var auxAtrib2 = ""
        for item in value{
            
            if(item != " "){
                if(crtlCommand == 0){
                    auxCommand.append(item)
                }else if(ctrlAtrib1 == 0){
                    auxAtrib1.append(item)
                }else if(ctrlAtrib2 == 0){
                    auxAtrib2.append(item)
                }
            }else{
                if(crtlCommand == 0){
                    crtlCommand = 1
                }else if( ctrlAtrib1 == 0){
                    ctrlAtrib1 = 1
                }else if(ctrlAtrib2 == 0){
                    ctrlAtrib2 = 1
                }
            }
            
        }
        linkedCodeLines.append(codeLine(linha: self.lineCounter, inst: auxCommand, atrib1: auxAtrib1, atrib2: auxAtrib2, com: ""))
        
        
     //print(linkedCodeLines)
    }
    
    
}
