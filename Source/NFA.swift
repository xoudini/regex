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

enum Symbol {
    case any, set(Set<Character>), single(Character)
}

extension Symbol {
    
    func matches(_ input: Character) -> Bool {
        switch self {
        case .any:
            return true
        case .set(let characterSet):
            return characterSet.contains(input)
        case .single(let character):
            return input == character
        }
    }
}


class State {
    
    enum Category {
        case initial, terminal, standard
    }
    
    let category: Category
    var transitions: [Transition]
    
    /// The epsilon-closure of the state.
    ///
    /// - warning:  The closure is evaluated lazily, once.
    ///
    lazy var closure: [State] = {
        var result: [State] = [self]
        var stack: Stack<State> = [self]
        
        while !stack.isEmpty {
            guard let next = stack.pop() else { continue }
            
            for transition in next.transitions {
                guard case .epsilon = transition.category else { continue }
                result.append(transition.destination)
                stack.push(transition.destination)
            }
        }
        
        return result
    }()
    
    init(category: Category = .standard) {
        self.category = category
        self.transitions = []
    }
    
    func add(_ transition: Transition) {
        self.transitions.append(transition)
    }
    
    func destinations(from input: Character) -> [State] {
        return self.closure.reduce(into: [State]()) { (result, state) in
            for transition in state.transitions {
                guard transition.accepts(input) else { continue }
                result.append(transition.destination)
            }
        }
    }
}

struct Transition {
    
    enum Category {
        case epsilon, standard(Symbol)
    }
    
    let category: Category
    let destination: State
    
    init(to destination: State, with category: Category) {
        self.destination = destination
        self.category = category
    }
    
    init(to destination: State) {
        self.init(to: destination, with: .epsilon)
    }
    
    init(to destination: State, matching symbol: Symbol) {
        self.init(to: destination, with: .standard(symbol))
    }
    
    func accepts(_ input: Character) -> Bool {
        guard case .standard(let symbol) = self.category else { return false }
        return symbol.matches(input)
    }
}
