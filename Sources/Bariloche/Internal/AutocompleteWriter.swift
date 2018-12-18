//
//  AutocompleteWriter.swift
//  Bariloche
//
//  Created by Tomas Camin on 29/12/2018.
//

import Foundation
import Rainbow

class AutocompleteWriter {    
    func writeZsh(executableName: String, command: Command) {
        Zsh().write(executableName: executableName, command: command)
    }
}

// MARK: - zsh

extension AutocompleteWriter {
    class Zsh {
        private let margin = "    "
        private lazy var margin2 = { margin + margin }()
        private lazy var margin3 = { margin + margin2 }()
        
        func write(executableName: String, command: Command) {
            guard let baseUrl = autocompletionUrl() else {
                print("Failed to find zsh autocompletion path, please file an issue here: https://github.com/Subito-it/Bariloche/issues".yellow)
                return
            }
            
            var autocompletion = "#compdef _\(executableName) \(executableName)\n\n"
            autocompletion += autocomplete(command: command, functionName: executableName)
            
            try? autocompletion.data(using: .utf8)?.write(to: baseUrl.appendingPathComponent("_\(executableName)"))            
        }
        
        private func autocompletionUrl() -> URL? {
            let autocompletePaths = Process().execute(command: "print -rl -- $fpath", shell: .zsh).components(separatedBy: "\n")
            
            let home = URL(fileURLWithPath: NSHomeDirectory()).path
            
            guard let path = autocompletePaths.first(where: { $0.contains(home) && $0.hasSuffix("/completions") }) else {
                return nil
            }
            
            return URL(fileURLWithPath: path)
        }
        
        private func autocomplete(command: Command, functionName: String) -> String {
            var template = """
            function _\(functionName) {
                local line

                _arguments -C \\
            \(functionFlags(command: command))
            \(functionArguments(command: command))
            \(functionSubcommands(command: command))
                    "*::arg:->args" \

            
            \(functionSubcommandsSwitch(command: command, functionName: functionName))
            }
            
            
            """
            
            template += command.subcommands().compactMap {
                guard let name = $0.name else { return nil }
                return autocomplete(command: $0, functionName: "\(functionName)_\(name)")
                }.joined(separator: "\n")
            
            return template
        }
        
        private func functionFlags(command: Command) -> String {
            guard command.validFlags().count > 0 else {
                return "\\"
            }
            
            var ret = [String]()
            for flag in command.validFlags() {
                var help = escape(string: flag.help)
                if !help.isEmpty {
                    help = "[\(help)]"
                }
                
                if let short = flag.short {
                    ret.append("\(margin2)\"-\(short)\(help)\" \\")
                }
                if let long = flag.long {
                    ret.append("\(margin2)\"--\(long)\(help)\" \\")
                }
            }
            return ret.joined(separator: "\n")
        }
        
        private func functionArguments(command: Command) -> String {
            guard command.validArguments().count > 0 else {
                return "\\"
            }
            
            var ret = [String]()
            var positionalIndex = 1
            for argument in command.validArguments() {
                var rawActions = ""
                switch argument.autocomplete {
                case .paths(let pattern):
                    rawActions = "_path_files -g '\(escape(string: pattern ?? "*"))'"
                case .files(let `extension`):
                    rawActions = "_path_files -g '*.\(escape(string: `extension` ?? "*"))(-.)'"
                case .directories:
                    rawActions = "_path_files -/"
                case .items(let autocompleteItems):
                    let raw = autocompleteItems.map { "\($0.value)\\:'\(escape(string: $0.help))'" }.joined(separator: " ")
                    rawActions = "((\(raw)))"
                case .none:
                    break
                }

                var help = escape(string: argument.help)
                if !help.isEmpty {
                    help = "[\(help)]"
                }
                
                switch argument.kind {
                case .positional where !(rawActions.isEmpty && help.isEmpty):
                    ret.append("\(margin2)\"\(positionalIndex)::\(help):\(rawActions)\" \\")
                    positionalIndex += 1
                case .variadic where !(rawActions.isEmpty && help.isEmpty):
                    ret.append("\(margin2)\"*::\(escape(string: argument.help)):\(rawActions)\" \\")
                case .named(let short, let long):
                    if let short = short {
                        ret.append("\(margin2)\"-\(short)=\(help):::\(rawActions)\" \\")
                    }
                    if let long = long {
                        ret.append("\(margin2)\"--\(long)=\(help):::\(rawActions)\" \\")
                    }
                case .positional, .variadic:
                    break
                }
            }
            
            guard ret.count > 0 else {
                return "\\"
            }
            
            return ret.joined(separator: "\n")
        }
        
        private func functionSubcommands(command: Command) -> String {
            guard command.subcommands().count > 0 else {
                return "\\"
            }
            
            let commandsData: [(name: String, help: String)] = command.subcommands().compactMap {
                ($0.name!, escape(string: $0.help))
            }
            
            let raw = commandsData.map { "\($0.name):'\($0.help)'" }.joined(separator: " ")
            return "\t\"1: :((\(raw)))\" \\"
        }
        
        private func functionSubcommandsSwitch(command: Command, functionName: String) -> String {
            guard command.subcommands().count > 0 else {
                return "\\"
            }
            
            let commandNames = command.subcommands().compactMap { $0.name }
            
            var ret = ["\tcase $line[1] in"]
            ret += commandNames.map { "\(margin3)\($0)) _\(functionName)_\($0) ;;" }
            ret += ["\tesac"]
            return ret.joined(separator: "\n")
        }
        
        private func escape(string: String?) -> String {
            guard let string = string else { return "" }
            
            return string.replacingOccurrences(of: "\\", with: "\\\\\\")
                .replacingOccurrences(of: "\"", with: "\\\"")
                .replacingOccurrences(of: "'", with: "\"\\'\"")
                .replacingOccurrences(of: "`", with: "\\`")
        }
    }
}
