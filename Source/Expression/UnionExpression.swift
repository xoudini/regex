//
//  UnionExpression.swift
//

import Foundation

/// An expression encapsulating a number of subexpressions, which are conditionally matched.
///
/// - note:     Represented by the `...|...` expression.
///
struct UnionExpression: Expression {
    var alternatives: [Expression]
    
    init(_ alternatives: Expression...) {
        self.alternatives = alternatives.reduce(into: []) { (accumulator, next) in
            if let expression = next as? UnionExpression {
                accumulator.append(contentsOf: expression.alternatives)
            } else {
                accumulator.append(next)
            }
        }
    }
    
    mutating func append(_ expression: Expression) {
        self.alternatives.append(expression)
    }
}

extension UnionExpression: NFAConvertible {
    
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        guard let first = self.alternatives.first else { fatalError() }
        let nfa = self.alternatives.dropFirst().reduce(into: NFA(from: first)) { (nfa, expression) in
            nfa.union(with: NFA(from: expression))
        }
        
        // Default transitions
        initial.add(Transition(to: nfa.states.initial))
        nfa.states.terminal.add(Transition(to: terminal))
    }
}

extension UnionExpression: CustomStringConvertible {
    
    var description: String {
        let inner = self.alternatives.map{ $0.description }.joined(separator: ", ")
        return "Union(\(inner))"
    }
}
