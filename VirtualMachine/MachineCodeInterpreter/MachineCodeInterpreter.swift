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
    
    func getLine() -> Int {
        return linha
    }
    
    func getInst() -> String {
        return inst
    }
    
    func getAtrib1() -> String {
        return atrib1
    }
    
    func getAtrib2() -> String {
        return atrib2
    }
    
    mutating func setLine(linha: Int) {
        self.linha = linha
    }
    
    mutating func setInst(inst: String) {
        self.inst = inst
    }
    
    mutating func setAtrib1(atrib1: String){
        self.atrib1 = atrib1
    }
    
    mutating func setAtrib2(atrib2: String){
        self.atrib2 = atrib2
    }
}

struct stackValues {
    
    var endereco: Int
    var valor: Int
    
    mutating func setEndereco(endereco: Int){
        self.endereco = endereco
    }
    
    mutating func setValor(valor: Int){
        self.valor = valor
    }
    
    func getEndereco() -> Int {
        return endereco
    }
    
    func getValor() -> Int {
        return valor
    }
    
}

class MachineCodeInterpreter {
    
    var fileContent: String
    var linkedCodeLines: LinkedList<codeLine>
    var _stackCodeLines = Stack<stackValues>()
    var lineCounter : Int
    var rotuleToReplace: [[Int]] = []

    
    init(fileContent: String) {
        self.fileContent = fileContent
        self.linkedCodeLines = LinkedList<codeLine>()
        self.lineCounter = 0
        
    }
    
 
    
