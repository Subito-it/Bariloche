//
//  Process+Shell.swift
//  Bariloche
//
//  Created by Tomas Camin on 31/12/2018.
//

import Foundation

extension Process {
    enum Shell: String, CaseIterable {
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

        var url: URL {
            return URL(fileURLWithPath: rawValue)
        }

        static func current() -> Shell {
            let fm = FileManager.default
            let homeUrl = URL(fileURLWithPath: NSHomeDirectory())

            for shell in Shell.allCases {
                if shell == .bash, fm.fileExists(atPath: homeUrl.appendingPathComponent(".bash_profile").path) {
                    return shell
                } else if shell == .zsh, fm.fileExists(atPath: homeUrl.appendingPathComponent(".zshrc").path) {
                    return shell
                }
            }

            fatalError("No known shell found!")
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
