//
//  Autocomplete.swift
//  Bariloche
//
//  Created by Tomas Camin on 02/01/2019.
//

import Foundation

public enum Autocomplete {
    case none
    case items(_ items: [Item])
    // Files matching a particular extension (e.g `json`).
    // If no extension is provided only files will match
    case files(_ extension: String?)
    // Directory only
    case directories
    // Autocomplete filesystem items matching a particular pattern
    // refer to http://zsh.sourceforge.net/Doc/Release/Completion-System.html#Completion-System
    case paths(_ pattern: String?)
}

extension Autocomplete {
    public struct Item {
        let value: String
        let help: String?
        
        public init(value: String, help: String? = nil) {
            self.value = value
            self.help = help
        }
    }
}
