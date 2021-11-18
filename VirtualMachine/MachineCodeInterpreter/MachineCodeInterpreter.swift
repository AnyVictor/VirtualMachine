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
        return atrib1 ?? ""
    }

    func getAtrib2() -> String {
        return atrib2 ?? ""
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
    static var defaultValue:  stackValues = stackValues(endereco: -1, valor: -1)
    var endereco: Int
    var valor: Int
}

class MachineCodeInterpreter {
    
    var fileContent: String
    var linkedCodeLines: LinkedList<codeLine>
    var _stackCodeLines = Stack<stackValues>()
    var lineCounter : Int
    var rotuleToReplace: [[Int]] = []
    
    init(fileContent: String) {
        self.fileContent = fileContent
        linkedCodeLines = LinkedList<codeLine>()
        lineCounter = 0
    }

    func analyser() {
        extractCommands()
        executaNormal(command: linkedCodeLines)
    }

    func extractCommands(){

        var array = fileContent.components(separatedBy: .newlines)

        for item in array {

            var i = 0
            var arrChar = Array<Character>(item)
            // remove espaços iniciais
            if(arrChar.count != 0){
                while(arrChar[i] == " "){
                    i+=1
                }
                matchWithCommand(Array<Character>(arrChar[i..<arrChar.count]))
                lineCounter+=1
            }


        }

        fixNullRotule()
        print(linkedCodeLines)

        var _linkedCodeLines : LinkedList<codeLine> = LinkedList<codeLine>()
        _linkedCodeLines.setHead(el: linkedCodeLines.first!)
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

            if(i == 0 && item.isNumber ){
                rotule = item.wholeNumberValue ?? -1
            }else if(item != "\t"){
                if(item != " " ){

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
    }

    func fixNullRotule() {
        var _linkedCodeLines: LinkedList<codeLine> = LinkedList<codeLine>()

        var value = linkedCodeLines.first?.value ?? codeLine.defaultValue

        while (value.linha != -1) {
            if (value.inst == "CALL" || value.inst == "JMP" || value.inst == "JMPF") {
                for item in self.rotuleToReplace {
                    if ("\(item[0])" == value.atrib1) {
                        _linkedCodeLines.append(codeLine(linha: value.linha, inst: value.inst, atrib1: "\(item[1])", atrib2: "", com: ""))
                    }

                }
            } else {
                _linkedCodeLines.append(value)
            }

            linkedCodeLines.nextNode()
            value = linkedCodeLines.first?.value ?? codeLine.defaultValue
        }

        linkedCodeLines.setHead(el: _linkedCodeLines.first!)
    }
    
    func executaNormal(command: LinkedList<codeLine>) {

        let linhas = command.last?.value.linha ?? -1
        var i = 0
        var atrib = 0

       while (true) {

           var instruction = command.nodeAt(index: i)?.value.inst
           var instValue = command.nodeAt(index: i)?.value ?? codeLine.defaultValue

           if(instruction == "LDC") {
                let value = instValue
                _stackCodeLines.push(stackValues(endereco: _stackCodeLines.items.count, valor: Int(value.atrib1) ?? -1))
                i += 1
           }
           else
           if(instruction == "NULL") {
                i += 1
           }
           else
           if(instruction == "LDV") {

                let value = instValue

                let aux = _stackCodeLines.itemAtPosition(Int(value.atrib1) ?? 0)
                _stackCodeLines.push(stackValues(endereco: _stackCodeLines.items.count, valor: aux.valor))
                i += 1
           }
           else
           if(instruction == "ADD") {
               let add = (_stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 2).valor) + (_stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1).valor)
               _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = add
               _stackCodeLines.pop()
                i += 1
           }
           else
           if(instruction == "SUB") {
                let sub = (_stackCodeLines.items[_stackCodeLines.items.count - 2].valor) - (_stackCodeLines.items[_stackCodeLines.items.count - 1].valor)
                _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = sub
                _stackCodeLines.pop()
                i += 1

           }
           else
           if(instruction == "MULT") {
                let mult = (_stackCodeLines.items[_stackCodeLines.items.count - 2].valor) * (_stackCodeLines.items[_stackCodeLines.items.count - 1].valor)
                _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = mult
                _stackCodeLines.pop()
                i += 1

           }
           else
           if(instruction == "DIVI") {
                let div = (_stackCodeLines.items[_stackCodeLines.items.count - 2].valor) / (_stackCodeLines.items[_stackCodeLines.items.count - 1].valor)
                _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = div
                _stackCodeLines.pop()
                i += 1

           }
           else
           if(instruction == "INV") {
                let inv = -(_stackCodeLines.items[_stackCodeLines.items.count - 1].valor);
                _stackCodeLines.items[_stackCodeLines.items.count - 1].valor = inv
                i += 1

           }
           else
           if(instruction == "AND") {
                let aux1 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1 ?? 0)

                let aux2 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 2 ?? 0)

                if(aux2.valor == 1 ?? 0 && aux1.valor == 1 ?? 0) {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 1
                }
                else {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 0
                }
                _stackCodeLines.pop()
                i += 1

           }
           else
           if(instruction == "OR") {
                let aux1 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1 ?? 0)

