//
//  CocoaPodsCommand.swift
//  BarilocheExample
//
//  Created by Tomas Camin on 19/12/2018.
//

import Foundation
import Bariloche

class CocoaPodsCommand: Command {
    let usage: String? = "CocoaPods, the Cocoa library package manager."
    let subcommands: [Command] = [SearchCommand(), CacheCommand()]
    
    func run() -> Bool {
        return true
    }
}
