//
//  ViewController.swift
//  VirtualMachine
//
//  Created by Victor Felipe dos Santos on 11/11/21.
//

import Cocoa

class ViewController: NSViewController {
    @IBOutlet weak var normalRadioButton: NSButton!
    @IBOutlet weak var passoRadioButton: NSButton!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Set the radio group's initial selection
        normalRadioButton.state = NSControl.StateValue.on
        // Do any additional setup after loading the view.
    }

    override var representedObject: Any? {
        didSet {

        }
    }

    @IBAction func radioButtonChanged(_ sender: AnyObject) {
    }
}

