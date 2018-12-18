//
//  Bariloche.swift
//  Bariloche
//
//  Created by Tomas Camin on 18/12/2018.
//

import Foundation

public class Bariloche {
    private let root: Command
    private let arguments: [String]
    private let executableName: String
    private let parser: Parser
    private let usagePrinter: UsagePrinter
    private let autocompleteWriter: AutocompleteWriter
    
    public convenience init(command: Command) {
        self.init(root: command)
    }
    
    init(root: Command,
         arguments: [String] = CommandLine.arguments,
         usagePrinter: UsagePrinter = UsagePrinter(),
         autocompleteWriter: AutocompleteWriter = AutocompleteWriter()) {
        self.root = root
        self.arguments = arguments
        self.executableName = URL(fileURLWithPath: arguments.first ?? "").lastPathComponent
        self.parser = Parser(root: root)
        self.usagePrinter = usagePrinter
        self.autocompleteWriter = autocompleteWriter
    }
    
    /// Begin parsing
    ///
    /// - Returns: an array containing all commands that were parsed successfully
    @discardableResult
    public func parse() -> [Command] {
        writeAutocompletionIfNeeded()
        
        let commandLineArguments = Array(arguments.dropFirst())
        switch parser.parse(arguments: commandLineArguments) {
        case .success(let parsedCommands):
            return parsedCommands.reversed()
        case .showUsage(let commands, let error):
            usagePrinter.output(executableName: executableName, commands: commands, error: error)
            return []
        }
    }
    
    /// Present a text and synchronously wait for data from stdin
    ///
    /// - Parameters:
    ///     - question: A text that is sent to stdout
    ///     - endOfMarker: Specifies which marker will return from stdin, the default value returns on first end-of-line ("\n")
    ///     - validate: Validation block, allows to reject the provided answer prompting question again by throwing an exception
    ///
    /// - Returns: the return value of the validate block (if implemented) or the converted value from sdtin
    @discardableResult
    public static func ask<Value>(_ question: String, secure: Bool = false, endOfMarker: String = "", validate: ((_ answer: Value) throws -> Value)? = nil) -> Value {
        print(question.yellow)
        
        let eof = endOfMarker + "\n"
        while (true) {
            var answer = ""
            
            while let line = readLine(strippingNewline: false, secure: secure) {
                answer += line
                guard !line.hasSuffix(eof) else { break }
            }
            
            answer = String(answer.prefix(max(0, answer.count - eof.count)))
            
            guard let value: Value = StringTypeConverter.convert(answer) else {
                print("\n\nInvalid value!\n".red)
                continue
            }
            
            if let validate = validate {
                do {
                    return try validate(value)
                } catch let error {
                    print("\n\n\(error.localizedDescription)\n".red)
                }
            } else {
                return value
            }
        }
    }
    
    private static func readLine(strippingNewline: Bool, secure: Bool) -> String? {
        if secure {
            let pwd = String(cString: getpass(""))
            return pwd.count > 0 ? (pwd + "\n") : nil
        } else {
            return Swift.readLine(strippingNewline: strippingNewline)
        }
    }
    
    private func writeAutocompletionIfNeeded() {
        if ProcessInfo.processInfo.environment["ZSH"] != nil {
            autocompleteWriter.writeZsh(executableName: executableName, command: root)
        }
    }
}
