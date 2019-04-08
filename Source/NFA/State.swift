//
//  State.swift
//

import Foundation

/// A state type used in finite automata.
///
public class State {
    
    /// An enumerator describing the type of a state.
    ///
    enum Category {
        case initial, terminal, standard
    }
    
    /// The type of this state.
    let category: Category
    
    /// The transitions of this state.
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
    
    /// Designated initializer.
    ///
    init(category: Category = .standard) {
        self.category = category
        self.transitions = []
    }
    
    /// Method for adding transitions.
    ///
    /// - parameters:
    ///   - transition: The `Transition` to add.
    ///
    func add(_ transition: Transition) {
        self.transitions.append(transition)
    }
    
    /// Method reducing the epsilon-closure of the instance into a set of new
    /// states, depending on whether the reduced states accept the input.
    ///
    /// - parameters:
    ///   - input:      A `Character` to match against.
    ///
    /// - returns:      A set of `State` instances resulting from a match.
    /// - note:         May be expensive if `closure` hasn't yet been accessed
    ///                 on this instance.
    ///
    func destinations(from input: Character) -> [State] {
        return self.closure.reduce(into: [State]()) { (result, state) in
            for transition in state.transitions {
                guard transition.accepts(input) else { continue }
                result.append(transition.destination)
            }
        }
    }
}
