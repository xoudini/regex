//
//  ArgumentParser.swift
//

import Foundation

fileprivate typealias Provider = () -> String?

struct ArgumentParser {
    var options: [Option]
    
    init(_ options: Option...) {
        self.options = options
    }
    
    func parse(arguments: [String]) {
        var iterator = arguments.makeIterator()
        
        while let argument = iterator.next() {
            if let option = self.options.get(argument) {
                let closure: () -> String? = { iterator.next() }
                option.handler(closure)
            }
        }
    }
}
