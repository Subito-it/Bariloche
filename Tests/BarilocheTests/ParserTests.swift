import XCTest
@testable import Bariloche

final class ParserTests: XCTestCase {
    func testNamedArgumentSingleValue() {
        let command = SingleStringArgumentCommand()
        let parser = Parser(root: command)

        let result = parser.parse(arguments: ["--value", "hello"])
        guard case .success = result else {
            return XCTFail("Expected parsing success, got \(result)")
        }

        XCTAssertEqual(command.argument.value, "hello")
    }

    func testArrayArgumentSingleOccurrenceProducesSingleElement() {
        let command = ArrayStringArgumentCommand()
        let parser = Parser(root: command)

        let result = parser.parse(arguments: ["--names", "arya"])
        guard case .success = result else {
            return XCTFail("Expected parsing success, got \(result)")
        }

        XCTAssertEqual(command.argument.value ?? [], ["arya"])
    }

    func testArrayArgumentMultipleOccurrencesProducesAllElements() {
        let command = ArrayStringArgumentCommand()
        let parser = Parser(root: command)

        let result = parser.parse(arguments: ["--names", "arya", "--names", "sansa", "--names", "bran"])
        guard case .success = result else {
            return XCTFail("Expected parsing success, got \(result)")
        }

        XCTAssertEqual(command.argument.value ?? [], ["arya", "sansa", "bran"])
    }

    func testArrayArgumentCastsToIntegers() {
        let command = ArrayIntArgumentCommand()
        let parser = Parser(root: command)

        let result = parser.parse(arguments: ["--count", "1", "--count", "2", "--count", "3"])
        guard case .success = result else {
            return XCTFail("Expected parsing success, got \(result)")
        }

        XCTAssertEqual(command.argument.value ?? [], [1, 2, 3])
    }

    func testVariadicArgumentAccumulatesValues() {
        let command = VariadicArgumentCommand()
        let parser = Parser(root: command)

        let result = parser.parse(arguments: ["alpha", "beta", "gamma"])
        guard case .success = result else {
            return XCTFail("Expected parsing success, got \(result)")
        }

        XCTAssertEqual(command.argument.value ?? [], ["alpha", "beta", "gamma"])
    }

    func testStackedShortFlagsAreExpanded() {
        let command = StackedFlagsCommand()
        let parser = Parser(root: command)

        let result = parser.parse(arguments: ["-ab"])
        guard case .success = result else {
            return XCTFail("Expected parsing success, got \(result)")
        }

        XCTAssertTrue(command.flagA.value)
        XCTAssertTrue(command.flagB.value)
    }

    func testEqualSeparatedNamedArgumentsAreParsed() {
        let command = EqualSeparatedArgumentCommand()
        let parser = Parser(root: command)

        let result = parser.parse(arguments: ["--path=/tmp/project"])
        guard case .success = result else {
            return XCTFail("Expected parsing success, got \(result)")
        }

        XCTAssertEqual(command.argument.value, "/tmp/project")
    }

    func testMissingRequiredArgumentReturnsUsageWithError() {
        let command = SingleStringArgumentCommand()
        let parser = Parser(root: command)

        guard case .showUsage(_, let error) = parser.parse(arguments: []) else {
            return XCTFail("Expected showUsage result when argument is missing")
        }

        guard case .missingArgument(let missing)? = error else {
            return XCTFail("Expected missing argument error, got \(String(describing: error))")
        }

        XCTAssertEqual(missing.count, 1)
        XCTAssertEqual(missing.first?.name, "value")
    }
}

private final class SingleStringArgumentCommand: Command {
    let argument = Argument<String>(name: "value", kind: .named(short: nil, long: "value"), optional: false)

    func run() -> Bool { true }
}

private final class ArrayStringArgumentCommand: Command {
    let argument = Argument<[String]>(name: "names", kind: .named(short: nil, long: "names"), optional: false)

    func run() -> Bool { true }
}

private final class ArrayIntArgumentCommand: Command {
    let argument = Argument<[Int]>(name: "count", kind: .named(short: nil, long: "count"), optional: false)

    func run() -> Bool { true }
}

private final class VariadicArgumentCommand: Command {
    let argument = Argument<[String]>(name: "letters", kind: .variadic, optional: true)

    func run() -> Bool { true }
}

private final class StackedFlagsCommand: Command {
    let flagA = Flag(short: "a", long: nil, help: nil)
    let flagB = Flag(short: "b", long: nil, help: nil)

    func run() -> Bool { true }
}

private final class EqualSeparatedArgumentCommand: Command {
    let argument = Argument<String>(name: "path", kind: .named(short: nil, long: "path"), optional: false)

    func run() -> Bool { true }
}

#if !os(macOS)
extension ParserTests {
    static let allTests = [
        ("testNamedArgumentSingleValue", testNamedArgumentSingleValue),
        ("testArrayArgumentSingleOccurrenceProducesSingleElement", testArrayArgumentSingleOccurrenceProducesSingleElement),
        ("testArrayArgumentMultipleOccurrencesProducesAllElements", testArrayArgumentMultipleOccurrencesProducesAllElements),
        ("testArrayArgumentCastsToIntegers", testArrayArgumentCastsToIntegers),
        ("testVariadicArgumentAccumulatesValues", testVariadicArgumentAccumulatesValues),
        ("testStackedShortFlagsAreExpanded", testStackedShortFlagsAreExpanded),
        ("testEqualSeparatedNamedArgumentsAreParsed", testEqualSeparatedNamedArgumentsAreParsed),
        ("testMissingRequiredArgumentReturnsUsageWithError", testMissingRequiredArgumentReturnsUsageWithError)
    ]
}
#endif
