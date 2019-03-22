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
}

struct Expression: ExpressionConvertible {
    
    static func consume(provider: @escaping Provider, with context: ParserContext) throws -> ExpressionConvertible {
        let stack: Stack<ExpressionConvertible> = Stack()
        
        loop: while let character = try provider() {
            switch character {
            case "(":
                context.enter(state: .group)
                let expression = try Expression.consume(provider: provider, with: context)
                stack.push(expression)
            case ")":
                guard context.state == .group else { throw ParsingError.invalidSymbol }
                context.exit()
                break loop
            case "[":
                let expression = try CharacterSetExpression.consume(provider: provider, with: context)
                stack.push(expression)
            case "]":
                guard context.state == .set else { throw ParsingError.invalidSymbol }
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
