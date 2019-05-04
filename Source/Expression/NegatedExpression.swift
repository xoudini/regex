//
//  NegatedExpression.swift
//

import Foundation

/// An expression encapsulating another expression, the complement
/// of which is matched.
///
/// - note:     Represented by the `^` literal.
///
struct NegatedExpression: Expression {
    let inner: Expression & SymbolConvertible
    
    init(_ inner: Expression & SymbolConvertible) {
        self.inner = inner
    }
}

extension NegatedExpression: SymbolConvertible {
    
    var symbol: Symbol {
        return .not(self.inner.symbol)
    }
}

extension NegatedExpression: CustomStringConvertible {
    
    var description: String {
        return "Negated(\(self.inner.description))"
    }
}
