//
//  UnsafeArray.swift
//

import Foundation

class UnsafeArray<Element> {
    private(set) var pointer: UnsafeMutablePointer<Element>
    private(set) var count: Int
    private(set) var capacity: Int
    
    init(with capacity: Int = 8) {
        self.pointer = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
        self.count = 0
        self.capacity = capacity
    }
    
    // TODO: Move to extension of pointer
    private func reallocate() {
        let pointer = UnsafeMutablePointer<Element>.allocate(capacity: self.capacity)
        pointer.moveInitialize(from: self.pointer, count: self.count)
        self.pointer.deallocate()
        self.pointer = pointer
    }
    
    func insert(_ element: Element, at index: Index) {
        // TODO: Check bounds
        
        switch index {
        case self.capacity:
            self.capacity *= 2
            self.reallocate()
            fallthrough
        case self.endIndex:
            defer { self.count += 1 }
            self.pointer.advanced(by: index).initialize(to: element)
        default:
            self.pointer.advanced(by: index).assign(repeating: element, count: 1)
        }
    }
    
    func append(_ element: Element) {
        self.insert(element, at: self.endIndex)
    }
    
    deinit {
        self.pointer.deallocate()
    }
}

extension UnsafeArray: RandomAccessCollection {
    typealias Index = Int
    
    var startIndex: Int {
        return 0
    }
    
    var endIndex: Int {
        return self.count
    }
    
    subscript (index: Index) -> Element {
        get {
            // TODO: Check bounds
            return self.pointer.advanced(by: index).pointee
        }
    }
}
