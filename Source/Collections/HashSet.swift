//
//  HashSet.swift
//

import Foundation


fileprivate indirect enum Node<Element> {
    case empty
    case bucket(value: Element, next: Node)
}

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


public class HashSet<Element: Hashable & Comparable> {
    private let buffer: UnsafeArray<Node<Element>>
    public let bufferSize: Int
    public private(set) var count: Int
    
    init(with bufferSize: Int = 512) {
        self.buffer = UnsafeArray(with: bufferSize, defaultValue: .empty)
        self.bufferSize = bufferSize
        self.count = 0
    }
    
    convenience init<S>(from sequence: S) where S: Sequence, S.Element == Element {
        self.init()
        for element in sequence {
            self.insert(element)
        }
    }
    
    func insert(_ element: Element) {
        let index = element.hashValue & (self.bufferSize - 1)
        let root = self.buffer[index]
        guard root.first(where: { $0 == element }) == nil else { return }
        self.buffer.insert(.bucket(value: element, next: root), at: index)
        self.count += 1
    }
    
    func contains(_ element: Element) -> Bool {
        let index = element.hashValue & (self.bufferSize - 1)
        return self.buffer[index].first { $0 == element } != nil
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
