# Testing document

## Scope of testing

Tests have been implemented as unit and integration tests using the [XCTest library][xctest] included in Swift. Custom data structures have been tested with unit tests, as have the main logic for expression parsing and NFA construction. Integration tests have this far been implemented mainly in conjunction with the tests for expression parsing and NFA construction.

Some cases have been tested for performance using `measure`-blocks. The purpose of these tests are to measure the performance of the parsing stage, and more importantly the input matching. Currently only common [ReDoS][redos] have been tested, but the intention is to add more regular cases as well in the near future.


## Inputs

> TODO


## Running the tests

Currently the tests are implemented as an independent macOS test target. This means that the following tools are required in order to run the tests in their current form:

- macOS 10.14.4
- Xcode 10.2
- Swift 5.0


### macOS

Assuming the aforementioned requirements are met, the tests can be run in Xcode with the key combination ⌘ + U.


### Linux

Running the tests on a Linux machine is possible, but requires some effort. Firstly, [Swift 5.0 needs to be installed][swift]. The release includes [Swift Package Manager][spm], which will be used for the `Package.swift` manifest file. The manifest file must be written to include a test target, with a dependency to all files in the [Source][src] directory excluding `main.swift`, as well as the test files in the [Tests][test] directory. After this the tests should be runnable using the commands `swift build` followed by `swift test` in the directory containing the `Package.swift` file.

Some additional tweaks may be required, including modifying each test class slightly. If time permits, the entire project will be made compatible with Ubuntu 18.04.


## Test results

> TODO


[xctest]: https://github.com/apple/swift-corelibs-xctest
[redos]: https://en.wikipedia.org/wiki/ReDoS
[swift]: https://swift.org/download/
[spm]: https://swift.org/package-manager/
[src]: /Source
[test]: /Tests
