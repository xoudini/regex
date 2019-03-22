//
//  Parser.swift
//

import Foundation

/// The main parser class.
///
class Parser {
    /// The regular expression given to the initializer.
    let regex: String
    
    /// The context of this parser.
    let context: ParserContext
    
    /// Lazy accessor for the parsing result.
    ///
    /// - note:     Returns `nil` if parsing fails. Catch the exception thrown
    ///             from `parse()` for debugging purposes.
    ///
    lazy var result: ExpressionConvertible? = {
        return try? self.parse()
    }()
    
    /// Designated initializer.
    ///
    /// - parameters:
    ///   - regex:  The regular expression to parse.
    ///
    init(with regex: String) {
        self.regex = regex
        self.context = ParserContext()
    }
    
    /// Tries to parse the given regular expression string.
    ///
    /// - throws:   A `ParsingError` in case something goes wrong.
    /// - returns:  The root of the resulting parse tree.
    ///
    func parse() throws -> ExpressionConvertible {
        var iterator = self.regex.makeIterator()
        let provider: Provider = { iterator.next() }
        let expression = try Expression.consume(provider: provider, with: self.context)
        guard case .none = self.context.state else { throw ParsingError.invalidEndState }
        return expression
    }
}


/// A state type used for tracking the context during parsing.
///
enum State {
    case none
    case escaped
    case group
    case set
}


/// Error type for parsing related errors.
///
enum ParsingError: Error {
    case emptyExpression
    case invalidSymbol
    case invalidEndState
    case unterminatedState
}


/// Context type used during parsing.
///
class ParserContext {
    /// A stack to keep track of the states during parsing.
    private let states: Stack<State>
    
    /// The current state.
    var state: State {
        return self.states.peek ?? State.none
    }
    
    /// Designated initializer.
    ///
    init() {
        self.states = Stack()
    }
    
    /// Enters the given state.
    ///
    /// - parameters:
    ///   - state:  The `State` to enter.
    ///
    func enter(state: State) {
        self.states.push(state)
    }
    
    /// Exits the current state.
    ///
    /// - note:     No guarantees are made.
    /// - todo:     Perhaps this should require the state to be exited as
    ///             argument, and throw if the current state doesn't match.
    ///
    func exit() {
        self.states.pop()
    }
}
