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
    lazy var result: Expression? = {
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
    func parse() throws -> Expression {
        let provider = Provider(self.regex)
        let expression = try self.consume(provider)
        guard case .none = self.context.state else { throw ParsingError.invalidEndState }
        return expression
    }
}

extension Parser {
    
    /// Method consuming the characters from the given `Provider`, constructing a
    /// parse tree in the process.
    ///
    /// - parameters:
    ///   - provider:   The `Provider` to consume.
    ///
    /// - throws:       A `ParsingError` if something goes wrong.
    /// - returns:      The root `Expression` of the constructed parse tree.
    ///
    fileprivate func consume(_ provider: Provider) throws -> Expression {
        let stack: Stack<Expression> = Stack()
        
        loop: while let character = provider.next() {
            
            switch (context.state, character) {
            case (.choice, "]"):
                self.context.exit()
                
            case (.choice, _):
                var expression = stack.pop() as! ChoiceExpression
                expression.characterSet.insert(character)
                stack.push(expression)
                
            case (.group, ")"):
                break loop
                
            case (.union, ")"):
                fallthrough
                
            case (.union, "|"):
                provider.stepBack()
                break loop
                
            case (_, "("):
                self.context.enter(state: .group)
                let expression = try self.consume(provider)
                self.context.exit()
                stack.push(expression)
                
            case (_, "["):
                self.context.enter(state: .choice)
                stack.push(ChoiceExpression())
                
            case (_, "."):
                stack.push(AnyCharacterExpression())
                
            case (_, "+"):
                guard let expression = stack.pop() else { throw ParsingError.invalidSymbol }
                let concat = ConcatenatedExpression(expression, RepeatedExpression(expression))
                stack.push(concat)
                
            case (_, "*"):
                guard let expression = stack.pop() else { throw ParsingError.invalidSymbol }
                stack.push(RepeatedExpression(expression))
                
            case (_, "?"):
                guard let expression = stack.pop() else { throw ParsingError.invalidSymbol }
                stack.push(OptionalExpression(expression))
                
            case (_, "|"):
                guard !stack.isEmpty else { throw ParsingError.invalidSymbol }
                
                self.context.enter(state: .union)
                let expression = try self.consume(provider)
                self.context.exit()
                
                let union: UnionExpression =  {
                    if stack.count == 1, let previous = stack.pop() {
                        return UnionExpression(previous, expression)
                    }
                    defer { stack.clear() }
                    return UnionExpression(ConcatenatedExpression(with: stack.representation), expression)
                }()
                
                stack.push(union)
                
            default:
                stack.push(CharacterExpression(character))
            }
        }
        
        switch stack.count {
        case 0:
            throw ParsingError.emptyExpression
        case 1:
            return stack.first!
        default:
            return ConcatenatedExpression(with: stack.representation)
        }
    }
}
