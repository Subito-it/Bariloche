//
//  Command.swift
//  Bariloche
//
//  Created by Tomas Camin on 13/12/2018.
//

import Foundation

struct Parser {
    enum Error: Swift.Error {
        case invalidArgument(String)
        case missingArgument([BaseArgument])
    }
    
    enum Result {
        case success([Command])
        case showUsage([Command], Error?)
    }
    
    private let root: Command
    
    init(root: Command) {
        root.integrityCheck()
        self.root = root
    }
    
    func parse(arguments: [String]) -> Result {
        var parsedCommands = [root]
        var commandLineArguments = prepareArguments(arguments)
        
        while commandLineArguments.count > 0 {
            guard let currentArgument = commandLineArguments.first,
                  let currentCommand = parsedCommands.last else {
                fatalError("Unhandled")
            }
            
            if let subcommand = parseSubcommand(from: currentArgument, command: currentCommand) {
                commandLineArguments.remove(at: 0)
                parsedCommands.append(subcommand)

                continue
            }

            if let _ = parseFlag(from: currentArgument, command: currentCommand) {
                commandLineArguments.remove(at: 0)
                continue
            }
            
            if let argument = parseArgument(from: commandLineArguments, command: currentCommand) {
                let removeCount: Int
                switch argument.kind {
                case .named:
                    removeCount = 2
                case .positional, .variadic:
                    removeCount = 1
                }
                
                commandLineArguments = Array(commandLineArguments.dropFirst(removeCount))
                continue
            }
            
            let error: Error = .invalidArgument(currentArgument)
            return .showUsage(parsedCommands, error)
        }
        
        var showUsage = false
        for parsedCommand in parsedCommands {
            let commandArguments = parsedCommand.validArguments().filter { $0.stringValue != nil }
            let requiredArguments = parsedCommand.validArguments().filter { !$0.optional }
            let missingArguments = requiredArguments.filter { !commandArguments.contains($0) }
            
            let shouldShowUsage = (parsedCommand.shouldShowUsage() || !missingArguments.isEmpty)
            
            guard !shouldShowUsage else {
                let error: Parser.Error? = missingArguments.count > 0 ? .missingArgument(missingArguments) : nil
                return .showUsage(parsedCommands, error)
            }
            
            guard parsedCommand.run() else {
                showUsage = true
                break
            }
        }
        
        return showUsage || arguments.count == 0 ? .showUsage(parsedCommands, nil) : .success(parsedCommands)
    }
    
    private func parseFlag(from lineArgument: String, command: Command) -> Flag? {
        for flag in command.validFlags() {
            if ["-\(flag.short ?? "")", "--\(flag.long ?? "")"].contains(lineArgument) {
                flag.value = true
                return flag
            }
        }
        
        return nil
    }
    
    private func parseArgument(from lineArguments: [String], command: Command) -> BaseArgument? {
        outerLoop: for argument in command.validArguments() {
            guard argument.stringValue == nil || argument.kind == .variadic else { continue }
            
            switch argument.kind {
            case .named(let short, let long):
                guard lineArguments.count > 1 else {
                    continue
                }
                guard !lineArguments[1].starts(with: "-") else {
                    continue
                }
                if ["-\(short ?? "")", "--\(long ?? "")"].contains(lineArguments[0]) {
                    argument.stringValue = lineArguments[1]
                    return argument
                }
            case .positional where !lineArguments[0].hasPrefix("-"):
                argument.stringValue = lineArguments.first
                return argument
            case .variadic where !lineArguments[0].hasPrefix("-"):
                argument.stringValue = (argument.stringValue ?? "") + Argument<Any>.Kind.variadicSeparator + (lineArguments.first ?? "")
                return argument
            default:
                continue
            }
        }
        
        return nil
    }
    
    private func parseSubcommand(from argument: String, command: Command) -> Command? {
        return command.subcommands().first { $0.name == argument }
    }
    
    private func prepareArguments(_ arguments: [String]) -> [String] {
        var ret = [String]()
        
        let optionStackingRegex = try? NSRegularExpression(pattern: "^-[a-z]{2,}$", options: .caseInsensitive)
        let equalSeparatedRegex = try? NSRegularExpression(pattern: "^-+\\w*=", options: .caseInsensitive)
        
        for argument in arguments {
            let argumentRange = NSRange(location: 0, length: argument.count)
            
            if optionStackingRegex?.matches(in: argument, range: argumentRange).count != 0 {
                ret += Array(argument).dropFirst().map { "-\($0)" }
            } else if let equalSeparated = equalSeparatedRegex?.matches(in: argument, range: argumentRange),
                      let separationIndex = equalSeparated.first?.range.upperBound, separationIndex > 0 {
                ret.append(String(argument.prefix(separationIndex - 1)))
                let valueIndex = argument.index(argument.startIndex, offsetBy: separationIndex)
                ret.append(String(argument.suffix(from: valueIndex)))
            } else {
                ret.append(argument)
            }
        }
        
        return ret
    }
}

extension Parser.Error: CustomStringConvertible {
    var description: String {
        switch self {
        case .invalidArgument(let name):
            return "Invalid argument `\(name)`"
        case .missingArgument(let arguments):
            let description = arguments.map { $0.longDescription }.joined(separator: ", ")
            if arguments.count > 0 {
                return "Missing required arguments `\(description)`"
            } else {
                return "Missing required argument `\(description)`"
            }
        }
    }
}

private extension Parser.Result {
    var isSuccess: Bool {
        switch self {
        case .success:
            return true
        default:
            return false
        }
    }
    
    var isShowUsage: Bool {
        switch self {
        case .showUsage:
            return true
        default:
            return false
        }
    }
    
    var commands: [Command] {
        switch self {
        case .showUsage(let commands, _):
            return commands
        default:
            return []
        }
    }
    
    var error: Error? {
        switch self {
        case .showUsage(_, let error):
            return error
        default:
            return nil
        }
    }
}
