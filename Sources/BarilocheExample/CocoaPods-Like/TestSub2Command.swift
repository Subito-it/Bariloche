//
//  TestSub2Command.swift
//  BarilocheExample
//
//  Created by tomas on 07/03/2019.
//

import Foundation
import Bariloche

class TestSub2Command: Command {
    let name: String? = "sub2"
    let usage: String? = "Test command"
    let help: String? = "Test command"
        
    func run() -> Bool {
        print("Running \(#file)")
        return true
    }
}
