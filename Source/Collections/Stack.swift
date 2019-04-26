//
//  Stack.swift
//

import Foundation

/// A simple generic stack implementation.
///
class Stack<Element> {
    
    /// The internal representation of the stack.
    private let representation: UnsafeArray<Element>
    
    /// A copy of the elements in this stack.
    var elements: UnsafeArray<Element> {
        self.representation.align(startIndex: self.startIndex, endIndex: self.endIndex)
        return self.representation.copy()
    }
    
    /// The current count of elements in the stack.
    private(set) var count: Int
    
    /// A boolean value indicating whether the stack is empty.
    var isEmpty: Bool {
        return self.count == 0
    }
    
    /// The current top element in the stack.
    ///
    /// - note:     `nil` if the stack is empty.
    ///
    var peek: Element? {
        guard !self.isEmpty else { return nil }
        return self.representation[self.endIndex - 1]
    }
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - array:  An `Array<Element>` to copy.
    ///
    init(from array: Array<Element> = []) {
        self.representation = UnsafeArray(array)
        self.count = self.representation.count
    }
    
    /// Initializer required by `ExpressibleByArrayLiteral`.
    ///
    required convenience init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(from: elements)
    }
    
    /// Pushes an element onto the stack.
    ///
    /// - parameters:
    ///   - element:    The element to push onto stack.
    ///
    func push(_ element: Element) {
        defer { self.count += 1 }
        self.representation.insert(element, at: self.endIndex)
    }
    
    /// Pops the top element off the stack.
    ///
    /// - returns:  The top element from the stack, or `nil`
    ///             if the stack is empty.
    ///
    @discardableResult
    func pop() -> Element? {
        guard !self.isEmpty else { return nil }
        self.count -= 1
        return self.representation[self.endIndex]
    }
    
    /// Resets the stack into an empty state.
    ///
    func clear() {
        self.count = 0
    }
}


// MARK: - Collection

extension Stack: Collection {
    typealias Index = UnsafeArray<Element>.Index
    
    var startIndex: Index {
        return 0
    }
    
    var endIndex: Index {
        return self.count
    }
    
    func index(after i: Index) -> Index {
        return i + 1
    }
    
    subscript (position: Index) -> Element {
        get {
            return self.representation[position]
        }
    }
}


// MARK: - Sequence

extension Stack: Sequence {
    
    struct Iterator: IteratorProtocol {
        private var stack: Stack<Element>
        private var index: Stack.Index
        
        init(_ stack: Stack<Element>) {
            self.stack = stack
            self.index = stack.startIndex
        }
        
        mutating func next() -> Element? {
            guard self.index < self.stack.endIndex else { return nil }
            defer { self.index += 1 }
            return self.stack[self.index]
        }
    }
    
    func makeIterator() -> Stack<Element>.Iterator {
        return Iterator(self)
    }
}


// MARK: - ExpressibleByArrayLiteral

extension Stack: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
}


// MARK: - CustomStringConvertible

extension Stack: CustomStringConvertible {

    var description: String {
        let inner = self.representation
            .map{ String(describing: $0) }
            .joined(separator: ", ")
        return "[\(inner)]"
    }
}
