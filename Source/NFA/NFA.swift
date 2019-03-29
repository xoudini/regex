//
//  NFA.swift
//

import Foundation

class NFA {
    var states: (initial: State, terminal: State)
    
    init() {
        let (initial, terminal) = (State(category: .initial), State(category: .terminal))
        initial.add(Transition(to: terminal))
        self.states = (initial, terminal)
    }
    
    init(with state: State, matching symbol: Symbol) {
        guard case .standard = state.category else { fatalError() }
        
        let (initial, terminal) = (State(category: .initial), State(category: .terminal))
        initial.add(Transition(to: state))
        state.add(Transition(to: terminal, matching: symbol))
        self.states = (initial, terminal)
    }
    
    init(from expression: ExpressionConvertible) {
        let states = (State(category: .initial), State(category: .terminal))
        expression.insert(between: states)
        self.states = states
    }
    
    func concatenate(with other: NFA) {
        self.states.terminal.add(Transition(to: other.states.initial))
        self.states.terminal = other.states.terminal
    }
    
    func union(with other: NFA) {
        let (initial, terminal) = (State(category: .initial), State(category: .terminal))
        initial.add(Transition(to: self.states.initial))
        initial.add(Transition(to: other.states.initial))
        self.states.terminal.add(Transition(to: terminal))
        other.states.terminal.add(Transition(to: terminal))
        self.states = (initial, terminal)
    }
    
    func matches(_ input: String) -> Bool {
        var queue: [State] = [self.states.initial]
        
        for character in input {
            var remaining = queue.count
            
            while remaining != 0 {
                let state = queue.removeFirst()
                remaining -= 1
                
                queue.append(contentsOf: state.destinations(from: character))
            }
        }
        
        return queue.lazy.flatMap { $0.closure }.contains { state in state === self.states.terminal }
    }
}
