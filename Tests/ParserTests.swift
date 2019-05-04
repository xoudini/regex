//
//  ParserTests.swift
//

import XCTest
@testable import Regex

class ParserTests: XCTestCase {

    func testEmptyExpression() {
        let parser = Parser(with: "")
        
        XCTAssertThrowsError(try parser.parse()) { error in
            XCTAssert(error is ParsingError)
            XCTAssertEqual(error as? ParsingError, .emptyExpression)
        }
    }
    
    func testAnyCharacterExpression() {
        let parser = Parser(with: ".")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is AnyCharacterExpression)
    }
    
    func testCharacterExpression() {
        let parser = Parser(with: "x")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is CharacterExpression)
    }
    
    func testChoiceExpression() {
        let parser = Parser(with: "[abc]")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is ChoiceExpression)
        
        let characterSet = (parser.result as! ChoiceExpression).characterSet
        XCTAssert(characterSet.contains("a"))
        XCTAssert(characterSet.contains("b"))
        XCTAssert(characterSet.contains("c"))
        
    }
    
    func testOptionalExpression() {
        let parser = Parser(with: "a?")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is OptionalExpression)
        
        let result = parser.result as! OptionalExpression
        XCTAssert(result.inner is CharacterExpression)
        
        let character = (result.inner as! CharacterExpression).character
        XCTAssertEqual(character, "a")
    }
    
    func testRepeatedExpression() {
        let parser = Parser(with: "b*")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is RepeatedExpression)
        
        let result = parser.result as! RepeatedExpression
        XCTAssert(result.inner is CharacterExpression)
        
        let character = (result.inner as! CharacterExpression).character
        XCTAssertEqual(character, "b")
    }
    
    func testRepeatedPlusOneExpression() {
        let parser = Parser(with: "c+")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is ConcatenatedExpression)
        
        let result = parser.result as! ConcatenatedExpression
        XCTAssertEqual(result.children.count, 2)
        XCTAssert(result.children.first is CharacterExpression)
        XCTAssert(result.children.last is RepeatedExpression)
        
        let character = (result.children.first as! CharacterExpression).character
        XCTAssertEqual(character, "c")
        
        let repeated = result.children.last as! RepeatedExpression
        let innerCharacter = (repeated.inner as! CharacterExpression).character
        XCTAssertEqual(character, innerCharacter)
    }
    
    func testUnionExpression() {
        let parser = Parser(with: "a|b|c")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is UnionExpression)
        
        let result = parser.result as! UnionExpression
        let alternatives = result.alternatives.compactMap { ($0 as? CharacterExpression)?.character }
        XCTAssertEqual(alternatives.count, 3)
        XCTAssertEqual(alternatives[0], "a")
        XCTAssertEqual(alternatives[1], "b")
        XCTAssertEqual(alternatives[2], "c")
    }
    
    func testConcatenatedExpression() {
        let parser = Parser(with: "(ab)")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is ConcatenatedExpression)
        
        let group = parser.result as! ConcatenatedExpression
        XCTAssertEqual(group.children.count, 2)
        
        
        let children = group.children.compactMap { ($0 as? CharacterExpression)?.character }
        XCTAssertEqual(children.count, 2)
        XCTAssertEqual(children[0], "a")
        XCTAssertEqual(children[1], "b")
    }
    
    func testEscapedCharacter() {
        let parser = Parser(with: "ab\\?")
        
        XCTAssertNotNil(parser.result)
        
        let group = parser.result as! ConcatenatedExpression
        XCTAssertEqual(group.children.count, 3)
        
        let children = group.children.compactMap { ($0 as? CharacterExpression)?.character }
        XCTAssertEqual(children.count, 3)
        XCTAssertEqual(children[0], "a")
        XCTAssertEqual(children[1], "b")
        XCTAssertEqual(children[2], "?")
    }
    
    func testEscapedCharacterInChoiceContext() {
        let parser = Parser(with: "a[\\[\\]]")
        
        XCTAssertNotNil(parser.result)
        
        let group = parser.result as! ConcatenatedExpression
        XCTAssertEqual(group.children.count, 2)
        
        let choice = group.children.last as! ChoiceExpression
        XCTAssertTrue(choice.characterSet.contains("["))
        XCTAssertTrue(choice.characterSet.contains("]"))
        XCTAssertEqual(choice.characterSet.count, 2)
    }
    
    func testNegatedExpressionInChoiceContext() {
        let parser = Parser(with: "a[^0123456789]c")
        
        XCTAssertNotNil(parser.result)
        
        let group = parser.result as! ConcatenatedExpression
        XCTAssertEqual(group.children.count, 3)
        
        XCTAssertTrue(group.children[1] is NegatedExpression)
    }
}
