//
//  Queue.swift
//

import Foundation

/// A simple generic queue implementation.
///
class Queue<Element> {
    
    /// The internal representation of the queue.
    ///
    /// - todo:     Replace with custom array type.
    ///
    private(set) var representation: UnsafeArray<Element>
    
    /// A bounding index for the queue.
    private var head: Index, tail: Index
    
    /// The current count of elements in the queue.
    var count: Int {
        return self.tail - self.head
    }
    
    /// A boolean value indicating whether the queue is empty.
    var isEmpty: Bool {
        return self.count == 0
    }
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - array:  An `Array<Element>` to copy.
    ///
    init(from array: [Element] = []) {
        self.representation = UnsafeArray(array)
        self.head = 0
        self.tail = self.representation.count
    }
    
    /// Initializer required by `ExpressibleByArrayLiteral`.
    ///
    required convenience init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(from: elements)
    }
    
    /// Enqueues an element to the tail of the queue.
    ///
    /// - parameters:
    ///   - element:    The element to enqueue.
    ///
    func enqueue(_ element: Element) {
        self.representation.append(element)
        self.tail += 1
    }
    
    /// Enqueues a collection to the tail of the queue.
    ///
    /// - parameters:
    ///   - array:      The elements to enqueue.
    ///
    func enqueue(contentsOf array: UnsafeArray<Element>) {
        self.representation.append(contentsOf: array)
        self.tail += array.count
    }
    
    /// Dequeues the element at the head from the queue.
    ///
    /// - returns:      The element at the head, or `nil` if the
    ///                 queue is empty.
    ///
    func dequeue() -> Element? {
        guard !self.isEmpty else { return nil }
        defer { self.head += 1 }
        return self.representation[self.head]
    }
}


// MARK: - Collection

extension Queue: Collection {
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
