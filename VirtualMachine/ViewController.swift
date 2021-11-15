//
//  ViewController.swift
//  VirtualMachine
//
//  Created by Victor Felipe dos Santos on 11/11/21.
//

import Cocoa
import Foundation

class ViewController: NSViewController {
    @IBOutlet weak var normalRadioButton: NSButton!
    @IBOutlet weak var passoRadioButton: NSButton!
    
    override func viewWillAppear() {
        super.viewWillAppear()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the radio group's initial selection
        normalRadioButton.state = NSControl.StateValue.on
    
        let filepath = Bundle.main.path(forResource: "gera1", ofType: "txt") ?? ""
    
            do {
                let contents = try String(contentsOfFile: filepath)
                print(contents)
                //  Now push second ViewController form here with contents.
            } catch {
            
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

