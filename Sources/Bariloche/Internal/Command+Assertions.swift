//
//  Command+Assertions.swift
//  Bariloche
//
//  Created by Tomas Camin on 20/12/2018.
//

import Foundation

extension Command {
    func integrityCheck() {
        argumentsIntegrityCheck()
        flagsIntegrityCheck()
        
        subcommands().forEach {
            assert($0.name != nil, "Subcommands should have a name!")
            $0.integrityCheck()
        }
    }
    
    private func argumentsIntegrityCheck() {
        let variadicArguments = validArguments().filter { $0.kind == .variadic }
        assert(variadicArguments.count < 2, "Only one variadic argument is allowed")
        assert(variadicArguments.count == 0 || validArguments().last?.kind == .variadic, "Variadic argument should be last")
        
        var previousArgument = self.validArguments().first
        argumentIntegrityCheck(previousArgument)
        for argument in validArguments().dropFirst() {
            argumentIntegrityCheck(argument)
            
            let invalidSequesce = (previousArgument?.kind == .variadic && argument.kind.isPositional)
            assert(!invalidSequesce, "For named argument \(argument.shortDescription) variable positional argument cannot be followed by another positional argument")
            previousArgument = argument
        }
    }
    
    private func argumentIntegrityCheck(_ argument: BaseArgument?) {
        guard let argument = argument else { return }
        
        assert(argument.name.contains(" ") == false, "For argument \(argument.shortDescription) name should not contain spaces")
        switch argument.kind {
        case .positional:
            break
        case .variadic:
            let argumentType = String(describing: type(of: argument))
            let regex = try! NSRegularExpression(pattern: "Argument<Array<[a-zA-Z]+>>")
            
            let arrayArgumentTypeFound = regex.firstMatch(in: argumentType, options: [], range: NSRange(location: 0, length: argumentType.count)) != nil
            
            assert(arrayArgumentTypeFound, "For variadic argument \(argument.shortDescription) an array type is expected (e.g [Int])")
        case .named(let short, let long):
            assert((short ?? "").contains(" ") == false, "For named argument \(argument.shortDescription) short should not contain spaces")
            assert((long ?? "").contains(" ") == false, "For named argument \(argument.shortDescription) long should not contain spaces")
            assert((short ?? "").contains("-") == false, "For named argument \(argument.shortDescription) short should not contain dash characters")
            assert((long ?? "").contains("-") == false, "For named argument \(argument.shortDescription) long should not contain dash characters")
            assert(short != nil || long != nil, "For named argument \(argument.shortDescription) at least short or long should be provided")
        }
    }
    
    private func flagsIntegrityCheck() {
        for flag in validFlags() {
            assert(flag.short != nil || flag.long != nil, "For flag at least one among short or long should be passed")
            assert((flag.short ?? "").contains(" ") == false, "For flag short should not contain spaces")
            assert((flag.long ?? "").contains(" ") == false, "For flag long should not contain spaces")
            assert((flag.short ?? "").contains("-") == false, "For flag short should not contain dash characters")
            assert((flag.long ?? "").starts(with: "-") == false, "For flag long should not contain dash characters")
        }
    }
}
