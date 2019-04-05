//
//  OptionalExpression.swift
//

import Foundation

/// An expression encapsulating another expression, which is optionally matched.
///
/// - note:     Represented by the `?` literal.
///
struct OptionalExpression: Expression {
    let inner: Expression
    
    init(_ inner: Expression) {
        self.inner = inner
    }
}

extension OptionalExpression: NFAConvertible {
    
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        let nfa = NFA(from: self.inner)
        
        // Default transitions
        initial.add(Transition(to: nfa.states.initial))
        nfa.states.terminal.add(Transition(to: terminal))
        
        // Handle optional case
        initial.add(Transition(to: terminal))
    }
}

extension OptionalExpression: CustomStringConvertible {
    
    var description: String {
        return "Optional(\(self.inner.description))"
    }
}
