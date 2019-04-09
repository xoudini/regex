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

Assuming the aforementioned requirements are met, the tests can be run in Xcode with the key combination **⌘ + U**.

### Linux

Install [Swift 5.0][swift]. The release includes [Swift Package Manager][spm], which is required for the `Package.swift` manifest file. The tests should then be runnable using the command `swift test` in the directory containing the `Package.swift` file.

### Docker

Start the container using the command `make container` in the directory containing the Makefile. Once the container is up and running, the use the command `swift test` to run the tests.


## Test results

> TODO


[xctest]: https://github.com/apple/swift-corelibs-xctest
[redos]: https://en.wikipedia.org/wiki/ReDoS
[swift]: https://swift.org/download/
[spm]: https://swift.org/package-manager/
