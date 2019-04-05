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


// MARK: -

/// An expression matching any literal character.
///
/// - note:     Represented by the `.` literal.
///
struct AnyCharacterExpression: ExpressionConvertible { }

extension AnyCharacterExpression: SymbolConvertible {
    
    var symbol: Symbol {
        return .any
    }
}

extension AnyCharacterExpression: CustomStringConvertible {
    
    var description: String {
        return "Any"
    }
}


// MARK: -

/// An expression matching some specific literal character.
///
struct CharacterExpression: ExpressionConvertible {
    let character: Character
    
    init(_ character: Character) {
        self.character = character
    }
}

extension CharacterExpression: SymbolConvertible {
    
    var symbol: Symbol {
        return .single(self.character)
    }
}

extension CharacterExpression: CustomStringConvertible {
    
    var description: String {
        return self.character.description
    }
}


// MARK: -

/// An expression matching a character in a given set.
///
/// - note:     Represented by the `[...]` expression.
///
struct CharacterSetExpression: ExpressionConvertible {
    var characterSet: Set<Character>
    
    init(with characterSet: Set<Character>) {
        self.characterSet = characterSet
    }
}

extension CharacterSetExpression: SymbolConvertible {
    
    var symbol: Symbol {
        return .set(self.characterSet)
    }
}

extension CharacterSetExpression: CustomStringConvertible {
    
    var description: String {
        let characters = self.characterSet.map{ $0.description }.sorted().joined(separator: ", ")
        return "Choice(\(characters))"
    }
}


// MARK: -

/// An expression encapsulating another expression, which is optionally matched.
///
/// - note:     Represented by the `?` literal.
///
struct OptionalExpression: ExpressionConvertible {
    let inner: ExpressionConvertible
    
    init(_ inner: ExpressionConvertible) {
        self.inner = inner
    }
}

extension OptionalExpression: NFAConvertible {
    
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        let nfa = NFA(from: self.inner)
        
        // Default transitions
        initial.add(Transition(to: nfa.states.initial))
        nfa.states.terminal.add(Transition(to: terminal))
        
        // Handle optional case
        initial.add(Transition(to: terminal))
    }
}

extension OptionalExpression: CustomStringConvertible {
    
    var description: String {
        return "Optional(\(self.inner.description))"
    }
}


// MARK: -

/// An expression encapsulating another expression, which is optionally matched repeatedly.
///
/// - note:     Represented by the `*` literal.
///
struct RepeatedExpression: ExpressionConvertible {
    let inner: ExpressionConvertible
    
    init(_ inner: ExpressionConvertible) {
        self.inner = inner
    }
}

extension RepeatedExpression: NFAConvertible {
    
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        let nfa = NFA(from: self.inner)
        
        // Default transitions
        initial.add(Transition(to: nfa.states.initial))
        nfa.states.terminal.add(Transition(to: terminal))
        
        // Handle optional case
        initial.add(Transition(to: terminal))
        
        // Handle repeating case
        nfa.states.terminal.add(Transition(to: nfa.states.initial))
    }
}

extension RepeatedExpression: CustomStringConvertible {
    
    var description: String {
        return "Repeated(\(self.inner.description))"
    }
}


// MARK: -

/// An expression encapsulating a number of subexpressions, which are conditionally matched.
///
/// - note:     Represented by the `...|...` expression.
///
struct UnionExpression: ExpressionConvertible {
    var alternatives: [ExpressionConvertible]
    
    init(_ alternatives: ExpressionConvertible...) {
        self.alternatives = alternatives.reduce(into: []) { (accumulator, next) in
            if let expression = next as? UnionExpression {
                accumulator.append(contentsOf: expression.alternatives)
            } else {
                accumulator.append(next)
            }
        }
    }
    
    mutating func append(_ expression: ExpressionConvertible) {
        self.alternatives.append(expression)
    }
}

extension UnionExpression: NFAConvertible {
    
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        guard let first = self.alternatives.first else { fatalError() }
        let nfa = self.alternatives.dropFirst().reduce(into: NFA(from: first)) { (nfa, expression) in
            nfa.union(with: NFA(from: expression))
        }
        
        // Default transitions
        initial.add(Transition(to: nfa.states.initial))
        nfa.states.terminal.add(Transition(to: terminal))
    }
}

extension UnionExpression: CustomStringConvertible {
    
    var description: String {
        let inner = self.alternatives.map{ $0.description }.joined(separator: ", ")
        return "Union(\(inner))"
    }
}


// MARK: -

/// An expression encapsulating a number of subexpressions, which are matched in succession.
///
/// - note:     Represented by the `(...)` expression.
///
struct ConcatenatedExpression: ExpressionConvertible {
    var children: [ExpressionConvertible]
    
    init(with children: [ExpressionConvertible]) {
        self.children = children
    }
}

extension ConcatenatedExpression: NFAConvertible {
    
    func insert(between states: (State, State)) {
        let (initial, terminal) = states
        guard let first = self.children.first else { fatalError() }
        let nfa = self.children.dropFirst().reduce(into: NFA(from: first)) { (nfa, expression) in
            nfa.concatenate(with: NFA(from: expression))
        }
        
        // Default transitions
        initial.add(Transition(to: nfa.states.initial))
        nfa.states.terminal.add(Transition(to: terminal))
    }
}

extension ConcatenatedExpression: CustomStringConvertible {
    
    var description: String {
        let inner = self.children.map{ $0.description }.joined(separator: ", ")
        return "Concatenated(\(inner))"
    }
}


// MARK: -

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
                var expression = stack.pop() as! CharacterSetExpression
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
                stack.push(CharacterSetExpression(with: []))
                
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
