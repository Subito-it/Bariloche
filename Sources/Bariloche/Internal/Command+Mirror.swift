//
//  Command+Assertions.swift
//  Bariloche
//
//  Created by Tomas Camin on 3/3/2019.
//

import Foundation

extension Command {
    func subcommands() -> [Command] {
        var ret = mirrorValues().compactMap { $0 as? Command }
        ret += mirrorValues().compactMap { $0 as? [Command] }.flatMap { $0 }
        
        return ret
    }
    
    func validFlags() -> [Flag] {
        var ret = mirrorValues().compactMap { $0 as? Flag }
        ret += mirrorValues().compactMap { $0 as? [Flag] }.flatMap { $0 }
        ret.append(Flag.help)
        
        return ret
    }
    
    func validArguments() -> [BaseArgument] {
        var ret = mirrorValues().compactMap { $0 as? BaseArgument }
        ret += mirrorValues().compactMap { $0 as? [BaseArgument] }.flatMap { $0 }
        
        return ret
    }
    
    private func mirrors() -> [Mirror] {
        var result = [Mirror?]()
        
        result.append(Mirror(reflecting: self))
        while let mirror = result.last as? Mirror {
            result.append(mirror.superclassMirror)
        }
        
        return result.compactMap { $0 }
    }
    
    private func mirrorValues() -> [Any] {
        return mirrors().flatMap { $0.children.map { $0.value } }
    }
}
