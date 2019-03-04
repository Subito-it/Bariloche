//
//  Flag.swift
//  Bariloche
//
//  Created by Tomas Camin on 15/12/2018.
//

public class Flag: Equatable, CustomStringConvertible {
    public let short: String?
    public let long: String?
    public let help: String?
    public var value: Bool = false
    public var runAction: (() -> Void)?
    
    public var description: String {
        var ret = [String]()
        if let shortDescription = short {
            ret.append("-\(shortDescription)")
        }
        if let longDescription = long {
            ret.append("--\(longDescription)")
        }
        return ret.joined(separator: ", ")
    }

    public init(short: String? = nil, long: String? = nil, help: String?, runAction: (() -> Void)? = nil) {
        self.short = short
        self.long = long
        self.help = help
        self.runAction = runAction
    }
    
    public static func == (lhs: Flag, rhs: Flag) -> Bool {
        return lhs.short == rhs.short &&
               lhs.long == rhs.long &&
               lhs.help == rhs.help
    }
    
    public static func == (lhs: Flag, rhs: String) -> Bool {
        let flags = lhs.description.components(separatedBy: ", ")
        return flags.contains(rhs)
    }

    public static func == (lhs: String, rhs: Flag) -> Bool {
        return rhs == lhs
    }
}

extension Flag {
    static let help = Flag(short: "h", long: "help", help: "Show help banner of specified command")
}

extension Array where Element == String {
    func contains(_ element: Flag) -> Bool {
        return first(where: { element == $0 }) != nil
    }
}
