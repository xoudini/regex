//
//  Provider.swift
//

import Foundation

/// A provider implementation in a consumer-provider model. Functions mostly like
/// an iterator, but has a step-back option which may be useful in some cases.
///
class Provider {
    
    /// The data source.
    private var string: String
    
    /// The current index
    private var currentIndex: String.Index
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - string:     The data source to provide characters from.
    ///
    init(_ string: String) {
        self.string = string
        self.currentIndex = string.startIndex
    }
    
    /// Provides the next character, if any are left.
    ///
    /// - returns:      The character at the next index, or nil.
    ///
    func next() -> Character? {
        guard self.currentIndex < self.string.endIndex else { return nil }
        defer { self.currentIndex = self.string.index(after: self.currentIndex) }
        return self.string[self.currentIndex]
    }
    
    /// Moves back one step, making the previously consumed character
    /// available for reconsumption.
    ///
    func stepBack() {
        self.currentIndex = self.string.index(before: self.currentIndex)
    }
}
