//
//  Expression.swift
//

import Foundation

typealias Provider = (() throws -> Character?)

protocol Consumer {
    static func consume(provider: @escaping Provider, with context: ParserContext) throws -> ExpressionConvertible
}

protocol ExpressionConvertible {
}

struct AnyCharacterExpression: ExpressionConvertible {
}

struct CharacterExpression: ExpressionConvertible {
    let character: Character
    
    init(_ character: Character) {
        self.character = character
    }
}

struct CharacterSetExpression: ExpressionConvertible {
    let characterSet: Set<Character>
    
    init(with characterSet: Set<Character>) {
        self.characterSet = characterSet
    }
    
    static func consume(provider: @escaping Provider, with context: ParserContext) throws -> ExpressionConvertible {
        context.enter(state: .set)
        
        var characterSet: Set<Character> = Set()
        
        while let character = try provider() {
            switch character {
            case "]":
                context.exit()
                guard !characterSet.isEmpty else { throw ParsingError.emptyExpression }
                return CharacterSetExpression(with: characterSet)
            default:
                characterSet.insert(character)
            }
        }
        
        throw ParsingError.unterminatedState
    }
}

struct OptionalExpression: ExpressionConvertible {
    let inner: ExpressionConvertible
    
    init(_ inner: ExpressionConvertible) {
        self.inner = inner
    }
}

struct RepeatingExpression: ExpressionConvertible {
    let inner: ExpressionConvertible
    
    init(_ inner: ExpressionConvertible) {
        self.inner = inner
    }
}

struct UnionExpression: ExpressionConvertible {
    let alternatives: [ExpressionConvertible]
    
    init(_ alternatives: ExpressionConvertible...) {
        self.alternatives = alternatives.reduce(into: []) { (accumulator, next) in
            if let expression = next as? UnionExpression {
                accumulator.append(contentsOf: expression.alternatives)
            } else {
                accumulator.append(next)
            }
        }
    }
}

struct GroupExpression: ExpressionConvertible {
    let children: [ExpressionConvertible]
    
    init(with children: [ExpressionConvertible]) {
        self.children = children
    }
    
    static func consume(provider: @escaping Provider, with context: ParserContext) throws -> ExpressionConvertible {
        context.enter(state: .group)
        
        let interceptor: Provider = {
            guard let character = try provider() else { throw ParsingError.unterminatedState }
            switch character {
            case ")":
                context.exit()
                return nil
            default:
                return character
            }
        }
        
        return try Expression.consume(provider: interceptor, with: context)
    }
}

struct Expression: ExpressionConvertible {
    
    static func consume(provider: @escaping Provider, with context: ParserContext) throws -> ExpressionConvertible {
        let stack: Stack<ExpressionConvertible> = Stack()
        
        while let character = try provider() {
            switch character {
            case "(":
                let expression = try GroupExpression.consume(provider: provider, with: context)
                stack.push(expression)
            case "[":
                let expression = try CharacterSetExpression.consume(provider: provider, with: context)
                stack.push(expression)
            case ")", "]":
                throw ParsingError.invalidSymbol
            case ".":
                stack.push(AnyCharacterExpression())
            case "+":
                guard let expression = stack.pop() else { throw ParsingError.invalidSymbol }
                stack.push(expression)
                stack.push(RepeatingExpression(expression))
            case "*":
                guard let expression = stack.pop() else { throw ParsingError.invalidSymbol }
                stack.push(RepeatingExpression(expression))
            case "?":
                guard let expression = stack.pop() else { throw ParsingError.invalidSymbol }
                stack.push(OptionalExpression(expression))
            case "|":
                let expression = UnionExpression(
                    stack.count == 1 ? stack.first! : GroupExpression(with: stack.representation),
                    try Expression.consume(provider: provider, with: context)
                )
                stack.clear()
                stack.push(expression)
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
            return GroupExpression(with: stack.representation)
        }
    }
}
