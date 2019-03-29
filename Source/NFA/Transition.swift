//
//  Transition.swift
//

import Foundation

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
