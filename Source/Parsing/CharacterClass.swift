//
//  CharacterClass.swift
//

import Foundation

// MARK: - Constants

fileprivate let asciiUpper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
fileprivate let asciiLower = "abcdefghijklmnopqrstuvwxyz"
fileprivate let digits = "0123456789"
fileprivate let whitespace = " \t\n\r\u{0b}\u{0c}"
fileprivate let asciiLetters = asciiUpper + asciiLower
fileprivate let base62 = asciiLetters + digits
fileprivate let base63 = base62 + "_"


// MARK: -

/// An enumerator for some common character classes.
///
enum CharacterClass: Character {
    /// ASCII word characters
    case w = "w", W = "W"
    
    /// Digit characters
    case d = "d", D = "D"
    
    /// ASCII whitespace characters
    case s = "s", S = "S"
    
    /// Lower case ASCII characters
    case l = "l", L = "L"
    
    /// Upper case ASCII characters
    case u = "u", U = "U"
}

extension CharacterClass {
    
    /// The expanded form of the character class.
    ///
    var expanded: String {
        switch self {
        case .w, .W:
            return base63
        case .d, .D:
            return digits
        case .s, .S:
            return whitespace
        case .l, .L:
            return asciiLower
        case .u, .U:
            return asciiUpper
        }
    }
    
    /// Signifies whether the expanded form of the character
    /// class should be treated as normal, or as complement.
    ///
    var negated: Bool {
        switch self {
        case .w, .d, .s, .l, .u:
            return false
        case .W, .D, .S, .L, .U:
            return true
        }
    }
}
