# Implementation document

## Project structure

The project is structured in groups according to the usage of the containing files.

- [Collections](/Source/Collections) contains custom data structures.
- [Expression](/Source/Expression) contains protocols and types describing available subexpressions.
- [Parsing](/Source/Parsing) contains the logic for parsing the regular expression into a parse tree.
- [NFA](/Source/NFA) contains types pertaining to NFA construction and input matching.
- [Errors](/Source/Errors) contains custom exceptions.
- [Extensions](/Source/Extensions) contains extensions to core types.

Swift conventions in structuring and naming are used to a sensible extent.


## Program structure

The program in its current form uses a non-deterministic finite automaton (NFA) for matching an input string against a regular expression. The implemented syntax can be found in the [syntax sheet](SYNTAX.md).

The construction of the NFA occurs in two passes:
- During the first pass the given regular expression is converted into a parse tree. The parse tree consists of objects conforming to the `Expression` protocol, the types of which describe their behaviour.
- The second pass then converts the parse tree into an NFA, by recursively creating smaller automata from leaf nodes and combining them into larger automata until the root of the tree is reached.

Once the NFA has been constructed, it can be used for matching against an input string. The matching is done using a breadth-first search approach. This means that a standard queue is used for storing the next possible states, each of which are compared against the next character of input. If a state accepts a character, the states for the next character are evaluated from the accepting transitions.


## Complexity

### Expression parsing

The expression parsing uses minor backtracking in limited cases, otherwise passing over the regular expression string once. As such the time complexity of this operation is linear in relation to the length of the regular expression.

The operation constructs a parse tree with at most one node per character in the regular expression string, although in practice the number of nodes will often be smaller than the character count. The space complexity is therefore also linear.


### NFA construction

The NFA construction phase reads each node in the expression parse tree once, so the time complexity of this operation is also linear in relation to the length of the regular expression.

Since the NFA is built by converting expressions into sub-automata of limited size, the size of the NFA will be within a constant multiple of the size of the parse tree. The space complexity of the NFA is therefore also linear.


### Matching

> TODO


### Complexities

| Operation | Time   | Space  |
| --------- | ------ | ------ |
| Parsing   | `O(r)` | `O(r)` |
| NFA       | `O(r)` | `O(r)` |
| Matching  | `O(2^n)` | `O(r + n)` |

Where `r` is the length of the regular expression, and `n` is the length of the input.


## Comparison

The program will be compared against `grep` with extended syntax with normal, non-malicious regular expressions. The tested regular expressions will obviously be somewhat constrained, due to the more limited syntax and feature set of this implementation.

After some initial comparisons, I've found `grep` to be roughly 2-3 times faster than the program compiled with optimizations on a 3.5 GHz Intel i7-4771 processor. A more thorough comparison including test cases will be made available soon.


## Possible flaws and improvements

The matching logic is currently vulnerable to some malicious regular expressions. Commonly, these cause catastrophic backtracking, but in the case of this project the time consuming component is the expansion of states in the NFA.

Some of these malicious regular expressions can be avoided by following Thompson's algorithm more closely. Further improvements could possibly be made by reducing the constructed NFA into a minimal DFA.


## Sources

- [ReDoS][redos], Wikipedia
- [Regular Expression Matching Can Be Simple And Fast][cox], Russ Cox


[redos]: https://en.wikipedia.org/wiki/ReDoS
[cox]: https://swtch.com/~rsc/regexp/regexp1.html