//
//  ViewController.swift
//  VirtualMachine
//
//  Created by Victor Felipe dos Santos on 11/11/21.
//

import Cocoa
import Foundation



//extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
//
//    func numberOfRows(in tableView: NSTableView) -> Int {
//        return (data.count)
//    }
//
//    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
//        let person = data[row]
//
//        guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
//
//        if(tableColumn!.identifier.rawValue == "focus" && person[tableColumn!.identifier.rawValue] == "true"){
//            cell.textField?.drawsBackground = true
//            cell.textField?.backgroundColor = NSColor.blue
//        }
//        print("oi", cell)
//
//        cell.textField?.stringValue = person[tableColumn!.identifier.rawValue] ?? ""
//        //print("oi", person)
//        return cell
//    }
//}


class ViewController: NSViewController {
    @IBOutlet weak var normalRadioButton: NSButton!
    @IBOutlet weak var passoRadioButton: NSButton!
    @IBOutlet weak var stackAddr : NSTableView!
    @IBOutlet weak var mainTableView: NSTableView!
    @IBOutlet weak var documentNameInput: NSTextField!
    @IBOutlet var dataOutput: NSTextView!
    @IBOutlet weak var executeButton: NSButton!
    @IBOutlet weak var stopButton: NSButton!


    var _isRadioButtonSelected: Bool = false
    
    let nomes = ["Carlos","Joao","Manuel"]
    let idade = ["32","22","13"]

    var VirtualMachine: MachineCodeInterpreter?
    var data: [[String: String]] = [[:]]
    var dataStack : [[String: String]] = [[:]]
    
    @IBAction func documentTextFieldAction(_ sender: NSTextField) {
        //self.cleanVirtualMachine()
        
        if(data.count != 0){
            data.removeAll()
            data = [["endereco":"1", "valor":"1"]]
        }
        //dataOutput.string = ""
        
        let filepath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0].appendingPathComponent(documentNameInput.stringValue)
        var contents : String
        do{
            contents = try String(contentsOf: filepath)
            
            self.VirtualMachine =  MachineCodeInterpreter(fileContent: contents)

            self.VirtualMachine?.analyser(stackUI: &self.data)
        }catch{
            print(error)
        }
        let queue = DispatchQueue(label: "work-queue")
        mainTableView.reloadData()
        stackAddr.reloadData()
        importQueue()
    }

    @IBAction func importButtonPressed(_ sender: Any) {
        importQueue()
    }

    @IBAction func executeCodeAction(_ sender: Any) {
        //dataOutput.string = "zuinho"
        
        if(_isRadioButtonSelected){
            VirtualMachine?.executaNormal(dataCommandsUI: &self.data, dataStackUI: &self.dataStack, dataOutput : &self.dataOutput)
        }
        else {
            while(true){
                
                
                if let ctrl = VirtualMachine?.executaNormal(dataCommandsUI: &self.data, dataStackUI: &self.dataStack, dataOutput : &self.dataOutput){
                    if(!ctrl){
                        self.cleanVirtualMachine()
                        break
                    }
                }
                
                
               
            }
            
        }
        mainTableView.reloadData()
        stackAddr.reloadData()
    }
    
    
    @IBAction func stopButtonAction(_ sender: Any) {
        self.cleanVirtualMachine()
        
        
    }
    @IBAction func radioButtonChanged(_ sender: NSButton) {
        print(sender.identifier?.rawValue)
        
        if(sender.identifier?.rawValue == "passoRadioButton"){
            self._isRadioButtonSelected = true
        }else{
            self._isRadioButtonSelected = false
        }
        
    }

    func importQueue() {
        executeButton.isEnabled = true
        stopButton.isEnabled = true
        let filepath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0].appendingPathComponent(documentNameInput.stringValue)
        var contents : String
        do{
         contents = try String(contentsOf: filepath)
        self.VirtualMachine = MachineCodeInterpreter(fileContent: contents)

        self.VirtualMachine?.analyser(stackUI: &self.data)
        }catch{
            print(error)
        }
        let queue = DispatchQueue(label: "work-queue")
        mainTableView.reloadData()
        stackAddr.reloadData()
    }
    

    override func viewWillAppear() {
        super.viewWillAppear()
        mainTableView.reloadData()
    }
    
//    func reloadData(){
//        DispatchQueue.main.async {
//            //self.view.backgroundC
//            //self.stackAddr.beginUpdates()
//
//            self.stackAddr.reloadData()
//
//            // self.stackAddr.endUpdates()
//        }
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        mainTableView.delegate = self
        mainTableView.dataSource = self
        stackAddr.delegate = self
        stackAddr.dataSource = self

        // reload tableview
        //stackAddr.reloadData()


        //self.stackAddr.endUpdates()
        // Set the radio group's initial selection
       
        
        normalRadioButton.state = NSControl.StateValue.on

        //let filepath = Bundle.main.path(forResource: "gera1", ofType: "txt") ?? ""

        //queue.async{
        
            //self.stackAddr.reloadData()
        //}
        /*do {

           
            DispatchQueue.main.async {
                //self.view.backgroundC

            }



            //print(contents)
           //  Now push second ViewController form here with contents.
            } catch {
            print("erro", error)
           // contents could not be loaded
        }*/
    }
    
    func cleanVirtualMachine(){
        let filepath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0].appendingPathComponent(documentNameInput.stringValue)
        var contents : String
        do{
            self.data = [["endereco":"1", "valor":"1"]]

         contents = try String(contentsOf: filepath)
        self.VirtualMachine = nil
        self.VirtualMachine = MachineCodeInterpreter(fileContent: contents)

        self.VirtualMachine?.analyser(stackUI: &self.data)
        }catch{
            print(error)
        }
        
        mainTableView.reloadData()
        stackAddr.reloadData()
        
        
        
    }

    override var representedObject: Any? {
        didSet {

        }
    }

    
}

//MARK: - Table View
extension ViewController: NSTableViewDelegate, NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "mainTableView") {
            return data.count
        } else {
            
            return dataStack.count
        }
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {

        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "mainTableView") {
            
            if( data[row]["focus"] == "true"){
                tableView.selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                tableView.scrollRowToVisible(row)
                
            }
            
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "linha") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "celulaLinha")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = data[row]["linha"] ?? ""
                
                return cellView
            }else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "instrucao"){
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "celulaInstrucao")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = data[row]["instrucao"] ?? ""
                
                return cellView
            }else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "atributo1") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "celulaAtributo1")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = data[row]["atributo1"] ?? ""
                
                return cellView
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "atributo2"){
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "celulaAtributo2")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = data[row]["atributo2"] ?? ""
                
                return cellView
            }
            else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "comentario"){
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "celulaComentario")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = data[row]["comentario"] ?? ""
                return cellView
            }
            
            
           
        }

        if tableView.identifier == NSUserInterfaceItemIdentifier(rawValue: "stackAddr") {
            if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "endereco") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "celulaEndereco")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = dataStack[row]["endereco"] ?? ""
                return cellView
            } else if tableColumn?.identifier == NSUserInterfaceItemIdentifier(rawValue: "valor") {
                let cellIdentifier = NSUserInterfaceItemIdentifier(rawValue: "celulaValor")
                guard let cellView = tableView.makeView(withIdentifier: cellIdentifier, owner: self) as? NSTableCellView else { return nil }
                cellView.textField?.stringValue = dataStack[row]["valor"] ?? ""
                return cellView
            }
        }
        return nil
    }
}

