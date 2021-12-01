//
// Created by Raven on 13/11/21.
//

import Foundation
import Cocoa

//#REF implmenta a estrutura de uma linha de codigo para analise | Posteriormente usada dentro da UI para print
struct codeLine  {
    static var defaultValue:  codeLine = codeLine(linha: -1 , inst: "", atrib1: "", atrib2: "", com: "")
    var linha: Int
    var inst: String
    var atrib1: String
    var atrib2: String
    var com: String
}
//#REF implementa uma pilha
struct stackValues {
    static var defaultValue:  stackValues = stackValues(endereco: -1, valor: -1)
    var endereco: Int
    var valor: Int
  
    
}


//#REF implementa as funcoes basicas para criacao da maquina virtual
class MachineCodeInterpreter  {
    
    var fileContent: String
    var linkedCodeLines: LinkedList<codeLine>
    var _stackCodeLines = Stack<stackValues>()
    var listFinal : [codeLine] = [] // usada para copia momentanea de Debug da Stack
    var lineCounter : Int
    var rotuleToReplace: [[Int]] = []
    var i:Int = 0
    var atrib:Int = 0
    var s:Int = 0
    var lastS: Int = 0

    
    init(fileContent: String) {
        self.fileContent = fileContent
        self.linkedCodeLines = LinkedList<codeLine>()
        self.lineCounter = 0
        _stackCodeLines.items = [stackValues](repeating: stackValues.defaultValue, count: 500)
      
    }
 
    
    func analyser(stackUI : inout [[String: String]]) {
        self.extractCommands(stackUI: &stackUI)
    }
    
