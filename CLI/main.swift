import Foundation
import Regex


let parser = Parser(with: "abc|123")

do {
    let expression = try parser.parse()
    
    let nfa = NFA(from: expression)
    
    print(nfa.matches("abc"))
    
} catch {
    print(error)
}
