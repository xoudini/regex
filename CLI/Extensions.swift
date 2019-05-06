//
//  Extensions.swift
//

import Foundation

#if os(Linux)
// Rough implementation for missing method in Linux
extension String {
    func enumerateLines(_ closure: (String, inout Bool) -> Void) {
        var buffer = String(), iterator = self.makeIterator(), stop = false
        
        var previous: Character?
        
        while let next = iterator.next() {
            switch (previous, next) {
            case ("\r", "\n"):
                fallthrough
            case (_, "\n"):
                closure(buffer, &stop)
                guard !stop else { return }
                buffer = String()
            case (_, "\r"):
                previous = next
            default:
                previous = next
                buffer.append(next)
            }
        }
        
        guard !buffer.isEmpty else { return }
        closure(buffer, &stop)
    }
}
#endif
