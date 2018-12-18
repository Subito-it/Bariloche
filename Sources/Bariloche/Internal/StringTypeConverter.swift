//
//  StringTypeConverter.swift
//  Bariloche
//
//  Created by Tomas Camin on 08/01/2019.
//

import Foundation

struct StringTypeConverter {
    static func convert<Value>(_ value: [String]) -> Value? {
        guard value.count > 0 else { return nil }
        
        switch Value.self {
        case is [URL].Type:
            return value.compactMap { url($0) } as? Value
        case is [Bool].Type:
            return value.compactMap { Bool(string: $0) } as? Value
        case is [TimeInterval].Type:
            return value.compactMap { TimeInterval($0) } as? Value
        case is [Float].Type:
            return value.compactMap { Float($0) } as? Value
        case is [Int].Type:
            return value.compactMap { Int($0) } as? Value
        case is [UInt].Type:
            return value.compactMap { UInt($0) } as? Value
        case is [String].Type:
            return value as? Value
        default:
            fatalError("Unsupported Value type")
        }
    }
    
    static func convert<Value>(_ value: String) -> Value? {
        switch Value.self {
        case is URL.Type:
            return url(value) as? Value
        case is Bool.Type:
            return Bool(string: value) as? Value
        case is TimeInterval.Type:
            return TimeInterval(value) as? Value
        case is Float.Type:
            return Float(value) as? Value
        case is Int.Type:
            return Int(value) as? Value
        case is UInt.Type:
            return UInt(value) as? Value
        case is String.Type:
            return value as? Value
        default:
            fatalError("Unsupported Value type")
        }
    }
    
    private static func url(_ stringValue: String?) -> URL? {
        guard var stringValue = stringValue else { return nil }
        
        let fileManager = FileManager.default
        
        if stringValue.hasPrefix("~") {
            let homeUrl: URL
            if #available(OSX 10.12, *) {
                homeUrl = fileManager.homeDirectoryForCurrentUser
            } else {
                homeUrl = URL(fileURLWithPath: NSHomeDirectory())
            }
            stringValue = homeUrl.path + stringValue.suffix(stringValue.count - 1)
        }
        
        let isAbsolute = stringValue.hasPrefix("/")
        let pwd = URL(fileURLWithPath: fileManager.currentDirectoryPath)
        let isNetwork = ["http", "https", "ssh", "scp", "ftp"].contains(where: { stringValue.hasPrefix("\($0)://")} )
        switch (isAbsolute, isNetwork) {
        case (_, true):
            return URL(string: stringValue)
        case (true, _):
            return URL(fileURLWithPath: stringValue)
        case (false, _):
            if #available(OSX 10.11, *) {
                return URL(fileURLWithPath: stringValue, relativeTo: pwd)
            } else {
                return pwd.appendingPathComponent(stringValue)
            }
        }
    }

}

private extension Bool {
    init?(string: String) {
        switch string.lowercased() {
        case "true", "yes", "y", "1":
            self = true
        case "false", "no", "n", "0":
            self = false
        default:
            return nil
        }
    }
}
