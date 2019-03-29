//
//  Symbol.swift
//

import Foundation

/// Symbol type describing what input to match.
///
enum Symbol {
    case any, set(Set<Character>), single(Character)
}

extension Symbol {
    
    /// Basic matching function.
    ///
    /// - parameters:
    ///   - input:      The input to match against.
    ///
    /// - returns:      A boolean value depending on whether the input matches.
    ///
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
