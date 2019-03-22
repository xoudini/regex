//
//  ParserContext.swift
//

import Foundation

/// Context type used during parsing.
///
class ParserContext {
    
    /// A state type used for tracking the context during parsing.
    ///
    enum State {
        case none
        case escaped
        case group
        case set
    }
    
    /// A stack to keep track of the states during parsing.
    private let states: Stack<State>
    
    /// The current state.
    var state: State {
        return self.states.peek ?? .none
    }
    
    /// Designated initializer.
    ///
    init() {
        self.states = Stack()
    }
    
    /// Enters the given state.
    ///
    /// - parameters:
    ///   - state:  The `State` to enter.
    ///
    func enter(state: State) {
        self.states.push(state)
    }
    
    /// Exits the current state.
    ///
    /// - note:     No guarantees are made.
    /// - todo:     Perhaps this should require the state to be exited as
    ///             argument, and throw if the current state doesn't match.
    ///
    func exit() {
        self.states.pop()
    }
}
