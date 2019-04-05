//
//  UnsafeArray.swift
//

import Foundation

/// A generic array implementation using pointers. The array is dynamically resized
/// when necessary, doubling the capacity for each reallocation.
///
/// - warning:  No guarantees are provided -- handle with care.
///
class UnsafeArray<Element> {
    
    /// A pointer to the start of the allocated memory block.
    ///
    /// - todo:     Consider private-only access -- this shouldn't be modified anyways.
    ///
    private(set) var pointer: UnsafeMutablePointer<Element>
    
    /// The current count of elements in the array.
    private(set) var count: Int
    
    /// The currently reserved capacity for the array.
    private(set) var capacity: Int
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - capacity:   An integer value to use as the capacity for the initial allocation.
    ///
    /// - note:         If not using the default value for the capacity, at least
    ///                 consider using a power of 2.
    ///
    init(with capacity: Int = 8) {
        self.pointer = UnsafeMutablePointer<Element>.allocate(capacity: capacity)
        self.count = 0
        self.capacity = capacity
    }
    
    /// Inserts an element at the given index.
    ///
    /// - parameters:
    ///   - element:    The elemnt to insert.
    ///   - index:      The index at which the element should be inserted.
    ///
    /// - warning:      Insertion outside of the bounds invokes undefined behaviour.
    ///
    func insert(_ element: Element, at index: Index) {
        switch index {
        case self.capacity:
            self.capacity *= 2
            self.pointer.reallocate(to: self.capacity, copying: self.count)
            fallthrough
        case self.endIndex:
            defer { self.count += 1 }
            self.pointer.advanced(by: index).initialize(to: element)
        default:
            self.pointer.advanced(by: index).assign(element)
        }
    }
    
    /// Appends an element to the end of the array.
    ///
    /// - parameters:
    ///   - element:    The element to append.
    ///
    func append(_ element: Element) {
        self.insert(element, at: self.endIndex)
    }
    
    /// Prevents memory leaks by deallocating the pointer prior ARC cleaning up this instance.
    ///
    deinit {
        self.pointer.deallocate()
    }
}


// MARK: - RandomAccessCollection

extension UnsafeArray: RandomAccessCollection {
    typealias Index = Int
    
    var startIndex: Index {
        return 0
    }
    
    var endIndex: Index {
        return self.count
    }
    
    /// Subscript operator implementation.
    ///
    /// - note:     Read-only.
    /// - warning:  Access outside of the bounds invokes undefined behaviour.
    ///
    subscript (position: Index) -> Element {
        get {
            return self.pointer.advanced(by: position).pointee
        }
    }
}
