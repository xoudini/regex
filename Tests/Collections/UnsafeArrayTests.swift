//
//  UnsafeArrayTests.swift
//

import XCTest

@testable import Regex

#if os(OSX)
let rand = arc4random
#elseif os(Linux)
let rand = random
#endif

class UnsafeArrayTests: XCTestCase {

    var array: UnsafeArray<Int>!
    
    class Dummy {
        var value: Int
        init() {
            self.value = 999
        }
    }
    
    weak var dummy: Dummy?
    
    override func setUp() {
        self.array = UnsafeArray()
    }

    override func tearDown() {
        self.array = nil
    }
    
    func testIsEmpty() {
        XCTAssertTrue(self.array.isEmpty)
    }
    
    func testArrayInitializer() {
        let xs = [1, 2, 3, 4, 5]
        self.array = UnsafeArray(xs)
        XCTAssertEqual(self.array.count, xs.count)
        XCTAssertEqual(self.array[0], xs[0])
        XCTAssertEqual(self.array[4], xs[4])
    }
    
    func testLiteralAssignment() {
        self.array = [1, 2, 3, 4, 5]
        XCTAssertEqual(self.array.count, 5)
        
        for (i, x) in (1...5).enumerated() {
            XCTAssertEqual(self.array[i], x)
        }
    }
    
    func testInitializingInsert() {
        self.array.insert(1, at: self.array.endIndex)
        XCTAssertFalse(self.array.isEmpty)
        XCTAssertEqual(self.array.count, 1)
        XCTAssertEqual(self.array[0], 1)
    }
    
    func testAssigningInsert() {
        self.array.insert(10, at: self.array.endIndex)
        self.array.insert(11, at: self.array.endIndex)
        self.array.insert(12, at: self.array.endIndex)
        XCTAssertEqual(self.array[1], 11)
        
        self.array.insert(99, at: 1)
        XCTAssertEqual(self.array[1], 99)
    }
    
    func testReallocatingInsert() {
        let capacity = self.array.capacity
        
        while 0 < (capacity - self.array.count) {
            self.array.insert(1234, at: self.array.endIndex)
        }
        
        XCTAssertEqual(self.array.count, self.array.capacity)
        
        // This is where the resizing should happen
        self.array.insert(123, at: self.array.endIndex)
        XCTAssertEqual(self.array.capacity, capacity * 2)
    }
    
    func testAppend() {
        let value = 10
        self.array.append(value)
        XCTAssertFalse(self.array.isEmpty)
        XCTAssertEqual(self.array.count, 1)
        XCTAssertEqual(self.array[0], value)
    }

    func testLargeAppend() {
        let xs = (0..<50000).shuffled()
        
        for x in xs {
            self.array.append(x)
        }
        
        XCTAssertEqual(self.array.count, xs.count)
    }
    
    func testAppendFromArray() {
        let xs = (0..<50000).shuffled()
        let array = UnsafeArray(xs)
        self.array.append(contentsOf: array)
        XCTAssertEqual(self.array.count, xs.count)
    }
    
    func testFirstElement() {
        let value = 15
        self.array.append(value)
        XCTAssertEqual(self.array.first, value)
    }
    
    func testLastElement() {
        let (a, b, c) = (5, 10, 15)
        self.array = [a, b, c]
        XCTAssertEqual(self.array.last, c)
    }
    
    func testBoundsWithEmptyArray() {
        XCTAssertNil(self.array.first)
        XCTAssertNil(self.array.last)
    }
    
    func testCopying() {
        self.array = [1,2,3,4,5]
        
        let copy = self.array.copy()
        XCTAssertEqual(copy.count, self.array.count)
        
        var xs = self.array.makeIterator(), ys = copy.makeIterator()
        
        while let x = xs.next(), let y = ys.next() {
            XCTAssertEqual(x, y)
        }
    }
    
