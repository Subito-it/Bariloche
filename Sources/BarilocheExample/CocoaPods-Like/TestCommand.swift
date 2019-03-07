//
//  TestCommand.swift
//  BarilocheExample
//
//  Created by tomas on 07/03/2019.
//

import Foundation
import Bariloche

class TestCommand: Command {
    let name: String? = "test"
    let usage: String? = "Test command"
    let help: String? = "Test command"

    let subcommands: [Command] = [TestSub1Command(), TestSub2Command()]
    
    func run() -> Bool {
        print("Running \(#file)")
        return true
    }
}
