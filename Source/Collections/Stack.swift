//
//  Stack.swift
//

import Foundation

/// A simple generic stack implementation.
///
class Stack<Element> {
    
    /// The internal representation of the stack.
    ///
    /// - todo:     Replace with custom array type.
    ///
    private(set) var representation: [Element]
    
    /// The current count of elements in the stack.
    var count: Int {
        return self.representation.count
    }
    
    /// The current top element in the stack.
    ///
    /// - note:     `nil` if the stack is empty.
    ///
    var peek: Element? {
        return self.representation.last
    }
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - array:  An `Array<Element>` to copy.
    ///
    init(from array: [Element] = []) {
        self.representation = array
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
        self.representation.append(element)
    }
    
    /// Pops the top element off the stack.
    ///
    /// - returns:  The top element from the stack, or `nil`
    ///             if the stack is empty.
    ///
    @discardableResult
    func pop() -> Element? {
        return self.representation.popLast()
    }
    
    /// Resets the stack into an empty state.
    ///
    func clear() {
        self.representation.removeAll()
    }
}


// MARK: - Collection

extension Stack: Collection {
    typealias Index = Array<Element>.Index
    
    var startIndex: Index {
        return self.representation.startIndex
    }
    
    var endIndex: Index {
        return self.representation.endIndex
    }
    
    func index(after i: Index) -> Index {
        return self.representation.index(after: i)
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
