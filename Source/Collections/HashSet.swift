//
//  HashSet.swift
//

import Foundation

/// A generic recursive node type used as a container for a value.
///
fileprivate indirect enum Node<Element> {
    /// Signifies that the node is empty.
    case empty
    
    /// A container for an `Element`, and a link to the next `Node`.
    case bucket(value: Element, next: Node)
}


/// A minimal generic hash set implementation.
///
/// - note:     Accepts only types conforming to `Hashable` and `Comparable`.
///
public class HashSet<Element: Hashable & Comparable> {
    
    /// The internal buffer.
    private let buffer: UnsafeArray<Node<Element>>
    
    /// The size of the buffer.
    ///
    /// - warning:      This should be a power of two.
    ///
    public let bufferSize: Int
    
    /// A bitmask for constraining access into the buffer.
    private var bufferMask: Int {
        return self.bufferSize - 1
    }
    
    /// The current count of elements in the set.
    public private(set) var count: Int
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - bufferSize: The size of the buffer.
    ///
    init(with bufferSize: Int = 512) {
        self.buffer = UnsafeArray(with: bufferSize, defaultValue: .empty)
        self.bufferSize = bufferSize
        self.count = 0
    }
    
    /// Initializes the set from a type conforming to `Sequence`.
    ///
    /// - parameters:
    ///   - sequence:   The sequence to initialize from.
    ///
    convenience init<S>(from sequence: S) where S: Sequence, S.Element == Element {
        self.init()
        for element in sequence {
            self.insert(element)
        }
    }
    
    /// Inserts an element into the set. If the element already exists in
    /// the set, nothing is done.
    ///
    /// - parameters:
    ///   - element:    The element to insert.
    ///
    func insert(_ element: Element) {
        let index = element.hashValue & self.bufferMask
        guard !self.contains(element) else { return }
        self.buffer.insert(.bucket(value: element, next: self.buffer[index]), at: index)
        self.count += 1
    }
    
    /// A boolean check for whether a given element exists in the set.
    ///
    /// - parameters:
    ///   - element:    The element to search for.
    ///
    /// - returns:      A `Bool` signifying whether the element was found.
    ///
    func contains(_ element: Element) -> Bool {
        let index = element.hashValue & self.bufferMask
        return self.buffer[index].first { $0 == element } != nil
    }
}


// MARK: - Extensions

extension Node: Sequence {
    
    struct Iterator: IteratorProtocol {
        var node: Node<Element>
        
        init(_ node: Node<Element>) {
            self.node = node
        }
        
        mutating func next() -> Element? {
            guard case let .bucket(value, next) = self.node else { return nil }
            self.node = next
            return value
        }
    }
    
    func makeIterator() -> Node<Element>.Iterator {
        return Iterator(self)
    }
}


extension HashSet: Sequence {
    
    public struct Iterator: IteratorProtocol {
        private var set: HashSet<Element>
        private var index: Int, node: Node<Element>
        
        init(_ set: HashSet<Element>) {
            self.set = set
            self.index = 0
            self.node = .empty
        }
        
        public mutating func next() -> Element? {
            while self.index < self.set.bufferSize, case .empty = self.node {
                self.node = self.set.buffer[self.index]
                self.index += 1
            }
            guard case let .bucket(value, next) = self.node else { return nil }
            defer { self.node = next }
            return value
        }
    }
    
    public func makeIterator() -> HashSet<Element>.Iterator {
        return Iterator(self)
    }
}
