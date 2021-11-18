//
// Created by Raven on 13/11/21.
//

import Foundation
import Cocoa


struct codeLine  {
    static var defaultValue:  codeLine = codeLine(linha: -1, inst: "", atrib1: "", atrib2: "", com: "")
    var linha: Int
    var inst: String
    var atrib1: String
    var atrib2: String
    var com: String
}

struct stackValues {
    static var defaultValue:  stackValues = stackValues(endereco: -1, valor: -1)
    var endereco: Int
    var valor: Int
  
    
}



class MachineCodeInterpreter  {
    
    var fileContent: String
    var linkedCodeLines: LinkedList<codeLine>
    var _stackCodeLines = Stack<stackValues>()
    var lineCounter : Int
    var rotuleToReplace: [[Int]] = []
    var commands: Int = 0
    var count : Int = 1
    /*var stackUI :  [[String: String]] = [["endereco":"2", "valor":"12"]]
    var stackAddr: NSTableView*/
    
    init(fileContent: String) {
        self.fileContent = fileContent
        self.linkedCodeLines = LinkedList<codeLine>()
        self.lineCounter = 0
      
        //stackAddr.reloadData()
    }
 
    
    func analyser(stackUI : inout [[String: String]]) {
        self.extractCommands(stackUI: &stackUI)
        
        //stackAddr()
        //self.executaNormal(command: linkedCodeLines, stackUI: &stackUI )
    }
    
    
    func extractCommands(stackUI : inout [[String: String]]){
        
        var array = self.fileContent.components(separatedBy: .newlines)

        
        
        for item in array {
            
            var i = 0
            var arrChar = Array<Character>(item)
            // remove espaços iniciais
            if(arrChar.count != 0){
                while(arrChar[i] == " "){
                    i+=1
                }
                self.matchWithCommand(Array<Character>(arrChar[i..<arrChar.count]))
                
                self.lineCounter+=1
            }
            
           
        }
        self.fixNullRotule()
        print(linkedCodeLines)
        
        var _linkedCodeLines : LinkedList<codeLine> = LinkedList<codeLine>()
        _linkedCodeLines.setHead(el: linkedCodeLines.first!)

        
        var value  = _linkedCodeLines.first?.value ?? codeLine.defaultValue
        stackUI.remove(at: 0)
        while(value.linha != -1){
            
            stackUI.append(["linha": "\(value.linha)", "instrucao": "\(value.inst)", "atributo1": "\(value.atrib1)", "atributo2":"\(value.atrib2)", "comentario": "\(value.com)", "focus": "false"])
            
            _linkedCodeLines.nextNode()
            
            value = _linkedCodeLines.first?.value ?? codeLine.defaultValue
            
        }
        
    }
    