                let aux2 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 2 ?? 0)

                if(aux2.valor == 1 ?? 0 || aux1.valor == 1 ?? 0) {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 1
                }
                else {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 0
                }
                _stackCodeLines.pop()
                i += 1

           }
           else
           if(instruction == "NEG") {

                let neg = (1 - (_stackCodeLines.items[_stackCodeLines.items.count - 1].valor));
                _stackCodeLines.items[_stackCodeLines.items.count - 1].valor = neg
                i += 1

           }
           else
           if(instruction == "CME") {

                let aux1 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1 ?? 0)

                let aux2 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 2 ?? 0)

                if(aux2.valor ?? 0 < aux1.valor ?? 0) {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 1
                }
                else {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 0
                }
                _stackCodeLines.pop()
                i += 1

           }
           else
           if(instruction == "CMA") {

                let aux1 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1 ?? 0)

                let aux2 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 2 ?? 0)

                if(aux2.valor ?? 0 > aux1.valor ?? 0) {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 1
                }
                else {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 0
                }
                _stackCodeLines.pop()
                i += 1

            }
            else
            if(instruction == "CEQ") {

                let aux1 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1 ?? 0)

                let aux2 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 2 ?? 0)

                if(aux2.valor ?? 0 == aux1.valor ?? 0) {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 1
                }
                else {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 0
                }
                _stackCodeLines.pop()
                i += 1

            }
            else
            if(instruction == "CDIF") {

                let aux1 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1 ?? 0)

                let aux2 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 2 ?? 0)

                if(aux2.valor ?? 0 != aux1.valor ?? 0) {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 1
                }
                else {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 0
                }
                _stackCodeLines.pop()
                i += 1

            }
            else
            if(instruction == "CMEQ") {

                let aux1 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1 ?? 0)

                let aux2 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 2 ?? 0)

                if(aux2.valor ?? 0 <= aux1.valor ?? 0) {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 1
                }
                else {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 0
                }
                _stackCodeLines.pop()
                i += 1

            }
            else
            if(instruction == "CMAQ") {

                let aux1 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1 ?? 0)

                let aux2 = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 2 ?? 0)

                if(aux2.valor ?? 0 >= aux1.valor ?? 0) {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 1
                }
                else {
                    _stackCodeLines.items[_stackCodeLines.items.count - 2].valor = 0
                }
                _stackCodeLines.pop()
                i += 1

            }
            else
            if(instruction == "START") {
                var _stackCodeLines = Stack<stackValues>()
                i += 1
            }
            else
            if(instruction == "HLT") {
                print("ACABOOOOOU!")
                i += 1
                break
            }
            else
            if(instruction == "STR") {

                if let endereco = Int((command.nodeAt(index: i)?.value.getAtrib1() ?? "")) {
                    let aux = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1)
                    _stackCodeLines.items[endereco].valor = aux.valor
                    _stackCodeLines.pop()
                    i += 1
                }

            }
            else
            if(instruction == "JMP") {
                let atribuicao1: String? = command.nodeAt(index: i)?.value.getAtrib1()
                if let string = atribuicao1, let atrib1 = Int(string) {
                    i = atrib1 + 1
                }
            }
            else
            if(instruction == "JMPF") {
                let aux = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1).valor

                if(aux == 0) {
                    let aux = Int(command.nodeAt(index: i)?.value.getAtrib1() ?? "")
                    i = aux ?? 0
                }
                else {
                    i+=1
                }

                _stackCodeLines.pop()

            }
            else
            if(instruction == "RD") {
                print("Digite um valor: ")
                var str = readLine() ?? ""
                _stackCodeLines.push(stackValues(endereco: _stackCodeLines.items.count, valor: Int(str) ?? 0))
                i += 1
            }
            else
            if(instruction == "PRN") {
                print("Saida: ",(_stackCodeLines.peek()?.valor ?? ""))
                _stackCodeLines.pop()
                i += 1
            }
            else
            if(instruction == "ALLOC") {

                var atrib1 = Int((command.nodeAt(index: i)?.value.atrib1 ?? ""))!
                var atrib2 = Int((command.nodeAt(index: i)?.value.getAtrib2() ?? ""))
                
                for k in 0..<atrib2!{

                    if(_stackCodeLines.items.count > 4) {
                        _stackCodeLines.push(stackValues(endereco: _stackCodeLines.items.count, valor: _stackCodeLines.itemAtPosition(k + atrib1).valor ?? 0))
                    } else {
                        _stackCodeLines.push(stackValues(endereco: _stackCodeLines.items.count, valor: _stackCodeLines.peek()?.valor ?? 0))
                    }
                }

                i += 1

            }
            else
            if(instruction == "DALLOC") {

                var atrib1 = Int((command.nodeAt(index: i)?.value.atrib1 ?? ""))!
                var atrib2 = Int((command.nodeAt(index: i)?.value.getAtrib2() ?? ""))

                for k in stride(from: atrib2! - 1, through: 0, by: -1){
                        let aux = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1)
                    _stackCodeLines.items[atrib1 + k].endereco = atrib1 + k
                    _stackCodeLines.items[atrib1 + k].valor = aux.valor
                    _stackCodeLines.pop()
                }

                i += 1

            }
            else
            if(instruction == "CALL") {

                let atribuicao1: String? = command.nodeAt(index: i)?.value.getAtrib1()

                if let string = atribuicao1, let atribuicao1 = Int(string) {
                    var x = i
                    x += 1
                    i = atribuicao1
                    _stackCodeLines.push(stackValues(endereco: _stackCodeLines.items.count, valor: x))
                }

            }
            else
            if(instruction == "RETURN") {
                     i = _stackCodeLines.itemAtPosition(_stackCodeLines.items.count - 1).valor
                    _stackCodeLines.pop()
            }
        }
        
    }
}
