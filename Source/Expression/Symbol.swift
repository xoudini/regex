//
//  Symbol.swift
//

import Foundation

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
