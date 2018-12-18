//
//  SearchCommand.swift
//  BarilocheExample
//
//  Created by Tomas Camin on 19/12/2018.
//

import Foundation
import Bariloche

class SearchCommand: Command {
    let name: String? = "search"
    let usage: String? = "Searches for pods, ignoring case, whose name, summary, description, or authors match `QUERY`. If the `--simple` option is specified, this will only search in the names of the pods."
    let help: String? = "Search for pods"
    let simple = Flag(short: nil, long: "simple", help: "Search only by name")

    let query = Argument<String>(name: "QUERY", kind: .positional, optional: false, help: "Search query")
    
    func run() -> Bool {
        print("Running \(#file)")
        return true
    }
}
