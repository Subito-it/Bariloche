//
//  Command.swift
//  Bariloche
//
//  Created by Tomas Camin on 15/12/2018.
//

public protocol Command: AnyObject {
    var name: String? { get }
    var usage: String? { get }
    var help: String? { get }
    
    func shouldShowUsage() -> Bool
    
    /**
     Invoked when the command is successfully parsed
     
     - Returns: Return true if parsing should proceed looking for subcommands.
                If no command returns true help is shown.
     */
    func run() -> Bool
}

// MARK: - Default implementation

public extension Command {
    var name: String? { return nil }
    var help: String? { return nil }
    var usage: String? { return nil }

    func shouldShowUsage() -> Bool {
        let parsedFlags = validFlags().filter { $0.value }
        return parsedFlags.contains(Flag.help)
    }
}