    func analyser() {
        self.extractCommands()
        
        self.executaNormal(command: linkedCodeLines)
    }
    
    
    func extractCommands(){
        
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
            }else{
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
    
    func executaNormal(command: LinkedList<codeLine>) {
        let linhas = command.last?.value.linha
        var count = 0
        var atrib = 0
        for commands in 0..<(linhas!) {
            
            if(command.nodeAt(index: commands)?.value.inst == "LDC") {
                count += 1
                _stackCodeLines.push(stackValues(endereco: count, valor: Int(command.nodeAt(index: commands)?.value.getAtrib1() ?? " ")!))
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "LDV") {
                count += 1
                _stackCodeLines.push(stackValues(endereco: count, valor: Int(command.nodeAt(index: commands)?.value.getAtrib1() ?? " ")!))
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "ADD") {
                count -= 1
                let soma = (_stackCodeLines.pop()?.valor ?? 0)! + (_stackCodeLines.pop()?.valor ?? 0)!
                print("SOMA: ", soma)
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "SUB") {
                count -= 1
                let sub = (_stackCodeLines.pop()?.valor ?? 0)! - (_stackCodeLines.pop()?.valor ?? 0)!
                print("SUB: ", sub)
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "MULT") {
                count -= 1
                let mult = (_stackCodeLines.pop()?.valor ?? 0)! * (_stackCodeLines.pop()?.valor ?? 0)!
                print("MULT: ", mult)
            }
//            else
//            if(command.nodeAt(index: commands)?.value.inst == "DIVI") {
//                count -= 1
//                let div = (_stackCodeLines.pop()?.valor ?? 0)! / (_stackCodeLines.pop()?.valor)!
//                print("DIVI: ", div)
//            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "INV") {
                let inv = -(_stackCodeLines.pop()?.valor ?? 0)!
                print("INV: ", inv)
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "AND") {
                count -= 1
                let stackVar1 = _stackCodeLines.pop()
                let stackVar2 = _stackCodeLines.pop()

                _stackCodeLines.push(stackValues(endereco: (stackVar1?.valor)!, valor: (stackVar1?.endereco)!))
                _stackCodeLines.push(stackValues(endereco: (stackVar2?.valor)!, valor: (stackVar2?.endereco)!))
                
                if(stackVar1?.valor == 1 && stackVar2?.valor == 1) {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 0))

                }
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "OR") {
                count -= 1
                let stackVar1 = _stackCodeLines.pop()
                let stackVar2 = _stackCodeLines.pop()

                _stackCodeLines.push(stackValues(endereco: (stackVar1?.valor)!, valor: (stackVar1?.endereco)!))
                _stackCodeLines.push(stackValues(endereco: (stackVar2?.valor)!, valor: (stackVar2?.endereco)!))
                
                if(stackVar1?.valor == 1 || stackVar2?.valor == 1) {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 0))

                }
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "NEG") {
                let neg = (1 - (_stackCodeLines.pop()?.valor)!);
                _stackCodeLines.push(stackValues(endereco: count, valor: neg))
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "CME") {
                
                count -= 1
                let stackVar1 = _stackCodeLines.pop()
                let stackVar2 = _stackCodeLines.pop()

                _stackCodeLines.push(stackValues(endereco: (stackVar1?.valor)!, valor: (stackVar1?.endereco)!))
                _stackCodeLines.push(stackValues(endereco: (stackVar2?.valor)!, valor: (stackVar2?.endereco)!))
                
                if(stackVar1?.valor ?? 0 > stackVar2?.valor ?? 0) {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "CMA") {
                
                count -= 1
                let stackVar1 = _stackCodeLines.pop()
                let stackVar2 = _stackCodeLines.pop()

                _stackCodeLines.push(stackValues(endereco: (stackVar1?.valor)!, valor: (stackVar1?.endereco)!))
                _stackCodeLines.push(stackValues(endereco: (stackVar2?.valor)!, valor: (stackVar2?.endereco)!))
                
                if(stackVar1?.valor ?? 0 < stackVar2?.valor ?? 0) {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "CEQ") {
                
                count -= 1
                let stackVar1 = _stackCodeLines.pop()
                let stackVar2 = _stackCodeLines.pop()

                _stackCodeLines.push(stackValues(endereco: (stackVar1?.valor)!, valor: (stackVar1?.endereco)!))
                _stackCodeLines.push(stackValues(endereco: (stackVar2?.valor)!, valor: (stackVar2?.endereco)!))
                
                if(stackVar1?.valor ?? 0 == stackVar2?.valor ?? 0) {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "CDIF") {
                
                count -= 1
                let stackVar1 = _stackCodeLines.pop()
                let stackVar2 = _stackCodeLines.pop()

                _stackCodeLines.push(stackValues(endereco: (stackVar1?.valor)!, valor: (stackVar1?.endereco)!))
                _stackCodeLines.push(stackValues(endereco: (stackVar2?.valor)!, valor: (stackVar2?.endereco)!))
                
                if(stackVar1?.valor ?? 0 != stackVar2?.valor ?? 0) {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "CMEQ") {
                
                count -= 1
                let stackVar1 = _stackCodeLines.pop()
                let stackVar2 = _stackCodeLines.pop()

                _stackCodeLines.push(stackValues(endereco: (stackVar1?.valor)!, valor: (stackVar1?.endereco)!))
                _stackCodeLines.push(stackValues(endereco: (stackVar2?.valor)!, valor: (stackVar2?.endereco)!))
                
                if(stackVar1?.valor ?? 0 >= stackVar2?.valor ?? 0) {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "CMAQ") {
                
                count -= 1
                let stackVar1 = _stackCodeLines.pop()
                let stackVar2 = _stackCodeLines.pop()

                _stackCodeLines.push(stackValues(endereco: (stackVar1?.valor)!, valor: (stackVar1?.endereco)!))
                _stackCodeLines.push(stackValues(endereco: (stackVar2?.valor)!, valor: (stackVar2?.endereco)!))
                
                if(stackVar1?.valor ?? 0 <= stackVar2?.valor ?? 0) {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 1))
                }
                else {
                    _stackCodeLines.push(stackValues(endereco: count, valor: 0))

                }
                
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "START") {
                var _stackCodeLines = Stack<stackValues>()
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "HLT") {
                print("ACABOOOOOU")
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "STR") {
                var end = command.nodeAt(index: commands)?.value.getAtrib1()
                _stackCodeLines.pop()
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "JMP") {
                let optionalString: String? = command.nodeAt(index: commands)?.value.getAtrib1()
                if let string = optionalString, let myInt = Int(string) {
                     print("Int : \(myInt)")
                    atrib = myInt
                }
                
                _stackCodeLines.pop()
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "JMPF") {
                count -= 1
                var atribs = _stackCodeLines.pop()
                if(atribs?.valor == 0) {
                    let optionalString: String? = command.nodeAt(index: commands)?.value.getAtrib1()
                    if let string = optionalString, let myInt = Int(string) {
                         print("Int : \(myInt)")
                        atrib = myInt
                    }
                    
                    _stackCodeLines.pop()
                }
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "RD") {
                count -= 1
                var str = readLine()
                _stackCodeLines.push(stackValues(endereco: count, valor: Int(str!) ?? 0))

                
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "PRN") {
                print("Saida: ",_stackCodeLines.pop())
                
            }
            else
            if(command.nodeAt(index: commands)?.value.inst == "ALLOC") {
                count += 1
                var atrib1 = Int((command.nodeAt(index: commands)?.value.getAtrib1())!)
                var atrib2 = Int((command.nodeAt(index: commands)?.value.getAtrib2())!)
                
                for k in 0..<atrib2!{
                    _stackCodeLines.push(stackValues(endereco: atrib1! + k, valor: Int(exactly: _stackCodeLines.pop()?.getValor() ?? 0)!))
                }
            }
            if(command.nodeAt(index: commands)?.value.inst == "DALLOC") {
                count -= 1
                var atrib1 = Int((command.nodeAt(index: commands)?.value.getAtrib1())!)
                var atrib2 = Int((command.nodeAt(index: commands)?.value.getAtrib2())!)
                
                for k in stride(from: (atrib2)! - 1, to: 0, by: -1){
                    _stackCodeLines.push(stackValues(endereco: atrib1! + k, valor: Int(exactly: _stackCodeLines.pop()?.getValor() ?? 0)!))
                }
            }
            if(command.nodeAt(index: commands)?.value.inst == "CALL") {
                atrib += 1
                _stackCodeLines.push(stackValues(endereco: count, valor: atrib))
                let optionalString: String? = command.nodeAt(index: commands)?.value.getAtrib1()
                if let string = optionalString, let myInt = Int(string) {
                    atrib = myInt
                }
                

            }
            if(command.nodeAt(index: commands)?.value.inst == "RETURN") {
                let optionalString: String? = command.nodeAt(index: commands)?.value.getAtrib1()
                if let string = optionalString, let myInt = Int(string) {
                    atrib += myInt
                }

                _stackCodeLines.pop()
            }

            
            
        }
        
    }
    
    func fixNullRotule(){
        var _linkedCodeLines: LinkedList<codeLine> = LinkedList<codeLine>()

        var value  = linkedCodeLines.first?.value ?? codeLine.defaultValue
        
        while(value.linha != -1){
            if(value.inst == "CALL"){
                for item in self.rotuleToReplace{
                    if(item[0] == Int(value.atrib1 )){
                        _linkedCodeLines.append(codeLine(linha: value.linha, inst: value.inst, atrib1: "\(item[1])", atrib2: "", com: ""))
                    }
                    
                }
            }else{
                _linkedCodeLines.append(value)
            }
            
            linkedCodeLines.nextNode()
            value = linkedCodeLines.first?.value ?? codeLine.defaultValue
            
        }
        
        
        linkedCodeLines.setHead(el: _linkedCodeLines.first!)
        //print(_linkedCodeLines)
        
    }
    
    
}
