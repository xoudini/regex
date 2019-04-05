//
//  Provider.swift
//

import Foundation

class Provider {
    private var string: String
    private var currentIndex: String.Index
    
    init(_ string: String) {
        self.string = string
        self.currentIndex = string.startIndex
    }
    
    func next() -> Character? {
        guard self.currentIndex < self.string.endIndex else { return nil }
        defer { self.currentIndex = self.string.index(after: self.currentIndex) }
        return self.string[self.currentIndex]
    }
    
    func stepBack() {
        self.currentIndex = self.string.index(before: self.currentIndex)
    }
}
