//
//  BaseCommand.swift
//  BarilocheExample
//
//  Created by tomas on 03/03/2019.
//

import Foundation
import Bariloche

class BaseCommand: Command {
    var name: String? { return nil }
    var usage: String? { return nil }
    var help: String? { return nil }
    
    let version = Flag(short: "v", long: "version", help: "Show the version of the tool") { print("0.1.0") }
    
    @discardableResult
    func run() -> Bool {
        return true
    }
}
