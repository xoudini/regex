# Project specification

The scope of the project is to construct a regular expression matcher, written in the [Swift](https://swift.org/) programming language.


### Data structures and algorithms

The given regular expression will be converted into a non-deterministic finite automaton (NFA), which in practice will be implemented as a directed graph. In order to accomodate optional, repeated, and nested expressions, a few different node types will be used in the graph.

A candidate for constructing the NFA is _Thompson's construction_ algorithm, but most likely a variation of the algorithm will be used in the end. The NFA will be traversed breadth-first, on a character-by-character basis, allowing matching to occur in linear time with regard to the input string. As such, a queue will be used during the matching phase for storing the following nodes.

Furthermore, some additional data structures (e.g. hash sets and hash tables) may be used in relation to various smaller tasks, such as metacharacter identification and character class expansion.


### Problem statement

The problem is simply constructing an intermediate representation for a regular expression, and then using this intermediate representation for the purpose of verifying whether an input string matches the pattern described by the regular expression.

For constructing the intermediate representation, _Thompson's construction_ will be used as inspiration for the approach. Hence, the intermediate representation will be an NFA. A deterministic finite automaton (DFA) could be constructed from the NFA, but this would unnecessarily bloat both the time and space complexities during the construction phase.

Breadth-first traversal was elected due to its linear time complexity with regard to the length of the input string, and for the fact that branches can be short-circuited immediately on failure. Another option would be to traverse the graph depth-first and use backtracking, but this would have a significant impact on efficiency for some cases.


### Program input

The program input will be a regular expression, the features of which will be specified later, as well as a string to match against. If time permits, a `grep`-style feature for matching lines in a file may be implemented.

In short, the regular expression will be transformed into an NFA, which consumes the given string on a character-by-character basis, and returns either a truthy or falsy value.


### Expected time and space complexities

|                  | Time     | Space      |
| ---------------- | -------- | ---------- |
| NFA construction | `O(k)`   | `O(m)`     |
| Input matching   | `O(emn)` | `O(n)`     |


Where:

- _k_ is the length of the regular expression
- _n_ is the length of the input string
- _e_ is the number of transitions in the NFA
- _m_ is the number of states in the NFA


In essence, the both the time complexity and the space complexity of the program will be linear to the size of the inputs.


### Sources

###### [_Regular Expression Matching Can Be Simple And Fast_](https://swtch.com/~rsc/regexp/regexp1.html), Russ Cox, January 2007.

###### [_Regular expression_](https://en.wikipedia.org/wiki/Regular_expression), Wikipedia.

###### [_Thompson's construction_](https://en.wikipedia.org/wiki/Thompson%27s_construction), Wikipedia.


