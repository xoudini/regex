//
//  NFATests.swift
//

import XCTest
@testable import Regex

class NFATests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    
    // MARK: - Simple construction

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
        let nfa = NFA(with: state, matching: .set(HashSet<Character>(from: "abc")))
        
        XCTAssertTrue(nfa.matches("a"))
        XCTAssertTrue(nfa.matches("b"))
        XCTAssertTrue(nfa.matches("c"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("x"))
    }
    
    func testConcatenatedCharacterSetNFA() {
        let a = State(category: .standard)
        let b = State(category: .standard)
        let nfa = NFA(with: a, matching: .set(HashSet<Character>(from: "abc")))
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
    
    
    // MARK: - Expression conversion
    
    func testSimpleExpression() {
        let parser = Parser(with: "abcd")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("abcd"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("abc"))
        XCTAssertFalse(nfa.matches("bcd"))
        XCTAssertFalse(nfa.matches("aacd"))
        XCTAssertFalse(nfa.matches("abdd"))
        XCTAssertFalse(nfa.matches("abcdd"))
        XCTAssertFalse(nfa.matches("aabcd"))
    }
    
    func testAnyCharacterExpression() {
        let parser = Parser(with: "x.z")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("xaz"))
        XCTAssertTrue(nfa.matches("x z"))
        XCTAssertTrue(nfa.matches("x9z"))
        XCTAssertTrue(nfa.matches("xöz"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("xz"))
    }
    
    func testCharacterSetExpression() {
        let parser = Parser(with: "x[123]z")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("x1z"))
        XCTAssertTrue(nfa.matches("x2z"))
        XCTAssertTrue(nfa.matches("x3z"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("xz"))
        XCTAssertFalse(nfa.matches("xaz"))
        XCTAssertFalse(nfa.matches("xyz"))
        XCTAssertFalse(nfa.matches("xxz"))
        XCTAssertFalse(nfa.matches("xzz"))
        XCTAssertFalse(nfa.matches("x1zz"))
    }
    
    func testUnionExpression() {
        let parser = Parser(with: "abcd|xyz")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("abcd"))
        XCTAssertTrue(nfa.matches("xyz"))
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("xya"))
        XCTAssertFalse(nfa.matches("xyb"))
        XCTAssertFalse(nfa.matches("xyc"))
        XCTAssertFalse(nfa.matches("xyd"))
        XCTAssertFalse(nfa.matches("ayz"))
        XCTAssertFalse(nfa.matches("abz"))
        XCTAssertFalse(nfa.matches("abyz"))
        XCTAssertFalse(nfa.matches("abcz"))
    }
    
    func testOptionalExpression() {
        let parser = Parser(with: "(abcd)?")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("abcd"))
        XCTAssertTrue(nfa.matches(""))
        XCTAssertFalse(nfa.matches("abcdabcd"))
        XCTAssertFalse(nfa.matches("abcdabcdabcd"))
        XCTAssertFalse(nfa.matches("abc"))
        XCTAssertFalse(nfa.matches("abcda"))
        XCTAssertFalse(nfa.matches("dabcd"))
        XCTAssertFalse(nfa.matches("aaaa"))
        XCTAssertFalse(nfa.matches("dddd"))
    }
    
    func testKleeneStarExpression() {
        let parser = Parser(with: "(abcd)*")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("abcd"))
        XCTAssertTrue(nfa.matches("abcdabcd"))
        XCTAssertTrue(nfa.matches("abcdabcdabcd"))
        XCTAssertTrue(nfa.matches(""))
        XCTAssertFalse(nfa.matches("abc"))
        XCTAssertFalse(nfa.matches("abcda"))
        XCTAssertFalse(nfa.matches("dabcd"))
        XCTAssertFalse(nfa.matches("aaaa"))
        XCTAssertFalse(nfa.matches("dddd"))
    }
    
    func testPlusExpression() {
        let parser = Parser(with: "(abcd)+")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("abcd"))
        XCTAssertTrue(nfa.matches("abcdabcd"))
        XCTAssertTrue(nfa.matches("abcdabcdabcd"))
        XCTAssertFalse(nfa.matches(""))
    }
    
    func testNegatedChoiceExpression() {
        let parser = Parser(with: "a[^123]c")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("abc"))
        XCTAssertTrue(nfa.matches("axc"))
        XCTAssertTrue(nfa.matches("aöc"))
        XCTAssertFalse(nfa.matches("a1c"))
        XCTAssertFalse(nfa.matches("a2c"))
        XCTAssertFalse(nfa.matches("a3c"))
        XCTAssertFalse(nfa.matches("abcd"))
    }
    
    func testWCharacterClassExpression() {
        let parser = Parser(with: "\\w")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("f"))
        XCTAssertTrue(nfa.matches("F"))
        XCTAssertTrue(nfa.matches("_"))
        XCTAssertTrue(nfa.matches("0"))
        XCTAssertTrue(nfa.matches("9"))
        XCTAssertTrue(nfa.matches("a"))
        XCTAssertTrue(nfa.matches("z"))
        XCTAssertTrue(nfa.matches("A"))
        XCTAssertTrue(nfa.matches("Z"))
        
        XCTAssertFalse(nfa.matches("ö"))
        XCTAssertFalse(nfa.matches("-"))
        
        XCTAssertFalse(nfa.matches("aa"))
        XCTAssertFalse(nfa.matches("Test"))
    }
    
    func testNegatedWCharacterClassExpression() {
        let parser = Parser(with: "\\W")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertFalse(nfa.matches("f"))
        XCTAssertFalse(nfa.matches("F"))
        XCTAssertFalse(nfa.matches("_"))
        XCTAssertFalse(nfa.matches("0"))
        XCTAssertFalse(nfa.matches("9"))
        XCTAssertFalse(nfa.matches("a"))
        XCTAssertFalse(nfa.matches("z"))
        XCTAssertFalse(nfa.matches("A"))
        XCTAssertFalse(nfa.matches("Z"))
        
        XCTAssertTrue(nfa.matches("ö"))
        XCTAssertTrue(nfa.matches("-"))
        
        XCTAssertFalse(nfa.matches("aa"))
        XCTAssertFalse(nfa.matches("Test"))
    }
    
    func testDCharacterClassExpression() {
        let parser = Parser(with: "\\d")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("0"))
        XCTAssertTrue(nfa.matches("2"))
        XCTAssertTrue(nfa.matches("3"))
        XCTAssertTrue(nfa.matches("6"))
        XCTAssertTrue(nfa.matches("9"))
        
        XCTAssertFalse(nfa.matches("A"))
        XCTAssertFalse(nfa.matches("z"))
        XCTAssertFalse(nfa.matches("å"))
        XCTAssertFalse(nfa.matches("-"))
        
        XCTAssertFalse(nfa.matches("00"))
        XCTAssertFalse(nfa.matches("12345"))
    }
    
    func testNegatedDCharacterClassExpression() {
        let parser = Parser(with: "\\D")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertFalse(nfa.matches("0"))
        XCTAssertFalse(nfa.matches("2"))
        XCTAssertFalse(nfa.matches("3"))
        XCTAssertFalse(nfa.matches("6"))
        XCTAssertFalse(nfa.matches("9"))
        
        XCTAssertTrue(nfa.matches("A"))
        XCTAssertTrue(nfa.matches("z"))
        XCTAssertTrue(nfa.matches("å"))
        XCTAssertTrue(nfa.matches("-"))
        
        XCTAssertFalse(nfa.matches("00"))
        XCTAssertFalse(nfa.matches("12345"))
    }
    
    func testSCharacterClassExpression() {
        let parser = Parser(with: "\\s")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches(" "))
        XCTAssertTrue(nfa.matches("\t"))
        XCTAssertTrue(nfa.matches("\n"))
        XCTAssertTrue(nfa.matches("\r"))
        XCTAssertTrue(nfa.matches("\u{0b}"))
        XCTAssertTrue(nfa.matches("\u{0c}"))
        
        XCTAssertFalse(nfa.matches("A"))
        XCTAssertFalse(nfa.matches("z"))
        XCTAssertFalse(nfa.matches("å"))
        XCTAssertFalse(nfa.matches("-"))
        XCTAssertFalse(nfa.matches(":"))
        XCTAssertFalse(nfa.matches("0"))
        XCTAssertFalse(nfa.matches("\u{1b}"))
        
        XCTAssertFalse(nfa.matches("  "))
        XCTAssertFalse(nfa.matches(" \n"))
    }
    
    func testNegatedSCharacterClassExpression() {
        let parser = Parser(with: "\\S")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertFalse(nfa.matches(" "))
        XCTAssertFalse(nfa.matches("\t"))
        XCTAssertFalse(nfa.matches("\n"))
        XCTAssertFalse(nfa.matches("\r"))
        XCTAssertFalse(nfa.matches("\u{0b}"))
        XCTAssertFalse(nfa.matches("\u{0c}"))
        
        XCTAssertTrue(nfa.matches("A"))
        XCTAssertTrue(nfa.matches("z"))
        XCTAssertTrue(nfa.matches("å"))
        XCTAssertTrue(nfa.matches("-"))
        XCTAssertTrue(nfa.matches(":"))
        XCTAssertTrue(nfa.matches("0"))
        XCTAssertTrue(nfa.matches("\u{1b}"))
        
        XCTAssertFalse(nfa.matches("  "))
        XCTAssertFalse(nfa.matches(" \n"))
    }
    
    func testComplexExpression1() {
        let parser = Parser(with: "(ab)+|[xyz]+")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("ab"))
        XCTAssertTrue(nfa.matches("abab"))
        XCTAssertTrue(nfa.matches("ababab"))
        
        XCTAssertTrue(nfa.matches("x"))
        XCTAssertTrue(nfa.matches("xx"))
        XCTAssertTrue(nfa.matches("y"))
        XCTAssertTrue(nfa.matches("yy"))
        XCTAssertTrue(nfa.matches("z"))
        XCTAssertTrue(nfa.matches("zz"))
        XCTAssertTrue(nfa.matches("xzyxz"))
        
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("abx"))
        XCTAssertFalse(nfa.matches("xab"))
        XCTAssertFalse(nfa.matches("abxzz"))
    }
    
    func testComplexExpression2() {
        let parser = Parser(with: "abc.*def")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("abcdef"))
        XCTAssertTrue(nfa.matches("abc-def"))
        XCTAssertTrue(nfa.matches("abc--def"))
        XCTAssertTrue(nfa.matches("abc-----------------------------------------------def"))
        
        XCTAssertFalse(nfa.matches(""))
    }
    
    func testComplexExpression3() {
        let parser = Parser(with: "a[xyz]+x.?")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("axx"))
        XCTAssertTrue(nfa.matches("axxx"))
        XCTAssertTrue(nfa.matches("axxs"))
        XCTAssertTrue(nfa.matches("ayxs"))
        XCTAssertTrue(nfa.matches("azyzx"))
        XCTAssertTrue(nfa.matches("azyzxs"))
        XCTAssertTrue(nfa.matches("axxxxxxxxxxxxxxxxxxxxxxx"))
        
        XCTAssertFalse(nfa.matches(""))
        XCTAssertFalse(nfa.matches("azyzs"))
        XCTAssertFalse(nfa.matches("ayys"))
        XCTAssertFalse(nfa.matches("xxxs"))
    }
    
    func testReDoSExpression1() {
        let parser = Parser(with: "(a+)+")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("a"))
        XCTAssertTrue(nfa.matches("aaa"))
        XCTAssertTrue(nfa.matches("aaaaaaaaa"))
        
        XCTAssertFalse(nfa.matches(""))
        
        self.measure {
            XCTAssertTrue(nfa.matches("aaaaaaaaaaaaaaa"))
        }
    }
    
    func testReDoSExpression2() {
        let parser = Parser(with: "(a|aa)+")
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        XCTAssertTrue(nfa.matches("a"))
        XCTAssertTrue(nfa.matches("aaa"))
        XCTAssertTrue(nfa.matches("aaaaaaaaa"))
        
        XCTAssertFalse(nfa.matches(""))
        
        self.measure {
            XCTAssertTrue(nfa.matches("aaaaaaaaaaaaaaa"))
        }
    }
    
    func testReDoSExpression3() {
        let n = 10
        let regex = (0..<n).map{ _ in "a?" }.joined() + (0..<n).map{ _ in "a" }.joined()
        let input = (0..<n).map{ _ in "a" }.joined()
        
        let parser = Parser(with: regex)
        XCTAssertNotNil(parser.result)
        
        let nfa = NFA(from: parser.result!)
        
        self.measure {
            XCTAssertTrue(nfa.matches(input))
        }
    }
}
