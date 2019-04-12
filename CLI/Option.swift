//
//  Option.swift
//

import Foundation

typealias MatchHandler = (() -> String?) -> Void

class Option {
    let name: String
    let short: String
    let handler: MatchHandler
    
    init(name: String, short: String, handler: @escaping MatchHandler) {
        self.name = name
        self.short = short
        self.handler = handler
    }
}


// MARK: - Operators

infix operator =~

extension Option {
    
    static func =~ (lhs: Option, rhs: String) -> Bool {
        switch rhs.count {
        case 2:
            return "-\(lhs.short)" == rhs
        default:
            return "--\(lhs.name)" == rhs
        }
    }
}


// MARK: - Extensions

extension Array where Element == Option {
    
    func get(_ key: String) -> Option? {
        return self.first { option in
            option =~ key
        }
    }
}
