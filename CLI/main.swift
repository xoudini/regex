import Foundation
import Regex

// MARK: File handles

let standardInput = FileHandle.standardInput
let standardOutput = FileHandle.standardOutput
let standardError = FileHandle.standardError


// MARK: Instructions

let usage = """
Usage:
 -h --help              Show this and exit.
 -r --regex <value>     The regular expression.
 -i --input <value>     An input string to match against. If the input matches,
                         it will be echoed. If an input is not given, input
                         will be read from standard input.
 -n --numbered          The lines will be numbered, starting from 1. Only used
                         on input from standard input.

Example usage for Swift Package Manager:
· Using the input flag:
    swift run rift -r '(ab|cd)+' -i 'ababcdab'

· Using piped input:
    cat Makefile | swift run rift -n -r '.*[Ll]inux.*'

· Using a here-string:
    swift run rift -n -r '.*a.*' <<< 'This is a here-string.'
"""

func writeUsage() {
    let output = Data(usage.appending("\n").utf8)
    standardOutput.write(output)
}


// MARK: Declarations

var regex: String?, input: String?
var numbered: Bool = false


// MARK: Argument parsing

ArgumentParser(
    Option(name: "help", short: "h") { _ in
        writeUsage()
        exit(2)
    },
    Option(name: "input", short: "i") { closure in
        input = closure()
    },
    Option(name: "regex", short: "r") { closure in
        regex = closure()
    },
    Option(name: "numbered", short: "n") { _ in
        numbered = true
    }
).parse(arguments: CommandLine.arguments)


// MARK: Main program

guard let regex = regex else {
    writeUsage()
    exit(2)
}

let parser = Parser(with: regex)

do {
    let expression = try parser.parse()
    let nfa = NFA(from: expression)

    // Match against an explicitly given input, if any.
    if let input = input {
        // Exit with 1 if the input doesn't match the regex.
        guard nfa.matches(input) else { exit(1) }
        let output = Data(input.appending("\n").utf8)
        standardOutput.write(output)
        exit(0)
    }
    
    var lineCount = 0
    
    // Read from standard input and match line by line.
    while let input = String(data: standardInput.availableData, encoding: .utf8), !input.isEmpty {
        input.enumerateLines { (line, stop) in lineCount += 1
            guard nfa.matches(line) else { return }
            
            // Format the line.
            let result: String = {
                guard numbered else { return line }
                return "\(lineCount):\(line)"
            }()
            
            // Output the result.
            let output = Data(result.appending("\n").utf8)
            standardOutput.write(output)
        }
    }

} catch {
    // Output the error and exit with -1 if an error occurred.
    let error = Data(error.localizedDescription.appending("\n").utf8)
    standardError.write(error)
    exit(-1)
}
