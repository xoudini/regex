//
//  Expression.swift
//

import Foundation

protocol Expression {
}

struct AnyCharacterExpression: Expression {
}

struct CharacterExpression: Expression {
    let character: Character
    
    init(_ character: Character) {
        self.character = character
    }
}

struct CharacterSetExpression: Expression {
    let characterSet: Set<Character>
    
    init(_ string: inout String) {
        var characterSet = Set<Character>()
        
        while let character = string.first, string.removeFirst() != "]" {
            characterSet.insert(character)
        }
        
        self.characterSet = characterSet
    }
}

struct OptionalExpression: Expression {
    let inner: Expression
    
    init(_ inner: Expression) {
        self.inner = inner
    }
}

struct RepeatingExpression: Expression {
    let inner: Expression
    
    init(_ inner: Expression) {
        self.inner = inner
    }
}

struct UnionExpression: Expression {
    let alternatives: [Expression]
    
    init(_ alternatives: Expression...) {
        self.alternatives = alternatives
    }
}

struct GroupExpression: Expression {
    let children: [Expression]
    
    var reduced: Expression? {
        guard self.children.count == 1, let first = self.children.first else { return nil }
        return first
    }
    
    init(_ string: inout String) {
        let stack = Stack<Expression>()
        
        while let character = string.first, string.removeFirst() != ")" {
            switch character {
            case ".":
                stack.push(AnyCharacterExpression())
            case "(":
                stack.push(GroupExpression(&string))
            case "[":
                stack.push(CharacterSetExpression(&string))
            case "+":
                let expression = stack.pop()!
                stack.push(expression)
                stack.push(RepeatingExpression(expression))
            case "*":
                let expression = stack.pop()!
                stack.push(RepeatingExpression(expression))
            case "?":
                let expression = stack.pop()!
                stack.push(OptionalExpression(expression))

            case "|":
                let union = UnionExpression(GroupExpression(with: stack.representation), GroupExpression(&string))
                stack.clear()
                stack.push(union)
            default:
                stack.push(CharacterExpression(character))
            }
        }
        
        self.children = stack.representation
    }
    
    init(with children: [Expression]) {
        self.children = children
    }
}

struct ExpressionTree {
    let root: Expression
    
    init(with regex: String) {
        var copy = regex
        self.root = GroupExpression(&copy)
    }
}
