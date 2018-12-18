//
//  UsagePrinter.swift
//  Bariloche
//
//  Created by Tomas Camin on 18/12/2018.
//

import Foundation
import Rainbow

struct UsagePrinter {
    private let printer: OutputStreamer

    private let tab = "    "
    private let width = 80
    private let subcommandsPrefix = "+ "
    
    init(printer: OutputStreamer = DefaultOutputStreamer()) {
        self.printer = printer
    }
    
    func output(executableName: String, commands: [Command] = [], error: Parser.Error? = nil) {
        outputUsage(executableName: executableName, commands: commands)
        let indentation = descriptionIndentation(commands: commands)
        outputSubcommands(subcommands: commands.last?.subcommands(), indentation: indentation)
        outputOptions(arguments: commands.last?.validArguments(), flags: commands.last?.validFlags(), indentation: indentation)

        if let error = error {
            print(error.description.red)
            print("\n")
        }
    }
}

extension UsagePrinter {
    private func outputUsage(executableName: String, commands: [Command]) {
        var cmds = [executableName.lightGreen]
        cmds += commands.compactMap { $0.name?.lightGreen }
        
        if commands.last?.subcommands().count != 0 {
            cmds += ["COMMAND".lightGreen]
        } else {
            cmds += commands.last?.validArguments().filter({ $0.kind.isNamed && !$0.optional }).map { $0.shortDescription.lightRed } ?? []
            cmds += commands.last?.validArguments().filter({ $0.kind.isPositional }).map { $0.description.lightRed } ?? []
        }
        
        if let command = commands.last,
           let multilineUsage = command.usage {
            print("Usage:\n".underline)
            print("\(tab)$ \(cmds.joined(separator: " "))\n")
            
            for usage in multilineUsage.components(separatedBy: "\n") {
                guard usage.count > 0 else {
                    print("")
                    continue
                }
                for line in highlightArgumentsAndFlags(for: command, description: usage).wordWrap(length: width) {
                    print("\(tab)  \(line)")
                }
            }
            print("")
        }
    }
    
    private func highlightArgumentsAndFlags(for command: Command, description: String) -> String {
        var ret = description
        for argument in command.validArguments() {
            let arg = "`\(argument.name)`"
            ret = ret.replacingOccurrences(of: arg, with: arg.red)
            if argument.kind.isNamed {
                let replacements = argument.kind.namedParameters.map { "`\($0)`" }
                for replacement in replacements {
                    ret = ret.replacingOccurrences(of: replacement, with: replacement.blue)
                }
            }
        }
        for flag in command.validFlags() {
            let description = "`\(flag.description)`"
            ret = ret.replacingOccurrences(of: description, with: description.blue)
        }
        return ret
    }
    
    private func outputSubcommands(subcommands: [Command]?, indentation: Int) {
        guard let subcommands = subcommands,
            subcommands.count > 0 else { return }
        print("Commands:\n".underline)
        let subcommandsHelp: [String] = subcommands.compactMap { cmd in
            guard let name = cmd.name else { return nil }
            let deltaStart = indentation - name.count - subcommandsPrefix.count
            return "\(tab)\(subcommandsPrefix)\(name)".green + Array(repeating: " ", count: deltaStart) + (cmd.help ?? cmd.usage ?? "")
        }
        print(subcommandsHelp.joined(separator: "\n"))
        print("\n")
    }
    
    private func outputOptions(arguments: [BaseArgument]?, flags: [Flag]?, indentation: Int) {
        guard let flags = flags else { return }
        guard let arguments = arguments else { return }
        guard flags.count + arguments.count > 0 else { return }

        print("Options:\n".underline)
        var optionsHelp = [String]()
        
        let argumentsOptionsHelp: (Bool) -> [String] = { optional in
            var help: [String] = arguments.sorted { $0.shortDescription < $1.shortDescription }
                                .filter { $0.optional == optional }
                                .map { argument in
                let description = "\(self.tab)\(argument.description)"

                var optionHelp = description.blue
                if let help = argument.help {
                    var wrapped = help.wordWrap(length: self.width + self.tab.count - indentation).map { String(repeating: " ", count: indentation) + $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                    wrapped[0] = optionHelp + wrapped[0].dropFirst(description.count)
                    optionHelp = wrapped.joined(separator: "\n")
                }

                return optionHelp
            }

            if help.count > 0 {
                help.append("")
            }

            return help
        }
        
        let mandatoryArgumentsOptionsHelps = argumentsOptionsHelp(false)
        let optionalArgumentsOptionsHelps = argumentsOptionsHelp(true)
        
        optionsHelp += mandatoryArgumentsOptionsHelps + optionalArgumentsOptionsHelps
        
        optionsHelp += flags.sorted(by: { $0.description < $1.description }).compactMap { flag in
            let description = "\(tab)\(flag.description)"
            
            var optionHelp = description.blue
            if let help = flag.help {
                var wrapped = help.wordWrap(length: width + tab.count - indentation).map { String(repeating: " ", count: indentation) + $0.trimmingCharacters(in: .whitespacesAndNewlines) }
                wrapped[0] = optionHelp + wrapped[0].dropFirst(description.count)
                optionHelp = wrapped.joined(separator: "\n")
            }
            
            return optionHelp
        }
        
        print(optionsHelp.joined(separator: "\n"))
        print("\n")
    }
    
    private func descriptionIndentation(commands: [Command]) -> Int {
        var indentation = 12
        if let subcommands = commands.last?.subcommands(), subcommands.count > 0 {
            let longestSubcommandName = (subcommands.compactMap { $0.name?.count }.sorted().last ?? 0) + subcommandsPrefix.count
            indentation = max(indentation, longestSubcommandName)
        }
        
        if let options = commands.last?.validFlags(), options.count > 0 {
            let longestOptionName = options.map { $0.description.count }.sorted().last
            indentation = max(indentation, longestOptionName ?? 0)
        }
        
        if let namedArguments = commands.last?.validArguments(), namedArguments.count > 0 {
            let longestNamedArgument = namedArguments.map{ $0.description.count }.sorted().last
            indentation = max(indentation, longestNamedArgument ?? 0)
        }
        
        return indentation + 7
    }
    
    private func print(_ text: String) {
        printer.print(text)
    }
}

private extension String {
    func wordWrap(length: Int) -> [String] {
        let words = components(separatedBy: " ")

        var ret = [String]()
        var current = ""
        var currentCount = Int.max
        for word in words {
            if currentCount < length {
                current += " " + word
                currentCount += 1 + word.rainbowRaw().count
            } else {
                ret.append(current)
                current = word
                currentCount = word.rainbowRaw().count
            }
        }
        if !current.isEmpty {
            ret.append(current)
        }
        
        return Array(ret.dropFirst())
    }
    
    private func rainbowRaw() -> String {
        // The implementation of Rainbow's String+raw() works only if the string begins/ends with escape markers
        // We naively remove markers with regex here
        let token = "\u{001B}\\[\\d+m"
        guard let regex = try? NSRegularExpression(pattern: "\(token)", options: []) else {
            return self
        }
        
        let range = NSRange(location: 0, length: count)
        return regex.stringByReplacingMatches(in: self, range: range, withTemplate: "")
    }
}
