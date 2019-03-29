//
//  NFATests.swift
//  RegexTests
//
//  Created by Dan Lindholm on 29/03/2019.
//  Copyright © 2019 Dan Lindholm. All rights reserved.
//

import XCTest

class NFATests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testEmptyNFA() {
        let nfa = NFA()
        
        XCTAssertEqual(nfa.states.initial.category, State.Category.initial)
        XCTAssertEqual(nfa.states.terminal.category, State.Category.terminal)
        XCTAssertTrue(nfa.matches(""))
        XCTAssertFalse(nfa.matches("a"))
    }
    
    func testConcatenatedNFA() {
        let nfa = NFA()
        nfa.concatenate(with: NFA())
        
        XCTAssertTrue(nfa.matches(""))
        XCTAssertFalse(nfa.matches("a"))
    }

    func testLongConcatenatedNFA() {
        let nfa = (0..<15).reduce(into: NFA()) { (nfa, _) in
            nfa.concatenate(with: NFA())
        }
        
        XCTAssertTrue(nfa.matches(""))
        XCTAssertFalse(nfa.matches("a"))
    }
    
    func testUnionNFA() {
        let nfa = NFA(with: State(category: .standard), matching: .single("a"))
        nfa.union(with: NFA(with: State(category: .standard), matching: .single("b")))
        
        XCTAssertTrue(nfa.matches("a"))
        XCTAssertTrue(nfa.matches("b"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("c"))
        XCTAssertFalse(nfa.matches("ab"))
    }
    
    func testLargeUnionNFA() {
        let range = UInt8(ascii: "b")...UInt8(ascii: "x")
        let initial = NFA(with: State(category: .standard), matching: .single("a"))
        let nfa = range.reduce(into: initial) { (nfa, codePoint) in
            let character = Character(UnicodeScalar(codePoint))
            nfa.union(with: NFA(with: State(category: .standard), matching: .single(character)))
        }
        
        XCTAssertTrue(nfa.matches("a"))
        XCTAssertTrue(nfa.matches("d"))
        XCTAssertTrue(nfa.matches("v"))
        XCTAssertTrue(nfa.matches("x"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("y"))
        XCTAssertFalse(nfa.matches("z"))
        XCTAssertFalse(nfa.matches(" "))
        XCTAssertFalse(nfa.matches("ab"))
        XCTAssertFalse(nfa.matches("ff"))
    }
    
    func testUnionAndConcatenationCombined() {
        let hello = NFA(with: State(category: .standard), matching: .single("h"))
        hello.concatenate(with: NFA(with: State(category: .standard), matching: .single("e")))
        hello.concatenate(with: NFA(with: State(category: .standard), matching: .single("l")))
        hello.concatenate(with: NFA(with: State(category: .standard), matching: .single("l")))
        hello.concatenate(with: NFA(with: State(category: .standard), matching: .single("o")))
        
        let x = NFA(with: State(category: .standard), matching: .single("x"))
        x.union(with: hello)
        
        XCTAssertTrue(x.matches("hello"))
        XCTAssertTrue(x.matches("x"))
        XCTAssertFalse(x.matches(""))
        XCTAssertFalse(x.matches("h"))
        XCTAssertFalse(x.matches("he"))
        XCTAssertFalse(x.matches("hel"))
        XCTAssertFalse(x.matches("hell"))
        XCTAssertFalse(x.matches("hellox"))
        XCTAssertFalse(x.matches("xhello"))
    }
    
    func testSingleCharacterNFA() {
        let state = State(category: .standard)
        let nfa = NFA(with: state, matching: Symbol.single("x"))
        
        XCTAssertTrue(nfa.matches("x"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("a"))
    }
    
    func testConcatenatedSingleCharacterNFA() {
        let a = State(category: .standard)
        let b = State(category: .standard)
        let nfa = NFA(with: a, matching: .single("a"))
        nfa.concatenate(with: NFA(with: b, matching: .single("b")))
        
        XCTAssertTrue(nfa.matches("ab"))
        XCTAssertFalse(nfa.matches("a"))
        XCTAssertFalse(nfa.matches("b"))
        XCTAssertFalse(nfa.matches(""))
    }
    
    func testCharacterSetNFA() {
        let state = State(category: .standard)
        let nfa = NFA(with: state, matching: .set(Set<Character>("abc")))
        
        XCTAssertTrue(nfa.matches("a"))
        XCTAssertTrue(nfa.matches("b"))
        XCTAssertTrue(nfa.matches("c"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("x"))
    }
    
    func testConcatenatedCharacterSetNFA() {
        let a = State(category: .standard)
        let b = State(category: .standard)
        let nfa = NFA(with: a, matching: .set(Set<Character>("abc")))
        nfa.concatenate(with: NFA(with: b, matching: .single("d")))
        
        XCTAssertTrue(nfa.matches("ad"))
        XCTAssertTrue(nfa.matches("bd"))
        XCTAssertTrue(nfa.matches("cd"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("a"))
        XCTAssertFalse(nfa.matches("b"))
        XCTAssertFalse(nfa.matches("c"))
        XCTAssertFalse(nfa.matches("ab"))
        XCTAssertFalse(nfa.matches("dd"))
        XCTAssertFalse(nfa.matches("add"))
    }
    
    func testAnyCharacterNFA() {
        let state = State(category: .standard)
        let nfa = NFA(with: state, matching: .any)
        
        XCTAssertTrue(nfa.matches("a"))
        XCTAssertTrue(nfa.matches("b"))
        XCTAssertTrue(nfa.matches("c"))
        XCTAssertTrue(nfa.matches("x"))
        XCTAssertTrue(nfa.matches("y"))
        XCTAssertTrue(nfa.matches(" "))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("ab"))
    }
}
