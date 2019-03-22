//
//  Parser.swift
//

import Foundation

class Parser {
    var regex: String
    let context: ParserContext
    
    lazy var result: ExpressionConvertible? = {
        return try? self.parse()
    }()
    
    init(with regex: String) {
        self.regex = regex
        self.context = ParserContext()
    }
    
    func parse() throws -> ExpressionConvertible {
        var iterator = self.regex.makeIterator()
        let expression = try Expression.consume(provider: { iterator.next() }, with: self.context)
        guard case .none = self.context.state else { throw ParsingError.invalidEndState }
        return expression
    }
}

enum State {
    case none
    case escaped
    case group
    case set
}

enum ParsingError: Error {
    case emptyExpression
    case invalidSymbol
    case invalidEndState
    case unterminatedState
}

class ParserContext {
    let states: Stack<State>
    
    var state: State {
        return self.states.peek ?? State.none
    }
    
    init() {
        self.states = Stack()
    }
    
    func enter(state: State) {
        self.states.push(state)
    }
    
    func exit() {
        self.states.pop()
    }
}