    func testSliceCopying() {
        let xs = (0...30).shuffled()
        self.array = UnsafeArray(xs)
        
        let (start, end) = (4, 15)
        
        let copy = self.array.copy(from: start, to: end)
        
        XCTAssertEqual(copy.count, end - start)
        XCTAssertEqual(copy.first, xs[start])
        XCTAssertEqual(copy.last, xs[end - 1])
    }
    
    func testDeallocation() {
        var array: UnsafeArray<Dummy>! = UnsafeArray()
        array.append(Dummy())
        self.dummy = array.first
        
        XCTAssertEqual(self.dummy?.value, array.first?.value)
        
        array = nil
        XCTAssertNil(self.dummy)
    }
    
    
    // MARK: - Custom convenience functions
    
    func testUnpackingWithEmptyArray() {
        XCTAssertNil(self.array.unpack())
    }
    
    func testUnpackingWithOneElement() {
        self.array.append(15)
        
        guard let (head, tail) = self.array.unpack() else { return XCTFail() }
        
        XCTAssertEqual(head, 15)
        XCTAssertTrue(tail.isEmpty)
    }
    
    func testUnpackingWithMultipleElements() {
        let xs = (0...30).shuffled()
        self.array = UnsafeArray(xs)
        
        guard let (head, tail) = self.array.unpack() else { return XCTFail() }
        
        XCTAssertEqual(head, xs.first)
        XCTAssertEqual(tail.count, xs.count - 1)
        XCTAssertEqual(tail[10], xs[11])
        XCTAssertEqual(tail[20], xs[21])
    }
    
    func testUnpackingWithReferenceTypes() {
        var array: UnsafeArray<SampleClass>! = (0..<30).reduce(into: UnsafeArray()) { (result, _) in
            let value = Int(rand())
            result.append(SampleClass(value: value))
        }
        
        guard let (head, tail) = array.unpack() else { return XCTFail() }
        
        let value = array.first?.value
        let count = array.count - 1
        array = nil
        
        XCTAssertEqual(head.value, value)
        XCTAssertEqual(tail.count, count)
    }
    
    func testReduceWithInitialResult() {
        let bound = 10
        let xs = (1...bound).shuffled()
        self.array = UnsafeArray(xs)
        
        let factorial = (1...bound).reduce(1) { $0 * $1 }
        
        let result = self.array.reduce(1) { (result, next) in
            return result * next
        }
        
        XCTAssertEqual(result, factorial)
    }
    
    func testReduceWithAccumulatingResult() {
        let bound = 10
        let xs = (1...bound).shuffled()
        self.array = UnsafeArray(xs)
        
        let factorial = (1...bound).reduce(1) { $0 * $1 }
        
        let result = self.array.reduce(into: Int(1)) { (result, next) in
            result *= next
        }
        
        XCTAssertEqual(result, factorial)
    }
    
    func testMap() {
        self.array = [1, 2, 3]
        
        let transform: (Int) -> String = { $0.description }
        
        let mapped = self.array.map(transform)
        
        XCTAssertEqual(self.array.count, mapped.count)
        XCTAssertEqual(mapped[0], "1")
        XCTAssertEqual(mapped[1], "2")
        XCTAssertEqual(mapped[2], "3")
    }
    
    func testCompactMap() {
        let bound = 10
        let xs = (1...bound).shuffled()
        self.array = UnsafeArray(xs)
        
        let transform: (Int) -> Int? = { $0 & 1 == 0 ? $0 : nil }
        
        let compacted: UnsafeArray<Int> = self.array.compactMap(transform)
        
        XCTAssertEqual(compacted.count, bound / 2)
        
        for value in compacted {
            XCTAssertNotNil(transform(value))
        }
    }
    
    func testFlatMap() {
        let matrix: UnsafeArray<UnsafeArray<Int>> = [[1, 2, 3], [4, 5]]
        
        let flattened: UnsafeArray<Int> = matrix.flatMap { $0 }
        
        XCTAssertEqual(flattened.count, 5)
    }
    
