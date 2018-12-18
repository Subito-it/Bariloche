//
//  Process+Shell.swift
//  Bariloche
//
//  Created by Tomas Camin on 31/12/2018.
//

import Foundation

extension Process {
    enum Shell: String {
        case bash = "/bin/bash"
        case zsh = "/bin/zsh"
        
        var source: String {
            switch self {
            case .bash:
                return "source ~/.bash_profile;"
            case .zsh:
                return "source ~/.zshrc;"
            }
        }
    }
    
    @discardableResult
    func execute(command: String, shell: Shell) -> String {
        arguments = ["-c", "\(shell.source) \(command)"]
        
        let stdout = Pipe()
        standardOutput = stdout
        do {
            if #available(OSX 10.13, *) {
                executableURL = URL(fileURLWithPath: shell.rawValue)
                try run()
            } else {
                launchPath = shell.rawValue
                guard FileManager.default.fileExists(atPath: shell.rawValue) else {
                    fatalError("\(shell.rawValue) does not exists")
                }

                launch()
            }
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        waitUntilExit()
        
        let data = stdout.fileHandleForReading.readDataToEndOfFile()
        let result = String(data: data, encoding: String.Encoding.utf8) ?? ""
        return result.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
    }
}
