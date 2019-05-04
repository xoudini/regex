#if !canImport(ObjectiveC)
import XCTest

extension HashSetTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__HashSetTests = [
        ("testContains", testContains),
        ("testConvenienceInitializer", testConvenienceInitializer),
        ("testInsertingDuplicates", testInsertingDuplicates),
        ("testInsertWithDefaultBufferSize", testInsertWithDefaultBufferSize),
        ("testInsertWithFewElements", testInsertWithFewElements),
        ("testInsertWithManyElements", testInsertWithManyElements),
        ("testIteration", testIteration),
    ]
}

extension NFATests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__NFATests = [
        ("testAnyCharacterExpression", testAnyCharacterExpression),
        ("testAnyCharacterNFA", testAnyCharacterNFA),
        ("testCharacterSetExpression", testCharacterSetExpression),
        ("testCharacterSetNFA", testCharacterSetNFA),
        ("testComplexExpression1", testComplexExpression1),
        ("testComplexExpression2", testComplexExpression2),
        ("testComplexExpression3", testComplexExpression3),
        ("testConcatenatedCharacterSetNFA", testConcatenatedCharacterSetNFA),
        ("testConcatenatedNFA", testConcatenatedNFA),
        ("testConcatenatedSingleCharacterNFA", testConcatenatedSingleCharacterNFA),
        ("testDCharacterClassExpression", testDCharacterClassExpression),
        ("testEmptyNFA", testEmptyNFA),
        ("testKleeneStarExpression", testKleeneStarExpression),
        ("testLargeUnionNFA", testLargeUnionNFA),
        ("testLongConcatenatedNFA", testLongConcatenatedNFA),
        ("testNegatedChoiceExpression", testNegatedChoiceExpression),
        ("testNegatedDCharacterClassExpression", testNegatedDCharacterClassExpression),
        ("testNegatedSCharacterClassExpression", testNegatedSCharacterClassExpression),
        ("testNegatedWCharacterClassExpression", testNegatedWCharacterClassExpression),
        ("testOptionalExpression", testOptionalExpression),
        ("testPlusExpression", testPlusExpression),
        ("testReDoSExpression1", testReDoSExpression1),
        ("testReDoSExpression2", testReDoSExpression2),
        ("testReDoSExpression3", testReDoSExpression3),
        ("testSCharacterClassExpression", testSCharacterClassExpression),
        ("testSimpleExpression", testSimpleExpression),
        ("testSingleCharacterNFA", testSingleCharacterNFA),
        ("testUnionAndConcatenationCombined", testUnionAndConcatenationCombined),
        ("testUnionExpression", testUnionExpression),
        ("testUnionNFA", testUnionNFA),
        ("testWCharacterClassExpression", testWCharacterClassExpression),
    ]
}

extension ParserTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__ParserTests = [
        ("testAnyCharacterExpression", testAnyCharacterExpression),
        ("testCharacterExpression", testCharacterExpression),
        ("testChoiceExpression", testChoiceExpression),
        ("testConcatenatedExpression", testConcatenatedExpression),
        ("testEmptyExpression", testEmptyExpression),
        ("testEscapedCharacter", testEscapedCharacter),
        ("testEscapedCharacterInChoiceContext", testEscapedCharacterInChoiceContext),
        ("testNegatedExpressionInChoiceContext", testNegatedExpressionInChoiceContext),
        ("testOptionalExpression", testOptionalExpression),
        ("testRepeatedExpression", testRepeatedExpression),
        ("testRepeatedPlusOneExpression", testRepeatedPlusOneExpression),
        ("testUnionExpression", testUnionExpression),
    ]
}

extension QueueTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__QueueTests = [
        ("testDequeue", testDequeue),
        ("testDequeueWithEmptyQueue", testDequeueWithEmptyQueue),
        ("testDequeueWithMultipleEntries", testDequeueWithMultipleEntries),
        ("testDesignatedInitializer", testDesignatedInitializer),
        ("testEnqueue", testEnqueue),
        ("testEnqueueWithMultipleEntries", testEnqueueWithMultipleEntries),
        ("testForInIteration", testForInIteration),
        ("testLiteralAssignment", testLiteralAssignment),
        ("testSubscript", testSubscript),
    ]
}

