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


## Complexity

> TODO


## Comparison

> TODO


## Possible flaws and improvements

The matching logic is currently vulnerable to some malicious regular expressions. Commonly, these cause catastrophic backtracking, but in the case of this project the time consuming component is the expansion of states in the NFA.

Some of these malicious regular expressions can be avoided by following Thompson's algorithm more closely. Further improvements could possibly be made by reducing the constructed NFA into a minimal DFA.


## Sources

- [ReDoS][redos], Wikipedia
- [Regular Expression Matching Can Be Simple And Fast][cox], Russ Cox


[redos]: https://en.wikipedia.org/wiki/ReDoS
[cox]: https://swtch.com/~rsc/regexp/regexp1.html