    func testFilter() {
        let bound = 10
        let xs = (1...bound).shuffled()
        self.array = UnsafeArray(xs)
        
        let predicate: (Int) -> Bool = { 4...7 ~= $0 }
        
        let filtered: UnsafeArray<Int> = self.array.filter(predicate)
        
        XCTAssertEqual(filtered.count, 4)
        
        for value in filtered {
            XCTAssertTrue(predicate(value))
        }
    }
    
    func testFirst() {
        let bound = 10
        let xs = (1...bound).map { $0 }
        self.array = UnsafeArray(xs)
        
        let first = self.array.first { 5 < $0 }
        
        XCTAssertNotNil(first)
        XCTAssertEqual(first, 6)
    }
    
    func testFirstForNonexistingElement() {
        self.array.append(5)
        
        let first = self.array.first { $0 < 4 }
        
        XCTAssertNil(first)
    }
    
    func testContains() {
        let bound = 10
        let xs = (1...bound).map { $0 }
        self.array = UnsafeArray(xs)
        
        XCTAssertTrue(self.array.contains { 9...15 ~= $0 })
        XCTAssertFalse(self.array.contains { 10 < $0 })
    }

    
    // MARK: - Performance
    
    func testPerformanceWithBuiltinTypes() {
        let xs = (0..<500000).shuffled()
        var array: UnsafeArray<Int>!
        
        self.measure {
            // Initialize
            array = UnsafeArray()
            
            // Insert
            for x in xs {
                array.append(x)
            }
            
            // Deinitialize
            array = nil
        }
    }
    
    func testPerformanceOfArrayWithBuiltinTypes() {
        let xs = (0..<500000).shuffled()
        var array: Array<Int>!
        
        self.measure {
            // Initialize
            array = Array()
            
            // Insert
            for x in xs {
                array.append(x)
            }
            
            // Deinitialize
            array = nil
        }
    }
    
    
    struct SampleStruct {
        let x: Int
        let y: Int
    }
    
    func testPerformanceWithCustomStruct() {
        let ts = (0..<500000).reduce(into: [(x: Int, y: Int)]()) { (result, _) in
            let tuple = (Int(rand()), Int(rand()))
            result.append(tuple)
        }
        var array: UnsafeArray<SampleStruct>!
        
        self.measure {
            // Initialize
            array = UnsafeArray()
            
            // Insert
            for t in ts {
                array.append(SampleStruct(x: t.x, y: t.y))
            }
            
            // Deinitialize
            array = nil
        }
    }
    
    func testPerformanceOfArrayWithCustomStruct() {
        let ts = (0..<500000).reduce(into: [(x: Int, y: Int)]()) { (result, _) in
            let tuple = (Int(rand()), Int(rand()))
            result.append(tuple)
        }
        var array: Array<SampleStruct>!
        
        self.measure {
            // Initialize
            array = Array()
            
            // Insert
            for t in ts {
                array.append(SampleStruct(x: t.x, y: t.y))
            }
            
            // Deinitialize
            array = nil
        }
    }
    
    
    class SampleClass {
        let value: Int
        let description: String
        
        init(value: Int) {
            self.value = value
            self.description = value.description
        }
    }
    
    func testPerformanceWithCustomClass() {
        let xs = (0..<500000).reduce(into: [Int]()) { (result, _) in
            result.append(Int(rand()))
        }
        var array: UnsafeArray<SampleClass>!
        
        self.measure {
            // Initialize
            array = UnsafeArray()
            
            // Insert
            for x in xs {
                array.append(SampleClass(value: x))
            }
            
            // Deinitialize
            array = nil
        }
    }
    
    func testPerformanceOfArrayWithCustomClass() {
        let xs = (0..<500000).reduce(into: [Int]()) { (result, _) in
            result.append(Int(rand()))
        }
        var array: Array<SampleClass>!
        
        self.measure {
            // Initialize
            array = Array()
            
            // Insert
            for x in xs {
                array.append(SampleClass(value: x))
            }
            
            // Deinitialize
            array = nil
        }
    }
}
