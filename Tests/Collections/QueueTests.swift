//
//  QueueTests.swift
//

import XCTest
@testable import Regex

class QueueTests: XCTestCase {
    
    var queue: Queue<Int>!

    override func setUp() {
        self.queue = Queue()
    }

    override func tearDown() {
        self.queue = nil
    }
    
    func testDesignatedInitializer() {
        self.queue = Queue<Int>(from: [1, 2, 3])
        XCTAssertEqual(self.queue.count, 3)
        XCTAssertEqual(self.queue.dequeue(), 1)
    }
    
    func testLiteralAssignment() {
        self.queue = [1, 2, 3 ,4]
        XCTAssertEqual(self.queue.count, 4)
        XCTAssertEqual(self.queue.dequeue(), 1)
    }

    func testEnqueue() {
        self.queue.enqueue(5)
        XCTAssertEqual(self.queue.count, 1)
        XCTAssertEqual(self.queue.dequeue(), 5)
    }
    
    func testEnqueueWithMultipleEntries() {
        self.queue.enqueue(1)
        self.queue.enqueue(2)
        self.queue.enqueue(3)
        XCTAssertEqual(self.queue.count, 3)
    }
    
    func testDequeue() {
        self.queue.enqueue(5)
        XCTAssertEqual(self.queue.dequeue(), 5)
        XCTAssertEqual(self.queue.count, 0)
    }
    
    func testDequeueWithEmptyQueue() {
        XCTAssertNil(self.queue.dequeue())
    }
    
    func testDequeueWithMultipleEntries() {
        self.queue = [1, 2, 3]
        XCTAssertEqual(self.queue.count, 3)
        XCTAssertEqual(self.queue.dequeue(), 1)
        XCTAssertEqual(self.queue.count, 2)
        XCTAssertEqual(self.queue.dequeue(), 2)
        XCTAssertEqual(self.queue.count, 1)
        XCTAssertEqual(self.queue.dequeue(), 3)
        XCTAssertEqual(self.queue.count, 0)
    }
    
    func testSubscript() {
        self.queue = [1, 2, 3, 4]
        XCTAssertEqual(self.queue[0], 1)
        XCTAssertEqual(self.queue[3], 4)
    }
    
    func testForInIteration() {
        self.queue = [1, 2, 3]
        let copy = Queue<Int>()
        
        for element in self.queue {
            copy.enqueue(element)
        }
        
        XCTAssertEqual(copy.dequeue(), 1)
        XCTAssertEqual(copy.dequeue(), 2)
        XCTAssertEqual(copy.dequeue(), 3)
        XCTAssertNil(copy.dequeue())
    }

}
