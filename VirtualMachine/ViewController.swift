//
//  ViewController.swift
//  VirtualMachine
//
//  Created by Victor Felipe dos Santos on 11/11/21.
//

import Cocoa
import Foundation



extension ViewController: NSTableViewDataSource, NSTableViewDelegate {
    
  func numberOfRows(in tableView: NSTableView) -> Int {
    return (data.count)
  }

  func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
    let person = data[row]
    
    guard let cell = tableView.makeView(withIdentifier: tableColumn!.identifier, owner: self) as? NSTableCellView else { return nil }
      
      if(tableColumn!.identifier.rawValue == "focus" && person[tableColumn!.identifier.rawValue] == "true"){
          cell.textField?.drawsBackground = true
          cell.textField?.backgroundColor = NSColor.blue
      }
      print("oi", cell)
     
      cell.textField?.stringValue = person[tableColumn!.identifier.rawValue] ?? ""
      //print("oi", person)
    return cell
  }
        
}


class ViewController: NSViewController {
    @IBOutlet weak var normalRadioButton: NSButton!
    @IBOutlet weak var passoRadioButton: NSButton!
    @IBOutlet weak var stackAddr : NSTableView!


    var data: [[String: String]] = [["endereco":"1", "valor":"1"]]

    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    func reloadData(){
        DispatchQueue.main.async {
            //self.view.backgroundC
            //self.stackAddr.beginUpdates()
                
            self.stackAddr.reloadData()
            
           // self.stackAddr.endUpdates()
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
       
        // reload tableview
        //stackAddr.reloadData()

       
        //self.stackAddr.endUpdates()
        // Set the radio group's initial selection
        normalRadioButton.state = NSControl.StateValue.on
    
        //let filepath = Bundle.main.path(forResource: "gera1", ofType: "txt") ?? ""
        let filepath = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask)[0].appendingPathComponent("output.txt")
        
            do {
                
                let contents = try String(contentsOf: filepath)
                let queue = DispatchQueue(label: "work-queue")

                queue.async{
                    let VirtualMachine : MachineCodeInterpreter = MachineCodeInterpreter(fileContent: contents)

                    VirtualMachine.analyser(stackUI: &self.data, stackAddr: self.reloadData )
                    //self.stackAddr.reloadData()
                }
                DispatchQueue.main.async {
                    //self.view.backgroundC
                    
                }
                
                

                //print(contents)
                //  Now push second ViewController form here with contents.
            } catch {
                print("erro", error)
                // contents could not be loaded
            }
        }

    override var representedObject: Any? {
        didSet {

        }
    }

    @IBAction func radioButtonChanged(_ sender: AnyObject) {
    }
}

