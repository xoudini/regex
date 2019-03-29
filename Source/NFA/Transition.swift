//
//  Transition.swift
//

import Foundation

/// Type describing the transition to a destination state.
///
struct Transition {
    
    /// An enumerator describing the type of a transition.
    ///
    enum Category {
        case epsilon, standard(Symbol)
    }
    
    /// The type if this transition.
    let category: Category
    
    /// The destination state for this transition.
    let destination: State
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - destination:    The `State` to transition to on accepted input.
    ///   - category:       The type of this transition.
    ///
    init(to destination: State, with category: Category = .epsilon) {
        self.destination = destination
        self.category = category
    }
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - destination:    The `State` to transition to on accepted input.
    ///   - symbol:         The `Symbol` this transition accepts.
    ///
    init(to destination: State, matching symbol: Symbol) {
        self.init(to: destination, with: .standard(symbol))
    }
    
    /// Method for checking whether the input is accepted.
    ///
    /// - parameters:
    ///   - input:          The input `Character` to check against.
    ///
    /// - returns:          A boolean value, depending on whether the input
    ///                     is accepted.
    ///
    /// - note:             Epsilon-transitions do not accept any input.
    ///
    func accepts(_ input: Character) -> Bool {
        guard case .standard(let symbol) = self.category else { return false }
        return symbol.matches(input)
    }
}
