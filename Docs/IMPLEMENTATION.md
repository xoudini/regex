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

Matching is performed using a queue-based breadth-first search approach. Using the NFA this can lead to some inefficiencies, since the amount of valid transitions for the next iteration can grow exponentially for each input character. An example of an expression causing this behavious is `(.+)+`. However, for non-malicious regular expressions, the matching is rather efficient even against large input.


### Complexities

The following table describes the upper bounds for each operation.

| Operation | Time   | Space  |
| --------- | ------ | ------ |
| Parsing   | `O(r)` | `O(r)` |
| NFA       | `O(r)` | `O(r)` |
| Matching  | `O(2^n)` | `O(2^n)` |

Where `r` is the length of the regular expression, and `n` is the length of the input.


## Comparison

The program has also been compared against `grep` using extended syntax with normal, non-malicious regular expressions. The tested regular expressions are obviously somewhat constrained, due to the slightly more limited syntax and feature set of this implementation. The comparisons have been performed on macOS 10.14.4 with a 3.5 GHz Intel i7-4771 processor.

After some initial comparisons, I've found `grep` to be roughly 3-15 times faster than the program compiled with optimizations, depending on a variety of factors. Since `rift` doesn't support partial matching, a regular expression covering entire lines must be given, which may contribute to the inefficiency.

A CSV-file with performance comparison between `rift` and `grep` can be found [here](performance.csv). As can be seen, in some cases the performance is nearly on par with grep (i.e. within an order of magnitude). However, the comparisons are somewhat different running in a container with Linux. In the container, `grep` fails on one input, and finishes in `0.00` seconds on the remaining inputs, which leads me to believe that the implementation is different.


## Possible flaws and improvements

The matching logic is currently vulnerable to some malicious regular expressions. Commonly, these cause catastrophic backtracking, but in the case of this project the time consuming component is the expansion of states in the NFA.

Some of these malicious regular expressions can be avoided by following Thompson's algorithm more closely. Further improvements could possibly be made by reducing the constructed NFA into a minimal DFA.


## Sources

- [ReDoS][redos], Wikipedia
- [Regular Expression Matching Can Be Simple And Fast][cox], Russ Cox


[redos]: https://en.wikipedia.org/wiki/ReDoS
[cox]: https://swtch.com/~rsc/regexp/regexp1.html