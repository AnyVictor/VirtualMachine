//
// Created by Raven on 13/11/21.
//

import Foundation
import Cocoa

class MachineCodeInterpreter {
    
    var line = LinkedList<code>();
    var fileContent: String;
    
    init(fileContent: String) {
        self.fileContent = fileContent
    }
    
    func machine(fileContent: String) {
        let string = fileContent.components(separatedBy: .newlines)
        
        for chars in string {
            
            if chars == "\t" {
                
                print()
                
            }
            
        }
    }
    
}
