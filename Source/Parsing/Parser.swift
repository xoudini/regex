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
        let provider = Provider(self.regex)
        let expression = try Expression.consume(provider: provider, with: self.context)
        guard case .none = self.context.state else { throw ParsingError.invalidEndState }
        return expression
    }
}
