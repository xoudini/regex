//
//  ConcatenatedExpression.swift
//

import Foundation

/// An expression encapsulating a number of subexpressions, which are matched in succession.
///
/// - note:     Represented by the `(...)` expression.
///
struct ConcatenatedExpression: Expression {
//    var children: UnsafeArray<Expression>
    let children: [Expression]
    
    init(with children: UnsafeArray<Expression>) {
        self.children = children.map{ $0 }
    }
    
    init(_ children: Expression...) {
        self.init(with: UnsafeArray(children))
    }
}

extension ConcatenatedExpression: NFAConvertible {
    
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        guard let first = self.children.first else { fatalError() }
        let nfa = self.children.dropFirst().reduce(into: NFA(from: first)) { (nfa, expression) in
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
