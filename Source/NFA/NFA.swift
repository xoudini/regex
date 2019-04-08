//
//  NFA.swift
//

import Foundation

/// Non-deterministic finite automaton implementation.
///
public class NFA {
    /// A tuple holding the initial and terminal states.
    var states: (initial: State, terminal: State)
    
    /// Designated initializer. Creates an empty NFA with an epsilon-transition from
    /// the initial state to the terminal state.
    init() {
        let (initial, terminal) = (State(category: .initial), State(category: .terminal))
        initial.add(Transition(to: terminal))
        self.states = (initial, terminal)
    }
    
    /// Designated initializer. Creates an NFA with a single standard `State`, and an
    /// epsilon-transition from the initial state to the standard state, and a
    /// conditional transition from the standard state to the terminal state.
    ///
    /// - parameters:
    ///   - state:      The `State` to embed between the initial and terminal states.
    ///   - symbol:     The `Symbol` to match in order to pass to the terminal state.
    ///
    /// - warning:      The given `State` can not be of initial or terminal type.
    ///
    init(with state: State, matching symbol: Symbol) {
        guard case .standard = state.category else { fatalError() }
        
        let (initial, terminal) = (State(category: .initial), State(category: .terminal))
        initial.add(Transition(to: state))
        state.add(Transition(to: terminal, matching: symbol))
        self.states = (initial, terminal)
    }
    
    /// Designated initializer. Recursively creates an NFA from an expression parse tree.
    ///
    /// - parameters:
    ///   - expression: An expression, which may be a wrapper for another expression.
    ///
    public init(from expression: Expression) {
        let states = (State(category: .initial), State(category: .terminal))
        expression.insert(between: states)
        self.states = states
    }
    
    /// Concatenation operation.
    ///
    /// - parameters:
    ///   - other:      The `NFA` to concatenate to the end of this `NFA`.
    ///
    func concatenate(with other: NFA) {
        self.states.terminal.add(Transition(to: other.states.initial))
        self.states.terminal = other.states.terminal
    }
    
    /// Union operation.
    ///
    /// - parameters:
    ///   - other:      The `NFA` to use as an alternative for this `NFA`.
    ///
    func union(with other: NFA) {
        let (initial, terminal) = (State(category: .initial), State(category: .terminal))
        initial.add(Transition(to: self.states.initial))
        initial.add(Transition(to: other.states.initial))
        self.states.terminal.add(Transition(to: terminal))
        other.states.terminal.add(Transition(to: terminal))
        self.states = (initial, terminal)
    }
    
    /// Matching function.
    ///
    /// - parameters:
    ///   - input:      The input to match against.
    ///
    /// - returns:      A boolean value, depending on whether the input was matched.
    ///
    public func matches(_ input: String) -> Bool {
        let queue: Queue<State> = [self.states.initial]
        
        for character in input {
            var remaining = queue.count
            
            while remaining != 0, let state = queue.dequeue() {
                remaining -= 1
                queue.enqueue(contentsOf: state.destinations(from: character))
            }
        }
        
        return queue.flatMap{ $0.closure }.contains{ state in state === self.states.terminal }
    }
}
