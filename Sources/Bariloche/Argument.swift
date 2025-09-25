//
//  Argument.swift
//  Bariloche
//
//  Created by Tomas Camin on 21/12/2018.
//

import Foundation

public class Argument<Value>: BaseArgument {    
    public var value: Value? {
        guard let stringValue = stringValue else { return nil }
        
        if shouldUseCollectionConversion {
            let collectionValues = stringValue.components(separatedBy: Argument.Kind.variadicSeparator)

            return StringTypeConverter.convert(collectionValues)
        }

        return StringTypeConverter.convert(stringValue)
    }
    
    override var allowsMultipleValues: Bool {
        return super.allowsMultipleValues || isArrayValue
    }

    public override init(name: String, kind: Kind, optional: Bool, help: String? = nil, autocomplete: Autocomplete = .none) {
        super.init(name: name, kind: kind, optional: optional, help: help, autocomplete: autocomplete)
    }
    
    private var shouldUseCollectionConversion: Bool {
        return allowsMultipleValues
    }
    
    private var isArrayValue: Bool {
        return Value.self is AnyArrayValue.Type
    }
}

private protocol AnyArrayValue {}
extension Array: AnyArrayValue {}
