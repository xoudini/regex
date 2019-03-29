//
//  State.swift
//

import Foundation

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
