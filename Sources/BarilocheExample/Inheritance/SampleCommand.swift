//
//  SampleCommand.swift
//  BarilocheExample
//
//  Created by tomas on 03/03/2019.
//

import Foundation
import Bariloche

class SampleCommand: BaseCommand {
    override var name : String? { return "sample" }
    override var usage: String? { return "Donec dignissim ante vel tristique consequat. Sed interdum molestie turpis, sit amet hendrerit est varius nec. Nulla ornare placerat suscipit." }
    override var help: String? { return "Lorem ipsum dolor sit amet, consectetur adipiscing elit." }
    
    let query = Argument<String>(name: "ARGUMENT", kind: .positional, optional: false, help: "A sample argument")
    
    override func run() -> Bool {        
        print("Running \(#file)")
        return true
    }
}
