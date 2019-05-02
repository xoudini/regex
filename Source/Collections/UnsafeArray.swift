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
    /// - todo:     Consider private-only access -- this shouldn't be manipulated anyways.
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
        guard !self.isEmpty else { return nil }
        return self[self.startIndex]
    }
    
    /// The last element of the array.
    var last: Element? {
        guard !self.isEmpty else { return nil }
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
    
    /// Allocates a contiguous block of memory of the given capacity and initializes
    /// each slot with a copy of the given default value.
    ///
    /// - parameters:
    ///   - capacity:   An integer value to use as the capacity for the initial allocation.
    ///   - value:      The default value to populate the memory region with.
    ///
    /// - note:         If not using the default value for the capacity, at least
    ///                 consider using a power of 2.
    ///
    init(with capacity: Int = 8, defaultValue value: Element) {
        self.capacity = Swift.max(1, capacity)
        self.count = self.capacity
        self.pointer = UnsafeMutablePointer<Element>.allocate(capacity: self.capacity)
        self.pointer.initialize(repeating: value, count: self.count)
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
    ///   - element:    The element to insert.
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
    
    /// Appends the contents of the given array at the end of this array.
    ///
    /// - parameters:
    ///   - array:      The array to append.
    ///
    func append(contentsOf array: UnsafeArray<Element>) {
        for element in array {
            self.append(element)
        }
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
        
        // Release references to prevent memory leaks.
        self.pointer.advanced(by: count).deinitialize(count: self.endIndex - count)
        
        // Set count to amount of initialized instances.
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
        return (startIndex..<endIndex).reduce(into: UnsafeArray(with: capacity)) { (array, index) in
            array.append(self[index])
        }
    }
    
    /// Prevents memory leaks by releasing strong references in the buffer, and
    /// deallocating the pointer, prior to ARC releasing this instance.
    ///
    deinit {
        // Release references.
        self.pointer.deinitialize(count: self.count)
        
        // Release memory.
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


// MARK: - Convenience functions

extension UnsafeArray {
    
    /// Unpacks the array into a tuple containing the head and tail
    /// of the array, where the head refers to the first element and
    /// the tail to all remaining elements of the array.
    ///
    /// - returns:      An optional tuple containing the head
    ///                 and tail of the array.
    ///
    func unpack() -> (Element, UnsafeArray<Element>)? {
        guard let first = self.first else { return nil }
        return (first, self.copy(from: self.startIndex + 1, to: self.endIndex))
    }
    
    /// Returns a copy of this array, mapping each element by calling the given
    /// transform in the process.
    ///
    /// - parameters:
    ///   - transform:  A closure transforming an `Element` into type `T`.
    ///
    /// - returns:      The mapped array.
    ///
    func map<T>(_ transform: (Element) throws -> T) rethrows -> UnsafeArray<T> {
        return try self.reduce(into: UnsafeArray<T>(with: self.capacity)) { (array, element) in
            array.append(try transform(element))
        }
    }
    
    /// Returns a copy of this array, mapping each element by calling the given
    /// transform in the process, and excluding `nil` results.
    ///
    /// - parameters:
    ///   - transform:  A closure transforming an `Element` into type `T?`.
    ///
    /// - returns:      The mapped array excluding `nil` post-transform results.
    ///
    func compactMap<T>(_ transform: (Element) throws -> T?) rethrows -> UnsafeArray<T> {
        return try self.reduce(into: UnsafeArray<T>(with: self.capacity)) { (array, element) in
            guard let result = try transform(element) else { return }
            array.append(result)
        }
    }
    
    /// Flattens the sequences resulting from calling the given transform
    /// for each element of this array into a contiguous array.
    ///
    /// - parameters:
    ///   - transform:  A closure transforming an `Element` into a
    ///                 sequence containing elements of generic type.
    ///
    /// - returns:      The flattened array.
    ///
    func flatMap<S>(_ transform: (Element) throws -> S) rethrows -> UnsafeArray<S.Element> where S : Sequence {
        return try self.reduce(into: UnsafeArray<S.Element>()) { (array, element) in
            for element in try transform(element) {
                array.append(element)
            }
        }
    }
    
    /// Filters the elements of this array using the given predicate.
    ///
    /// - parameters:
    ///   - isIncluded: A predicate closure for `Element` instances.
    ///
    /// - returns:      The filtered array.
    ///
    func filter(_ isIncluded: (Element) throws -> Bool) rethrows -> UnsafeArray<Element> {
        return try self.reduce(into: UnsafeArray()) { (array, element) in
            guard try isIncluded(element) else { return }
            array.append(element)
        }
    }
    
    /// Returns the first element matching the given predicate.
    ///
    /// - parameters:
    ///   - predicate:  A predicate closure for `Element` instances.
    ///
    /// - returns:      The first element matching the predicate, or `nil`
    ///                 if no match was found.
    ///
    /// - note:         This is a short-circuiting operation.
    ///
    func first(where predicate: (Element) throws -> Bool) rethrows -> Element? {
        var iterator = self.makeIterator()
        while let next = iterator.next() {
            guard try !predicate(next) else { return next }
        }
        return nil
    }
    
    /// A boolean check for whether an element matching the given predicate
    /// exists in the array.
    ///
    /// - parameters:
    ///   - predicate:  A predicate closure for `Element` instances.
    ///
    /// - returns:      `true` if a match was found, `false` otherwise.
    ///
    /// - note:         This is a short-circuiting operation.
    ///
    func contains(where predicate: (Element) throws -> Bool) rethrows -> Bool {
        return try self.first(where: predicate) != nil
    }
    
    /// Reduces the elements of this array into the given initial result, by
    /// using the given reducer closure.
    ///
    /// - parameters:
    ///   - initialResult:      The initial result to reduce into.
    ///   - nextPartialResult:  The reducer closure.
    ///
    /// - returns:              The result after the reducer has been
    ///                         applied to each element of this array.
    ///
    func reduce<Result>(
        _ initialResult: Result,
        _ nextPartialResult: (Result, Element) throws -> Result
    ) rethrows -> Result {
        var result = initialResult, iterator = self.makeIterator()
        while let next = iterator.next() {
            result = try nextPartialResult(result, next)
        }
        return result
    }
    
    /// Reduces the elements of this array into the given initial result, by
    /// using the given reducer closure.
    ///
    /// - parameters:
    ///   - initialResult:              The initial result to reduce into.
    ///   - updateAccumulatingResult:   The reducer closure.
    ///
    /// - returns:                      The result after the reducer has been
    ///                                 applied to each element of this array.
    ///
    func reduce<Result>(
        into initialResult: Result,
        _ updateAccumulatingResult: (inout Result, Element) throws -> ()
    ) rethrows -> Result {
        var accumulator = initialResult, iterator = self.makeIterator()
        while let next = iterator.next() {
            try updateAccumulatingResult(&accumulator, next)
        }
        return accumulator
    }
}


// MARK: - ExpressibleByArrayLiteral

extension UnsafeArray: ExpressibleByArrayLiteral {
    typealias ArrayLiteralElement = Element
}
