//
//  BaseArgument.swift
//  Bariloche
//
//  Created by Tomas Camin on 15/12/2018.
//

public class BaseArgument: Equatable, CustomStringConvertible {
    public enum Kind: Equatable {
        case positional
        case variadic
        case named(short: String?, long: String?)
    }
        
    public let name: String
    public let kind: Kind
    public let optional: Bool
    public let help: String?
    public let autocomplete: Autocomplete

    var stringValue: String?
        
    public var description: String {
        switch kind {
        case .positional:
            return optional ? "[\(name)]" : name
        case .variadic:
            return optional ? "[\(name) ...]" : "\(name) ..."
        case .named:
            let ret = kind.namedParameters.joined(separator: ", ") + "="
            return ret + (optional ? "[\(name)]" : name)
        }
    }
    
    public var shortDescription: String {
        switch kind {
        case .positional, .variadic:
            return description
        case .named(let short, let long):
            if let short = short {
                return "-\(short)=" + (optional ? "[\(name)]" : name)
            }
            if let long = long {
                return "--\(long)=" + (optional ? "[\(name)]" : name)
            }
            
            return description
        }
    }
    
    public var longDescription: String {
        switch kind {
        case .positional, .variadic:
            return description
        case .named(let short, let long):
            if let long = long {
                return "--\(long)=" + (optional ? "[\(name)]" : name)
            }
            if let short = short {
                return "-\(short)=" + (optional ? "[\(name)]" : name)
            }
            
            return description
        }
    }
    
    init(name: String, kind: Kind, optional: Bool, help: String?, autocomplete: Autocomplete) {
        self.name = name
        self.kind = kind
        self.optional = optional
        self.help = help
        self.autocomplete = autocomplete
    }
}

extension BaseArgument {
    public static func == (lhs: BaseArgument, rhs: BaseArgument) -> Bool {
        return lhs.description == rhs.description && lhs.kind == rhs.kind
    }
}

extension BaseArgument.Kind {
    static let variadicSeparator = "\u{2}"
    
    var isPositional: Bool {
        switch self {
        case .positional, .variadic:
            return true
        default:
            return false
        }
    }
    
    var isNamed: Bool {
        switch self {
        case .named:
            return true
        default:
            return false
        }
    }
    
    var namedParameters: [String] {
        switch self {
        case .named(let short, let long):
            var ret = [String]()
            if let short = short {
                ret.append("-\(short)")
            }
            if let long = long {
                ret.append("--\(long)")
            }
            return ret
        default:
            return []
        }
    }
}
