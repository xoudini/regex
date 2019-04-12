import Foundation
import Regex

let usage = [
    "Usage:",
    " -h --help             Show this and exit.",
    " -r --regex <value>    The regular expression.",
    " -i --input <value>    An input string to match against. If the input",
    "                         matches, it will be echoed.",
    "",
    "Example usage for Swift Package Manager:",
    "  swift run rift -r '(ab|cd)+' -i 'ababcdab'",
].joined(separator: "\n")

var regex: String?, input: String?

ArgumentParser(
    Option(name: "help", short: "h") { _ in
        print(usage)
        exit(0)
    },
    Option(name: "input", short: "i") { closure in
        input = closure()
    },
    Option(name: "regex", short: "r") { closure in
        regex = closure()
    }
).parse(arguments: CommandLine.arguments)

guard
    let regex = regex,
    let input = input
else {
    print(usage)
    exit(1)
}

let parser = Parser(with: regex)

do {
    let expression = try parser.parse()
    let nfa = NFA(from: expression)

    // Exit with 1 if the input doesn't match the regex.
    guard nfa.matches(input) else { exit(1) }
    
    print(input)

} catch {
    print(error)
    exit(1)
}
