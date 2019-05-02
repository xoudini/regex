//
//  ChoiceExpression.swift
//

import Foundation

/// An expression matching a character in a given set.
///
/// - note:     Represented by the `[...]` expression.
///
struct ChoiceExpression: Expression {
    var characterSet: HashSet<Character>
    
    init(with characterSet: HashSet<Character> = HashSet()) {
        self.characterSet = characterSet
    }
}

extension ChoiceExpression: SymbolConvertible {
    
    var symbol: Symbol {
        return .set(self.characterSet)
    }
}

extension ChoiceExpression: CustomStringConvertible {
    
    var description: String {
        let characters = self.characterSet.map{ $0.description }.sorted().joined(separator: ", ")
        return "Choice(\(characters))"
    }
}
