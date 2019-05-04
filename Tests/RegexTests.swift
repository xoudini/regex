//
//  RegexTests.swift
//

import XCTest
@testable import Regex

class RegexTests: XCTestCase {

    override func setUp() {
    }

    override func tearDown() {
    }

    func testCommonExpression1() {
        let parser = Parser(with: ".*\\.(jpg|png)")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("IMG_0001.jpg"))
        XCTAssertTrue(nfa.matches("logo.png"))
        XCTAssertTrue(nfa.matches("image.with.dots.in.name.png"))
        
        XCTAssertFalse(nfa.matches("IMG_0001.JPG"))
        XCTAssertFalse(nfa.matches("testimage.jpg.exe"))
    }
}
