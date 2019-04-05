//
//  AnyCharacterExpression.swift
//

import Foundation

/// An expression matching any literal character.
///
/// - note:     Represented by the `.` literal.
///
struct AnyCharacterExpression: Expression { }

extension AnyCharacterExpression: SymbolConvertible {
    
    var symbol: Symbol {
        return .any
    }
}

extension AnyCharacterExpression: CustomStringConvertible {
    
    var description: String {
        return "Any"
    }
}