    //#REF Extrai os comandos do arquivo lido
    func extractCommands(stackUI : inout [[String: String]]){
        
        var array = self.fileContent.components(separatedBy: .newlines)

        
        // Para cada linha do arquivo lido sera analisado com match de comando
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
            listFinal.append(value)

        }
        
    }
    
    //os cmandos buscados sao separados por espaços 
    // Esses dois tipos de comandos sao tratados: <Comando> <atrib1> <atrib2> ou <X> NULL
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
            // foi encontrado um NULL
            // é buscado até o N todos os numeros para construção da lsita de rotulos para substituiçao
            // [toSearch, toReplace]
            var ax : String = ""
            for j in value{
                if(j == "N" || j == " "){
                    break;
                }else{
                    
                    ax.append(j)
                }
            }
            
            rotule = Int(ax) ?? -1
            
            rotuleToReplace.append([rotule, self.lineCounter])
            
            linkedCodeLines.append(codeLine(linha: self.lineCounter, inst: "NULL", atrib1: auxAtrib1, atrib2: auxAtrib2, com: ""))

        }else{
            linkedCodeLines.append(codeLine(linha: self.lineCounter, inst: auxCommand, atrib1: auxAtrib1, atrib2: auxAtrib2, com: ""))
        }
    }
    
    // #REF a partir da lista de posições montada, é substituida pelo match correspondente
    func fixNullRotule(){
        var _linkedCodeLines: LinkedList<codeLine> = LinkedList<codeLine>()

        var value  = linkedCodeLines.first?.value ?? codeLine.defaultValue
        
        while(value.linha != -1){
            if(value.inst == "CALL" || value.inst == "JMP" || value.inst == "JMPF"){
                for item in self.rotuleToReplace{
                    if("\(item[0])" == value.atrib1){
                        _linkedCodeLines.append(codeLine(linha: value.linha, inst: value.inst, atrib1: "\(item[1])", atrib2: "", com: ""))
                        break
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
    
    //#REF executa um comando. Essa funcao é colocada dentro de um while dentro da UI
    func executaNormal(dataCommandsUI : inout [[String: String]], dataStackUI: inout [[String: String]], dataOutput: inout NSTextView) -> Bool {

            let command = self.linkedCodeLines
            

            var instruction = command.nodeAt(index: i)?.value.inst
            var instValue = command.nodeAt(index: i)?.value ?? codeLine.defaultValue
            
        
        
            if (instruction == "LDC") {
                /*
                    LDC k (Carregar constante):
                    S:=s + 1 ; M [s]: = k
                */
                self.s += 1
                let value = instValue
                //_stackCodeLines.push(stackValues(endereco: _stackCodeLines.items.count, valor: Int(value.atrib1) ?? -1))
                _stackCodeLines.inserAtPosition(s, stackValues(endereco: s, valor: Int(value.atrib1) ?? -1))
                i += 1
                
            } else if (instruction == "NULL") {
                /*
                    NULL
                    i+1
                */
                i += 1
            } else if (instruction == "LDV") {
                /*
                    LDV n (Carregar valor):
                    S:=s+1 ; M[s]:=M[n]
                */
                self.s += 1
                let value = instValue

                let aux = _stackCodeLines.itemAtPosition(Int(value.atrib1) ?? 0 )
                _stackCodeLines.inserAtPosition(s, stackValues(endereco: s, valor: aux.valor))
                i += 1
                
            } else if (instruction == "ADD") {
                /*
                    ADD (Somar):
                    M[s-1]:=M[s-1]+M[s]; s:=s-1
                */

                let add = (_stackCodeLines.itemAtPosition(s - 1).valor) + (_stackCodeLines.itemAtPosition(s).valor)
                _stackCodeLines.items[s - 1].valor = add

                i += 1
                s -= 1
            } else if (instruction == "SUB") {
                /*
                    SUB (Subtrair):
                    M[s-1]:=M[s-1]-M[s]; s:=s-1

                */
                let sub = (_stackCodeLines.items[s - 1].valor) - (_stackCodeLines.items[s].valor)
                _stackCodeLines.items[s - 1].valor = sub
                i += 1
                self.s -= 1
            } else if (instruction == "MULT") {
                /*
                    MULT (Multiplicar):
                    M[s-1]:=M[s-1]*M[s]; s:=s-1
                */

                let mult = (_stackCodeLines.items[s - 1].valor) * (_stackCodeLines.items[s].valor)
                _stackCodeLines.items[s - 1].valor = mult
                i += 1
                self.s -= 1

            } else if (instruction == "DIVI") {
                /*
                    DIVI (Dividir):
                    M[s-1]:=M[s-1] div M[s]; s:=s-1
                */
                let div = (_stackCodeLines.items[s - 1].valor) / (_stackCodeLines.items[s].valor)
                _stackCodeLines.items[s - 1].valor = div
                i += 1
                self.s -= 1
            } else if (instruction == "INV") {
                /*
                    INV (Inverter sinal):
                     M[s]:=-M[s]
                */

                let inv = -(_stackCodeLines.items[s].valor);
                _stackCodeLines.items[s].valor = inv
                i += 1

            } else if (instruction == "AND") {
                /*
                    AND (Conjunção):
                    Se M [s-1]=1 e M[s]=1 então M[s-1]:=1 senão M[s-1]:=0; S:=s-1
                */

                let aux1 = _stackCodeLines.itemAtPosition(s-1)

                let aux2 = _stackCodeLines.itemAtPosition(s)

                if (aux2.valor == 1 && aux1.valor == 1 ) {
                    _stackCodeLines.items[s-1].valor = 1
                } else {
                    _stackCodeLines.items[s-1].valor = 0
                }
                i += 1
                self.s -= 1

            } else if (instruction == "OR") {
                /*
                    OR (Disjunção):
                    Se M[s-1]=1 ou M[s]=1 então M[s-1]:=1 senão M[s-1]:=0; s:=s-1
                */
                let aux1 = _stackCodeLines.itemAtPosition(s-1)

                let aux2 = _stackCodeLines.itemAtPosition(s)

                if (aux2.valor == 1 || aux1.valor == 1 ) {
                    _stackCodeLines.items[s-1].valor = 1
                } else {
                    _stackCodeLines.items[s-1].valor = 0
                }
                i += 1
                self.s -= 1
            } else if (instruction == "NEG") {
                /*
                    NEG (Negação):
                    M[s]:=1-M[s]
                */

                let neg = (1 - (_stackCodeLines.items[s].valor));
                _stackCodeLines.items[s].valor = neg
                i += 1

            } else if (instruction == "CME") {
                /*
                    CME (Comparar menor):
                    Se M[s-1]<M[s] então M[s-1]:=1 senão M[s-1]:=0; s:=s-1

                */
                let aux1 = _stackCodeLines.itemAtPosition(s)

                let aux2 = _stackCodeLines.itemAtPosition(s-1)

                if (aux2.valor  < aux1.valor ) {
                    _stackCodeLines.items[s-1].valor = 1
                } else {
                    _stackCodeLines.items[s-1].valor = 0
                }
                //_stackCodeLines.pop()
                i += 1
                self.s -= 1
            } else if (instruction == "CMA") {
                /*
                    CMA (Comparar maior):
                    Se M[s-1] >M[s] então M[s-1]:=1 senão M[s-1]:=0;s:=s-1
                */
                let aux1 = _stackCodeLines.itemAtPosition(s)

                let aux2 = _stackCodeLines.itemAtPosition(s-1)

                if (aux2.valor  > aux1.valor ) {
                    _stackCodeLines.items[s-1].valor = 1
                } else {
                    _stackCodeLines.items[s-1].valor = 0
                }
                //_stackCodeLines.pop()
                i += 1
                self.s -= 1
            } else if (instruction == "CEQ") {
                /*
                    CEQ (comparar igual):
                    Se M[s-1]=M[s] então M[s-1]:=1 senão M[s-1]:=0;s:=s-1
                */
                let aux1 = _stackCodeLines.itemAtPosition(s)

                let aux2 = _stackCodeLines.itemAtPosition(s-1)

                if (aux2.valor  == aux1.valor ) {
                    _stackCodeLines.items[s-1].valor = 1
                } else {
                    _stackCodeLines.items[s-1].valor = 0
                }
                i += 1
                self.s -= 1
            } else if (instruction == "CDIF") {
                /*
                    CDIF (Comparar desigual):
                    Se M[s-1] != M[s] então M[s-1]:=1 senão M[s-1]:=0; s:=s-1

                */
                let aux1 = _stackCodeLines.itemAtPosition(s)

                let aux2 = _stackCodeLines.itemAtPosition(s-1)

                if (aux2.valor  != aux1.valor ) {
                    _stackCodeLines.items[s-1].valor = 1
                } else {
                    _stackCodeLines.items[s-1].valor = 0
                }
                i += 1
                self.s -= 1
            } else if (instruction == "CMEQ") {
                /*
                    CMEQ (Comparar menor ou igual)
                    Se M[s-1] == M[s] então M[s-1]:=1 senão M[s-1]:=0;s:=s-1

                */
                let aux1 = _stackCodeLines.itemAtPosition(s)

                let aux2 = _stackCodeLines.itemAtPosition(s-1)
                
                //print(aux1)
                //print(aux2)
                
                if (aux2.valor <= aux1.valor ) {
                    _stackCodeLines.items[s-1].valor = 1
                } else {
                    _stackCodeLines.items[s-1].valor = 0
                }
                i += 1
                self.s -= 1
            } else if (instruction == "CMAQ") {
                /*
                    CMAQ (Comparar maior ou igual):
                    Se M[s-1] >= M[s] então M[s-1]:=1 senão M[s-1]:=0; s:=s-1
                */
                let aux1 = _stackCodeLines.itemAtPosition(s)

                let aux2 = _stackCodeLines.itemAtPosition(s-1)

                if (aux2.valor  >= aux1.valor ) {
                    _stackCodeLines.items[s-1].valor = 1
                } else {
                    _stackCodeLines.items[s-1].valor = 0
                }
                i += 1
                self.s -= 1
            } else if (instruction == "START") {
                /*
                    START (Iniciar programa principal):
                    S:=-1
                */
                var _stackCodeLines = Stack<stackValues>()
                i += 1
                self.s = -1
                
            } else if (instruction == "HLT") {
                /*
                    HLT (Parar):
                    “Pára a execução da MVD”
                */
                if(instValue.linha != -1) {
                    dataCommandsUI[instValue.linha]["focus"] = "true"
                }
                i += 1
                dataOutput.string += "Fim ;)\n"
                return false
            } else if (instruction == "STR") {
                /*
                    STR n (Armazenar valor):
                    M[n]:=M[s]; s:=s-1
                */

                if let endereco = Int((command.nodeAt(index: i)?.value.atrib1 ?? "")) {
                    let aux = _stackCodeLines.itemAtPosition(s)
                    _stackCodeLines.items[endereco].valor = aux.valor
                    i += 1
                    self.s -= 1
                }

            } else if (instruction == "JMP") {
                /*
                    JMP p (Desviar sempre):
                    i:=p
                */

                let atribuicao1 = Int(instValue.atrib1) ?? -1            
                i = atribuicao1 + 1
                
            } else if (instruction == "JMPF") {
                /*
                    JMPF p (Desviar se falso):
                    Se M[s]=0 então i:=p senão i:=i+1;
                    S:=s-1
                */
                let aux = _stackCodeLines.itemAtPosition(s).valor

                if (aux == 0) {
                    let aux = instValue.atrib1
                    i = Int(aux) ?? -1
                } else {
                    i += 1
                }

                self.s -= 1
            } else if (instruction == "RD") {
                /*
                    RD (Leitura):
                    S:=s+1; M[s]:= “próximo valor de entrada”.
                */

                print("Digite um valor: ")

                let alert = NSAlert()
                alert.messageText = "Digite uma Entrada"
                let textfield = NSTextField(frame: NSRect(x: 0.0, y: 0.0, width: 80.0, height: 24.0))
                textfield.alignment = .center
                alert.accessoryView = textfield
                alert.runModal()
                self.s+=1
                _stackCodeLines.items[s] = stackValues(endereco: s, valor: Int(textfield.stringValue) ?? 0)                                                      
                i += 1
            } else if (instruction == "PRN") {
                /*
                  PRN (Impressão):
                 “Imprimir M[s]”; s:=s-1
                */
                print("Saida: ", (_stackCodeLines.items[s].valor))
                
                let printE = _stackCodeLines.items[s].valor
                
                if(printE == 5 ){
                    print("mapooi")
                }
                
                dataOutput.string += "Saída: \(printE)\n"
                i += 1
                self.s -= 1
            } else if (instruction == "ALLOC") {
                /*
                    ALLOC m (Alocar memória*):
                    S:=s+m

                */

                let atrib1 = Int(instValue.atrib1) ?? 0
                let atrib2 = Int(instValue.atrib2) ?? 0

                for k in 0..<atrib2 {
                    self.s+=1
                    _stackCodeLines.items[s] = stackValues(endereco: s, valor: _stackCodeLines.itemAtPosition(k + atrib1).valor ?? 0)
                }

                i += 1

            } else if (instruction == "DALLOC") {
                /*
                    DALLOC m (liberar memória):
                    S:=s-m
                */
                let atrib1 = Int((command.nodeAt(index: i)?.value.atrib1 ?? ""))!
                let atrib2 = Int((command.nodeAt(index: i)?.value.atrib2 ?? ""))

                for k in stride(from: atrib2! - 1, through: 0, by: -1) {
                    let aux = _stackCodeLines.itemAtPosition(s)
                    
                    _stackCodeLines.items[atrib1 + k].endereco = atrib1 + k
                    _stackCodeLines.items[atrib1 + k].valor = aux.valor
                    //_stackCodeLines.pop()
                    self.s = self.s - 1
                }
                

                i += 1

            } else if (instruction == "CALL") {
                self.s+=1
                let atribuicao1: String? = command.nodeAt(index: i)?.value.atrib1

                if let string = atribuicao1, let atribuicao1 = Int(string) {
                    var x = i
                    x += 1
                    i = atribuicao1
                    _stackCodeLines.items[s] = stackValues(endereco: s, valor: x)
                }

            } else if (instruction == "RETURN") {
                i = _stackCodeLines.itemAtPosition(s).valor
                self.s -= 1
            }
        var count = self.s
        
        if(count == -1 ){
            count = 0
        }
        if(count < 30){
            count = 30
        }
    
        dataStackUI.removeAll()
            for j in 0..<count{
                //stackUI[i][0] "endereco": "\(items.endereco)", "valor": "\(items.valor)"
                //print(stackUI[i]["linha"])

                //dataCommandsUI[i]["linha"] = dataCommandsUI[i]["linha"]
               
                dataStackUI.append([ "endereco": "\(_stackCodeLines.itemAtPosition(j).endereco)", "valor": "\(_stackCodeLines.itemAtPosition(j).valor)", "focus": "false"])
                
                //dataStackUI+=1
            }
            
        
        
            if(instValue.linha != -1){
                for j in 0..<dataCommandsUI.count{
                    
                    if(j == instValue.linha){
                        dataCommandsUI[instValue.linha]["focus"] = "true"
                    }else{
                        dataCommandsUI[j]["focus"] = "false"
                    }
                    
                }
            }
            
       
            return true
        }

}
