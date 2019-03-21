//
//  Stack.swift
//

import Foundation

class Stack<Element> {
    private var representation: [Element]
    
    var count: Int {
        return self.representation.count
    }
    
    init(from array: [Element] = []) {
        self.representation = array
    }
    
    required init(arrayLiteral elements: ArrayLiteralElement...) {
        self.representation = elements
    }
    
    func push(_ element: Element) {
        self.representation.append(element)
    }
    
    func pop() -> Element? {
        return self.representation.popLast()
    }
}

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

extension Stack: Sequence {
    
    struct Iterator: IteratorProtocol {
        private var stack: Stack<Element>
        private var index: Stack.Index
        
        init(_ stack: Stack<Element>) {
            self.stack = stack
            self.index = 0
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

extension Stack: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
}
