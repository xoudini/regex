//
//  HashSetTests.swift
//

import XCTest
@testable import Regex

class HashSetTests: XCTestCase {

    let smallBufferSize = 16
    var set: HashSet<Character>!
    
    let upper = "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    let lower = "abcdefghijklmnopqrstuvwxyz"
    let digits = "0123456789"
    let special = "*',.-;:_¨^´`+?=()[]{}/&¶§|%€$¢£¥#@!¡©"
    
    override func setUp() {
        self.set = HashSet()
    }

    override func tearDown() {
        self.set = nil
    }
    
    func testContains() {
        self.set = HashSet(with: self.smallBufferSize)
        
        self.set.insert("z")
        
        XCTAssertTrue(self.set.contains("z"))
        XCTAssertFalse(self.set.contains("x"))
        XCTAssertFalse(self.set.contains("a"))
        XCTAssertFalse(self.set.contains("ä"))
    }

    func testInsertWithFewElements() {
        self.set = HashSet(with: self.smallBufferSize)
        
        let string = "abcdef"
        
        for character in string {
            self.set.insert(character)
        }
        
        XCTAssertEqual(self.set.count, string.count)
        
        for character in string {
            XCTAssertTrue(self.set.contains(character))
        }
    }

    func testInsertWithManyElements() {
        self.set = HashSet(with: self.smallBufferSize)
        
        let string = self.lower + self.upper + self.digits
        
        for character in string {
            self.set.insert(character)
        }
        
        XCTAssertEqual(self.set.count, string.count)
        
        for character in string {
            XCTAssertTrue(self.set.contains(character))
        }
    }
    
    func testInsertWithDefaultBufferSize() {
        let string = self.lower + self.digits + self.special
        
        for character in string {
            self.set.insert(character)
        }
        
        XCTAssertEqual(self.set.count, string.count)
        
        for character in string {
            XCTAssertTrue(self.set.contains(character))
        }
        
        for character in self.upper {
            XCTAssertFalse(self.set.contains(character))
        }
    }
    
    func testConvenienceInitializer() {
        let string = self.lower + self.upper + self.digits
        
        self.set = HashSet(from: string)
        
        XCTAssertEqual(self.set.count, string.count)
        
        for character in string {
            XCTAssertTrue(self.set.contains(character))
        }
    }
    
    func testInsertingDuplicates() {
        let string = self.lower
        let duplicates = string.shuffled().dropLast(10)
        
        for character in duplicates + string {
            self.set.insert(character)
        }
        
        XCTAssertEqual(self.set.count, string.count)
        
        for character in string {
            XCTAssertTrue(self.set.contains(character))
        }
    }
    
    func testIteration() {
        self.set = HashSet(from: self.digits)
        
        for character in self.set {
            XCTAssertTrue(self.digits.contains(character))
        }
    }
}
