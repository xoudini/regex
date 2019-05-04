//
//  Symbol.swift
//

import Foundation

/// Symbol type describing what input to match.
///
indirect enum Symbol {
    case any, set(HashSet<Character>), single(Character), not(Symbol)
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
        case .not(let symbol):
            return !symbol.matches(input)
        }
    }
}
