//
//  ConcatenatedExpression.swift
//

import Foundation

/// An expression encapsulating a number of subexpressions, which are matched in succession.
///
/// - note:     Represented by the `(...)` expression.
///
struct ConcatenatedExpression: Expression {
    var children: UnsafeArray<Expression>
    
    init(with children: UnsafeArray<Expression>) {
        self.children = children
    }
    
    init(_ children: Expression...) {
        self.init(with: UnsafeArray(children))
    }
}

extension ConcatenatedExpression: NFAConvertible {
    
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        
        guard let (head, tail) = self.children.unpack() else { fatalError() }
        
        let nfa = tail.reduce(into: NFA(from: head)) { (nfa, expression) in
            nfa.concatenate(with: NFA(from: expression))
        }
        
        // Default transitions
        initial.add(Transition(to: nfa.states.initial))
        nfa.states.terminal.add(Transition(to: terminal))
    }
}

extension ConcatenatedExpression: CustomStringConvertible {
    
    var description: String {
        let inner = self.children.map{ $0.description }.joined(separator: ", ")
        return "Concatenated(\(inner))"
    }
}
