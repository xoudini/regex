//
//  Parser.swift
//

import Foundation

/// The main parser class.
///
public class Parser {
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
    public init(with regex: String) {
        self.regex = regex
        self.context = ParserContext()
    }
    
    /// Tries to parse the given regular expression string.
    ///
    /// - throws:   A `ParsingError` in case something goes wrong.
    /// - returns:  The root of the resulting parse tree.
    ///
    public func parse() throws -> Expression {
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
            
            switch (self.context.state, character) {
            
            // TODO: Decide on specific escape characters to handle.
            case (.escaped, _):
                self.context.exit()
                
                if case .choice = self.context.state {
                    var expression = stack.pop() as! ChoiceExpression
                    expression.characterSet.insert(character)
                    stack.push(expression)
                } else {
                    // Handle possible character class
                    let expression: Expression = {
                        guard let characterClass = CharacterClass(rawValue: character) else {
                            return CharacterExpression(character)
                        }
                        let set = HashSet(from: characterClass.expanded)
                        let expression = ChoiceExpression(with: set)
                        return characterClass.negated ? NegatedExpression(expression) : expression
                    }()
                    stack.push(expression)
                }
                
            case (_, "\\"):
                self.context.enter(state: .escaped)
                
            case (.choice, "]"):
                self.context.exit()
                
                if case .negation = self.context.state {
                    self.context.exit()
                    let expression = stack.pop() as! ChoiceExpression
                    stack.push(NegatedExpression(expression))
                }
            
            case (.choice, "^"):
                // Move choice context to top
                self.context.exit()
                self.context.enter(state: .negation)
                self.context.enter(state: .choice)
                
                // Make sure this is at the beginning
                guard
                    let expression = stack.peek as? ChoiceExpression,
                    expression.characterSet.isEmpty
                else {
                    throw ParsingError.invalidSymbol
                }
                
            case (.choice, _):
                var expression = stack.pop() as! ChoiceExpression
                expression.characterSet.insert(character)
                stack.push(expression)
            
            case (.negation, _):
                let expression = CharacterExpression(character)
                stack.push(NegatedExpression(expression))
                
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
                    return UnionExpression(ConcatenatedExpression(with: stack.elements), expression)
                }()
                
                stack.push(union)
            
            case (_, "^"):
                self.context.enter(state: .negation)
                
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
            return ConcatenatedExpression(with: stack.elements)
        }
    }
}
