//
//  CacheCommand.swift
//  BarilocheExample
//
//  Created by Tomas Camin on 19/12/2018.
//

import Foundation
import Bariloche

class CacheCommand: Command {
    let name: String? = "cache"
    let usage: String? = "Manipulate the download cache for pods, like printing the cache content or cleaning the pods cache."
    let help: String? = "Manipulate the CocoaPods cache"
    
    let flag = Flag(short: "s", long: "some-flag", help: "Some flag help")
    
    let option = Argument<String>(name: "type",
                                  kind: .named(short: "t", long: "type"),
                                  optional: true,
                                  help: "Some help for this argument",
                                  autocomplete: .items([.init(value: "type1", help: "Type 1 help"),
                                                        .init(value: "type2", help: "Type 2 help")]))
        
    func run() -> Bool {
        print("Running \(#file)")
        return true
    }        
}
