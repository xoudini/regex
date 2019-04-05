//
//  UnsafeMutablePointer.swift
//

import Foundation

extension UnsafeMutablePointer {
    
    /// Allocates a block of memory for this pointer, according to the memory layout
    /// of the pointee, and moves over the given count of instances into initialized
    /// memory from the source pointer.
    ///
    /// - parameters:
    ///   - capacity:   The desired capacity after reallocation.
    ///   - count:      The number of pointee instances to move.
    ///
    /// - warning:      The memory referenced by each pointer from the address of
    ///                 this pointer up to `count` instances afterwards must be
    ///                 in initialized state.
    ///
    mutating func reallocate(to capacity: Int, copying count: Int) {
        let pointer = UnsafeMutablePointer<Pointee>.allocate(capacity: capacity)
        pointer.moveInitialize(from: self, count: count)
        self.deallocate()
        self = pointer
    }
    
    /// Convenience method for assigning a single pointee at this pointer.
    ///
    /// - parameters:
    ///   - pointee:    The pointee instance to assign to this pointer.
    ///
    func assign(_ pointee: Pointee) {
        self.assign(repeating: pointee, count: 1)
    }
}

