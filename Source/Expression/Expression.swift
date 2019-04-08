//
//  Expression.swift
//

import Foundation


/// Protocol for expression type conformance.
///
public protocol Expression: NFAConvertible, CustomStringConvertible { }


/// Protocol for expression types containing convertible expressions.
///
public protocol NFAConvertible {
    
    /// Method for inserting an `NFA` between two states.
    ///
    /// - parameters:
    ///   - states:     A tuple of `State` instances.
    ///
    func insert(between states: (State, State))
}


/// Protocol for expressions directly convertible into `Symbol` instances.
///
protocol SymbolConvertible: NFAConvertible {
    var symbol: Symbol { get }
}

extension SymbolConvertible {
    
    /// Default implementation for types conforming to `SymbolConvertible`.
    ///
    /// - parameters:
    ///   - states:     A tuple of `State` instances.
    ///
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        let state = State()
        initial.add(Transition(to: state, matching: self.symbol))
        state.add(Transition(to: terminal))
    }
}
