# Regex

A regular expression matcher built using Swift.


## Documentation

- [x] [Project specification](Docs/SPECIFICATION.md)
- [x] [Implementation document](Docs/IMPLEMENTATION.md) (WIP)
- [x] [Testing document](Docs/TESTING.md) (WIP)
- [ ] User guide


## Reports

- [x] [Week 1](Docs/Reports/1.md)
- [x] [Week 2](Docs/Reports/2.md)
- [x] [Week 3](Docs/Reports/3.md)
- [x] [Week 4](Docs/Reports/4.md)
- [x] [Week 5](Docs/Reports/5.md)
- [ ] Week 6


## Running the project

### macOS

The most straight-forward way is to simply install Xcode, but downloading the Swift distribution should be enough.

1. Install Xcode 10.2 from the App Store.
2. Open the workspace ([Regex.xcworkspace](Regex.xcworkspace)) in Xcode.
3. Select the scheme for the command-line application.
4. Tests can be run with the key combination **⌘ + U**. The program can be executed with the key combination **⌘ + R**, or by pressing the ▶ button.


### Linux

1. Install [Swift 5.0][swift], following the instructions under the title **[Linux][swift-help]**.
2. The tests and executable can the be run using the commands `swift test` and `swift run`, respectively.


### Docker

> For those who have Docker installed and don't feel like installing Swift.

1. Run `make container` in the root directory of the repository.
2. Once the container is up and running, the tests and executable can the be run using the commands `swift test` and `swift run`, respectively.



[swift]: https://swift.org/download/
[swift-help]: https://swift.org/download/#using-downloads
