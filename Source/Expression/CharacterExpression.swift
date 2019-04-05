//
//  CharacterExpression.swift
//

import Foundation

/// An expression matching some specific literal character.
///
struct CharacterExpression: ExpressionConvertible {
    let character: Character
    
    init(_ character: Character) {
        self.character = character
    }
}

extension CharacterExpression: SymbolConvertible {
    
    var symbol: Symbol {
        return .single(self.character)
    }
}

extension CharacterExpression: CustomStringConvertible {
    
    var description: String {
        return self.character.description
    }
}
