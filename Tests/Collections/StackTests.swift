//
//  StackTests.swift
//

import XCTest
@testable import Regex

class StackTests: XCTestCase {
    
    var stack: Stack<Character>!

    override func setUp() {
        self.stack = Stack()
    }

    override func tearDown() {
        self.stack = nil
    }
    
    func testDesignatedInitializer() {
        self.stack = Stack<Character>(from: ["a", "b", "c"])
        XCTAssertEqual(self.stack.count, 3)
        XCTAssertEqual(self.stack.pop(), "c")
    }
    
    func testLiteralAssignment() {
        self.stack = ["a", "b", "c", "d"]
        XCTAssertEqual(self.stack.count, 4)
        XCTAssertEqual(self.stack.pop(), "d")
    }

    func testPush() {
        self.stack.push("X")
        XCTAssertEqual(self.stack.first, "X")
    }
    
    func testPushWithMultipleEntries() {
        self.stack.push("a")
        self.stack.push("b")
        self.stack.push("c")
        XCTAssertEqual(self.stack.count, 3)
    }
    
    func testPop() {
        self.stack.push("X")
        XCTAssertEqual(self.stack.pop(), "X")
        XCTAssertTrue(self.stack.isEmpty)
    }
    
    func testPopWithEmptyStack() {
        XCTAssertNil(self.stack.pop())
    }
    
    func testPopWithMultipleEntries() {
        self.stack = ["a", "b", "c"]
        XCTAssertEqual(self.stack.pop(), "c")
        XCTAssertEqual(self.stack.pop(), "b")
        XCTAssertEqual(self.stack.pop(), "a")
        XCTAssertNil(self.stack.pop())
    }
    
    func testSubscript() {
        self.stack.push("X")
        XCTAssertEqual(self.stack[0], "X")
    }
    
    func testForInIteration() {
        self.stack = ["a", "b", "c"]
        let copy = Stack<Character>()
        
        for element in self.stack {
            copy.push(element)
        }
        
        XCTAssertEqual(copy.pop(), "c")
        XCTAssertEqual(copy.pop(), "b")
        XCTAssertEqual(copy.pop(), "a")
        XCTAssertNil(copy.pop())
    }
}
