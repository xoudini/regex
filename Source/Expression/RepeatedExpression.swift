//
//  RepeatedExpression.swift
//

import Foundation

/// An expression encapsulating another expression, which is optionally matched repeatedly.
///
/// - note:     Represented by the `*` literal.
///
struct RepeatedExpression: ExpressionConvertible {
    let inner: ExpressionConvertible
    
    init(_ inner: ExpressionConvertible) {
        self.inner = inner
    }
}

extension RepeatedExpression: NFAConvertible {
    
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        let nfa = NFA(from: self.inner)
        
        // Default transitions
        initial.add(Transition(to: nfa.states.initial))
        nfa.states.terminal.add(Transition(to: terminal))
        
        // Handle optional case
        initial.add(Transition(to: terminal))
        
        // Handle repeating case
        nfa.states.terminal.add(Transition(to: nfa.states.initial))
    }
}

extension RepeatedExpression: CustomStringConvertible {
    
    var description: String {
        return "Repeated(\(self.inner.description))"
    }
}
