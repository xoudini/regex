//
//  UnsafeArrayTests.swift
//

import XCTest

@testable import Regex

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

    // MARK: -
    
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
            let tuple = (Int(arc4random()), Int(arc4random()))
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
            let tuple = (Int(arc4random()), Int(arc4random()))
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
            result.append(Int(arc4random()))
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
            result.append(Int(arc4random()))
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