    func matchWithCommand(_ value: Array<Character>){
        
        var crtlCommand = 0
        var ctrlAtrib1 = 0
        var ctrlAtrib2 = 0
        
        var auxCommand = ""
        var auxAtrib1 = ""
        var auxAtrib2 = ""
        
        var i = 0
        var rotule = -1
        for item in value{
            
            if(i == 0 && item.isNumber){
                rotule = item.wholeNumberValue ?? -1
            }else if(item != "\t"){
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
            i+=1
            
        }
        if(rotule != -1){
            // [toSearch, toReplace]
            rotuleToReplace.append([rotule, self.lineCounter])
            
            linkedCodeLines.append(codeLine(linha: self.lineCounter, inst: "NULL", atrib1: auxAtrib1, atrib2: auxAtrib2, com: ""))

        }else{
            linkedCodeLines.append(codeLine(linha: self.lineCounter, inst: auxCommand, atrib1: auxAtrib1, atrib2: auxAtrib2, com: ""))

        }
        
        
        //
     //print(linkedCodeLines)
        //print(linkedCodeLines)
    }
    
    func fixNullRotule(){
        var _linkedCodeLines: LinkedList<codeLine> = LinkedList<codeLine>()

        var value  = linkedCodeLines.first?.value ?? codeLine.defaultValue
        
        while(value.linha != -1){
            if(value.inst == "CALL" || value.inst == "JMP" || value.inst == "JMPF"){
                for item in self.rotuleToReplace{
                    if("\(item[0])" == value.atrib1){
                        _linkedCodeLines.append(codeLine(linha: value.linha, inst: value.inst, atrib1: "\(item[1])", atrib2: "", com: ""))
                    }
                    
                }
            }
            else{
                _linkedCodeLines.append(value)
            }
            
            linkedCodeLines.nextNode()
            value = linkedCodeLines.first?.value ?? codeLine.defaultValue
            
        }
        
        
        linkedCodeLines.setHead(el: _linkedCodeLines.first!)
        //print(_linkedCodeLines)
        
    }
    
    func executaNormal(stackUI : inout [[String: String]], dataOutput: inout NSTextView) -> Bool {
        let command = self.linkedCodeLines
        
        
        //while(true){
            
            let comando = command.nodeAt(index: commands)?.value ?? codeLine.defaultValue
            
            if(comando.inst == "LDC") {
                count += 1
                let value = comando
               
                _stackCodeLines.push(stackValues(endereco: count, valor: Int(value.atrib1) ?? -1))
            }
            else
            if(comando.inst == "LDV") {
                count += 1
                let value = comando 
                let valueInStack = _stackCodeLines.itemAtPosition(Int(value.atrib1) ?? 0)
                
                _stackCodeLines.push(stackValues(endereco: count, valor: valueInStack.valor))
            }
            else
            if(comando.inst == "ADD") {
                let soma = _stackCodeLines.itemAtPosition(count - 1).valor + _stackCodeLines.itemAtPosition(count).valor
                
                count-=1
                
                _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: soma))
            }
            else
            if(comando.inst == "SUB") {
                let sub = _stackCodeLines.itemAtPosition(count - 1).valor - _stackCodeLines.itemAtPosition(count).valor
                
                count-=1
                
                _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: sub))
            }
            else
            if(comando.inst == "MULT") {
                let mult = _stackCodeLines.itemAtPosition(count - 1).valor * _stackCodeLines.itemAtPosition(count).valor
                
                count -= 1
                
                _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: mult))
            }
           else
            if(comando.inst == "DIVI") {
                let div = _stackCodeLines.itemAtPosition(count - 1).valor / _stackCodeLines.itemAtPosition(count).valor
                
                count-=1
                
                _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: div))
           }
            else
            if(comando.inst == "INV") {
                let inv = _stackCodeLines.itemAtPosition(count).valor * -1
                
               
                
                _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: inv))
            }
            else
            if(comando.inst == "AND") {
                
                let stackVar1 = _stackCodeLines.itemAtPosition(count - 1).valor
                let stackVar2 = _stackCodeLines.itemAtPosition(count).valor

                count -= 1
                if(stackVar1 == 1 && stackVar2 == 1) {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 0))

                }
            }
            else
            if(comando.inst == "OR") {
                let stackVar1 = _stackCodeLines.itemAtPosition(count - 1).valor
                let stackVar2 = _stackCodeLines.itemAtPosition(count).valor

                count -= 1
                if(stackVar1 == 1 || stackVar2 == 1) {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 0))

                }
            }
            else
            if(comando.inst == "NEG") {
                let stackVar1 = _stackCodeLines.itemAtPosition(count).valor

                _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 1 - stackVar1))
                
            }
            else
            if(comando.inst == "CME") {
                
                let stackVar1 = _stackCodeLines.itemAtPosition(count - 1).valor
                let stackVar2 = _stackCodeLines.itemAtPosition(count).valor

                count -= 1
                if(stackVar1 < stackVar2) {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(comando.inst == "CMA") {
                
                let stackVar1 = _stackCodeLines.itemAtPosition(count - 1).valor
                let stackVar2 = _stackCodeLines.itemAtPosition(count).valor

                count -= 1
                if(stackVar1 > stackVar2) {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(comando.inst == "CEQ") {
                
                let stackVar1 = _stackCodeLines.itemAtPosition(count - 1).valor
                let stackVar2 = _stackCodeLines.itemAtPosition(count).valor

                count -= 1
                if(stackVar1 == stackVar2) {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(comando.inst == "CDIF") {
                
                let stackVar1 = _stackCodeLines.itemAtPosition(count - 1).valor
                let stackVar2 = _stackCodeLines.itemAtPosition(count).valor

                count -= 1
                if(stackVar1 != stackVar2) {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(comando.inst == "CMEQ") {
                
                let stackVar1 = _stackCodeLines.itemAtPosition(count - 1).valor
                let stackVar2 = _stackCodeLines.itemAtPosition(count).valor

                count -= 1
                if(stackVar1 <= stackVar2) {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(comando.inst == "CMAQ") {
                
                let stackVar1 = _stackCodeLines.itemAtPosition(count - 1).valor
                let stackVar2 = _stackCodeLines.itemAtPosition(count).valor

                count -= 1
                if(stackVar1 >= stackVar2) {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(comando.inst == "START") {
                
                count -= 1
                commands = 1
                return true
                
            }
            else
            if(comando.inst == "HLT") {
                if(comando.linha != -1){
                    stackUI[comando.linha]["focus"] = "true"
                }
                print("ACABOOOOOU")
                return false
                
                //break
            }
            else
            if(comando.inst == "STR") {
                
                let contentS = _stackCodeLines.itemAtPosition(count).valor
                _stackCodeLines.inserAtPosition(Int(comando.atrib1) ?? -1, stackValues(endereco: count, valor: contentS))
                count -= 1

                
            }
            else
            if(comando.inst == "JMP") {
                
                let content = Int(comando.atrib1) ?? 0

                commands = content
            }
            else
            if(comando.inst == "JMPF") {
                let content = Int(comando.atrib1) ?? 0
                
                if(content == 0){
                    commands = content
                }//else commands +=1 - so dexa rola
                
                count-=1
                
                
                
                
            }
            else
            if(comando.inst == "RD") {
                count += 1
                //let str = readLine() ?? "0"
                
                let alert = NSAlert()
                alert.messageText = "Digite uma Entrada"
                let textfield = NSTextField(frame: NSRect(x: 0.0, y: 0.0, width: 80.0, height: 24.0))
                textfield.alignment = .center
                alert.accessoryView = textfield
                alert.runModal()

                _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: Int(textfield.stringValue) ?? 0))

                
            }
            else
            if(comando.inst == "PRN") {
                let content = _stackCodeLines.itemAtPosition(count).valor
                count -= 1
                //print("Saida: \(content)")
                dataOutput.string += "Saída: \(content) \n"
                
            }
            else
            if(comando.inst == "ALLOC") {
                count += 1
                let v = command.nodeAt(index: commands)?.value ?? codeLine.defaultValue
                
                let atrib1 = Int(v.atrib1) ?? 0
                let atrib2 = Int(v.atrib2) ?? 0
                
                for k in 0..<atrib2{
                    _stackCodeLines.push(stackValues(endereco: count, valor: atrib1+k))
                    count += 1
                }
            }
            if(comando.inst == "DALLOC") {
                count -= 1
                let v = command.nodeAt(index: commands)?.value ?? codeLine.defaultValue
                
                let atrib1 = Int(v.atrib1) ?? 0
                let atrib2 = Int(v.atrib2) ?? 0
                
                for k in stride(from: atrib2 - 1, to: 0, by: -1){
                    _stackCodeLines.push(stackValues(endereco: atrib1 + k, valor: _stackCodeLines.itemAtPosition(count).valor))
                    count -= 1
                }
            }
            if(comando.inst == "CALL") {
                count += 1
                _stackCodeLines.inserAtPosition(count, stackValues(endereco: count, valor: commands+1))
                
                commands = Int(comando.atrib1) ?? 0
                

            }
            if(comando.inst == "RETURN") {
                
                commands = _stackCodeLines.itemAtPosition(count).valor
                count-=1
                
            }
        
            commands+=1
            
            
            for i in 0..<_stackCodeLines.items.count{
                //stackUI[i][0] "endereco": "\(items.endereco)", "valor": "\(items.valor)"
                //print(stackUI[i]["linha"])
                
                stackUI[i]["linha"] = stackUI[i]["linha"]
                stackUI[i]["endereco"] = "\(_stackCodeLines.itemAtPosition(i+1).endereco)"
                stackUI[i]["valor"] = "\(_stackCodeLines.itemAtPosition(i+1).valor)"
                stackUI[i]["focus"] = "false"
                
            }
            if(comando.linha != -1){
                stackUI[comando.linha]["focus"] = "true"
            }
            
//            let str = readLine() ?? "0"
            //stackAddr()
        
        //}
        //stackAddr.reloadData()
        return true
    }
    
    
    
    
}
