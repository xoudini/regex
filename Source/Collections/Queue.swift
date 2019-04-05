//
//  Queue.swift
//

import Foundation

/// A simple generic queue implementation.
///
class Queue<Element> {
    
    private(set) var representation: [Element]
    
    var head: Index, tail: Index
    
    var count: Int {
        return self.tail - self.head
    }
    
    var isEmpty: Bool {
        return self.count == 0
    }
    
    init(from array: [Element] = []) {
        self.representation = array
        self.head = 0
        self.tail = array.count
    }
    
    required convenience init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(from: elements)
    }
    
    func enqueue(_ element: Element) {
        self.representation.append(element)
        self.tail += 1
    }
    
    func enqueue(contentsOf array: [Element]) {
        self.representation.append(contentsOf: array)
        self.tail += array.count
    }
    
    func dequeue() -> Element? {
        guard !self.isEmpty else { return nil }
        defer { self.head += 1 }
        return self.representation[self.head]
    }
}


// MARK: - Collection

extension Queue: Collection {
    typealias Index = Array<Element>.Index
    
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
            return self.representation[self.head + position]
        }
    }
}


// MARK: - Sequence

extension Queue: Sequence {
    
    struct Iterator: IteratorProtocol {
        private var queue: Queue<Element>
        private var index: Queue.Index
        
        init(_ queue: Queue<Element>) {
            self.queue = queue
            self.index = queue.startIndex
        }
        
        mutating func next() -> Element? {
            guard self.index < self.queue.endIndex else { return nil }
            defer { self.index += 1 }
            return self.queue[self.index]
        }
    }
    
    func makeIterator() -> Queue<Element>.Iterator {
        return Iterator(self)
    }
}


// MARK: - ExpressibleByArrayLiteral

extension Queue: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
}
