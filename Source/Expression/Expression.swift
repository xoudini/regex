//
//  Expression.swift
//

import Foundation


/// Protocol for expression type conformance.
///
protocol ExpressionConvertible: NFAConvertible, CustomStringConvertible {
}


/// Protocol for expressions directly convertible into `Symbol` instances.
///
protocol SymbolConvertible: NFAConvertible {
    var symbol: Symbol { get }
}

extension SymbolConvertible {
    
    /// Default implementation for types conforming to `SymbolConvertible`.
    ///
    /// - parameters:
    ///   - states:     A tuple of `State` instances.
    ///
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        let state = State()
        initial.add(Transition(to: state, matching: self.symbol))
        state.add(Transition(to: terminal))
    }
}


/// Protocol for expression types containing convertible expressions.
///
protocol NFAConvertible {
    
    /// Method for inserting an `NFA` between two states.
    ///
    /// - parameters:
    ///   - states:     A tuple of `State` instances.
    ///
    func insert(between states: (State, State))
}


/// Work in progress -- currently only responsible for generating the parse tree.
///
struct Expression {
    
    static func consume(provider: Provider, with context: ParserContext) throws -> ExpressionConvertible {
        let stack: Stack<ExpressionConvertible> = Stack()
        
        loop: while let character = provider.next() {
            
            switch (context.state, character) {
            case (.set, "]"):
                context.exit()
                
            case (.set, _):
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
                context.enter(state: .group)
                let expression = try Expression.consume(provider: provider, with: context)
                context.exit()
                stack.push(expression)
                
            case (_, "["):
                context.enter(state: .set)
                stack.push(ChoiceExpression())
                
            case (_, "."):
                stack.push(AnyCharacterExpression())
                
            case (_, "+"):
                guard let expression = stack.pop() else { throw ParsingError.invalidSymbol }
                let concat = ConcatenatedExpression(with: [expression, RepeatedExpression(expression)])
                stack.push(concat)
                
            case (_, "*"):
                guard let expression = stack.pop() else { throw ParsingError.invalidSymbol }
                stack.push(RepeatedExpression(expression))
                
            case (_, "?"):
                guard let expression = stack.pop() else { throw ParsingError.invalidSymbol }
                stack.push(OptionalExpression(expression))
                
            case (_, "|"):
                guard !stack.isEmpty else { throw ParsingError.invalidSymbol }
                
                context.enter(state: .union)
                let expression = try Expression.consume(provider: provider, with: context)
                context.exit()
                
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
