//
//  ParserTests.swift
//

import XCTest

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
    
    func testCharacterSetExpression() {
        let parser = Parser(with: "[abc]")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is CharacterSetExpression)
        
        let characterSet = (parser.result as! CharacterSetExpression).characterSet
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
    
    func testRepeatingExpression() {
        let parser = Parser(with: "b*")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is RepeatingExpression)
        
        let result = parser.result as! RepeatingExpression
        XCTAssert(result.inner is CharacterExpression)
        
        let character = (result.inner as! CharacterExpression).character
        XCTAssertEqual(character, "b")
    }
    
    func testRepeatingPlusOneExpression() {
        let parser = Parser(with: "c+")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is GroupExpression)
        
        let result = parser.result as! GroupExpression
        XCTAssertEqual(result.children.count, 2)
        XCTAssert(result.children.first is CharacterExpression)
        XCTAssert(result.children.last is RepeatingExpression)
        
        let character = (result.children.first as! CharacterExpression).character
        XCTAssertEqual(character, "c")
        
        let repeating = result.children.last as! RepeatingExpression
        let innerCharacter = (repeating.inner as! CharacterExpression).character
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
    
    func testGroupExpression() {
        let parser = Parser(with: "(ab)")
        
        XCTAssertNotNil(parser.result)
        XCTAssert(parser.result is GroupExpression)
        
        let group = parser.result as! GroupExpression
        XCTAssertEqual(group.children.count, 2)
        
        
        let children = group.children.compactMap { ($0 as? CharacterExpression)?.character }
        XCTAssertEqual(children.count, 2)
        XCTAssertEqual(children[0], "a")
        XCTAssertEqual(children[1], "b")
    }
}