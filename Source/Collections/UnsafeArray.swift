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
    
    /// A boolean value indicating whether the array is empty.
    var isEmpty: Bool {
        return self.count == 0
    }
    
    /// The first element of the array.
    var first: Element? {
        guard self.isEmpty else { return nil }
        return self[self.startIndex]
    }
    
    /// The last element of the array.
    var last: Element? {
        guard self.isEmpty else { return nil }
        return self[self.endIndex - 1]
    }
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - capacity:   An integer value to use as the capacity for the initial allocation.
    ///
    /// - note:         If not using the default value for the capacity, at least
    ///                 consider using a power of 2.
    ///
    init(with capacity: Int = 8) {
        self.capacity = Swift.max(1, capacity)
        self.count = 0
        self.pointer = UnsafeMutablePointer<Element>.allocate(capacity: self.capacity)
    }
    
    /// Copy initializer.
    ///
    init(copying other: UnsafeArray<Element>) {
        self.pointer = UnsafeMutablePointer<Element>.allocate(capacity: other.capacity)
        self.pointer.initialize(from: other.pointer, count: other.count)
        self.count = other.count
        self.capacity = other.capacity
    }
    
    /// Convenience initializer copying elements from a Foundation `Array`.
    ///
    convenience init(_ array: Array<Element>) {
        self.init()
        for element in array {
            self.append(element)
        }
    }
    
    /// Initializer required by `ExpressibleByArrayLiteral`.
    ///
    required convenience init(arrayLiteral elements: ArrayLiteralElement...) {
        self.init(elements)
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
    
    /// Realigns the element at `startIndex` to the pointer at the base address, and
    /// aligns the remaining elements up to `endIndex` linearly.
    ///
    /// - parameters:
    ///   - startIndex: The index to align with the internal starting index.
    ///   - endIndex:   The index after the last element to include in the operation.
    ///
    /// - warning:      Both indices must be initialized for the instance, and
    ///                 `endIndex` must be greater than `startIndex`.
    ///
    func align(startIndex: Index, endIndex: Index) {
        var index = self.startIndex
        let count = endIndex - startIndex
        while index < count {
            self.pointer.advanced(by: index).assign(self[startIndex + index])
            index += 1
        }
        self.pointer.advanced(by: count).deinitialize(count: self.endIndex - count)
        self.count = count
    }
    
    /// Creates an identical copy of the instance.
    ///
    /// - returns:      A copy of the instance.
    ///
    func copy() -> UnsafeArray<Element> {
        return UnsafeArray(copying: self)
    }
    
    /// Creates a copy of a slice of the instance between the given indices.
    ///
    /// - parameters:
    ///   - startIndex: The index to start the copy from.
    ///   - endIndex:   The index after the last element to include in the copy.
    ///
    /// - returns:      A partial copy of the instance.
    /// - warning:      Both indices must be initialized for the instance, and
    ///                 `endIndex` must be greater than `startIndex`.
    ///
    func copy(from startIndex: Index, to endIndex: Index) -> UnsafeArray<Element> {
        let capacity = Swift.max(8, endIndex - startIndex)
        return (startIndex..<endIndex).reduce(into: UnsafeArray<Element>(with: capacity)) { (array, index) in
            array.append(self[index])
        }
    }
    
    /// Prevents memory leaks by deallocating the pointer prior to ARC releasing this instance.
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


// MARK: - ExpressibleByArrayLiteral

extension UnsafeArray: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
}
