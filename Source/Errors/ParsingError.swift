//
//  ParsingError.swift
//

import Foundation

/// Error type for parsing related errors.
///
enum ParsingError: Error {
    case emptyExpression
    case invalidSymbol
    case invalidEndState
    case unterminatedState
}