extension RegexTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__RegexTests = [
        ("testCommonExpression1", testCommonExpression1),
    ]
}

extension StackTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__StackTests = [
        ("testConvenienceAccessors", testConvenienceAccessors),
        ("testConvenienceAccessorsWhenEmpty", testConvenienceAccessorsWhenEmpty),
        ("testDesignatedInitializer", testDesignatedInitializer),
        ("testForInIteration", testForInIteration),
        ("testLiteralAssignment", testLiteralAssignment),
        ("testPop", testPop),
        ("testPopWithEmptyStack", testPopWithEmptyStack),
        ("testPopWithMultipleEntries", testPopWithMultipleEntries),
        ("testPush", testPush),
        ("testPushWithMultipleEntries", testPushWithMultipleEntries),
        ("testSubscript", testSubscript),
    ]
}

extension UnsafeArrayTests {
    // DO NOT MODIFY: This is autogenerated, use:
    //   `swift test --generate-linuxmain`
    // to regenerate.
    static let __allTests__UnsafeArrayTests = [
        ("testAppend", testAppend),
        ("testAppendFromArray", testAppendFromArray),
        ("testArrayInitializer", testArrayInitializer),
        ("testAssigningInsert", testAssigningInsert),
        ("testBoundsWithEmptyArray", testBoundsWithEmptyArray),
        ("testCompactMap", testCompactMap),
        ("testContains", testContains),
        ("testCopying", testCopying),
        ("testDeallocation", testDeallocation),
        ("testFilter", testFilter),
        ("testFirst", testFirst),
        ("testFirstElement", testFirstElement),
        ("testFirstForNonexistingElement", testFirstForNonexistingElement),
        ("testFlatMap", testFlatMap),
        ("testInitializingInsert", testInitializingInsert),
        ("testIsEmpty", testIsEmpty),
        ("testLargeAppend", testLargeAppend),
        ("testLastElement", testLastElement),
        ("testLiteralAssignment", testLiteralAssignment),
        ("testMap", testMap),
        ("testPerformanceOfArrayWithBuiltinTypes", testPerformanceOfArrayWithBuiltinTypes),
        ("testPerformanceOfArrayWithCustomClass", testPerformanceOfArrayWithCustomClass),
        ("testPerformanceOfArrayWithCustomStruct", testPerformanceOfArrayWithCustomStruct),
        ("testPerformanceWithBuiltinTypes", testPerformanceWithBuiltinTypes),
        ("testPerformanceWithCustomClass", testPerformanceWithCustomClass),
        ("testPerformanceWithCustomStruct", testPerformanceWithCustomStruct),
        ("testReallocatingInsert", testReallocatingInsert),
        ("testReduceWithAccumulatingResult", testReduceWithAccumulatingResult),
        ("testReduceWithInitialResult", testReduceWithInitialResult),
        ("testSliceCopying", testSliceCopying),
        ("testUnpackingWithEmptyArray", testUnpackingWithEmptyArray),
        ("testUnpackingWithMultipleElements", testUnpackingWithMultipleElements),
        ("testUnpackingWithOneElement", testUnpackingWithOneElement),
        ("testUnpackingWithReferenceTypes", testUnpackingWithReferenceTypes),
    ]
}

public func __allTests() -> [XCTestCaseEntry] {
    return [
        testCase(HashSetTests.__allTests__HashSetTests),
        testCase(NFATests.__allTests__NFATests),
        testCase(ParserTests.__allTests__ParserTests),
        testCase(QueueTests.__allTests__QueueTests),
        testCase(RegexTests.__allTests__RegexTests),
        testCase(StackTests.__allTests__StackTests),
        testCase(UnsafeArrayTests.__allTests__UnsafeArrayTests),
    ]
}
#endif
