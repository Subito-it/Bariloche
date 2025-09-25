import XCTest
@testable import Bariloche

final class CommandUtilitiesTests: XCTestCase {
    func testCommandReflectionCollectsArgumentsFlagsAndSubcommands() {
        let command = CompositeCommand()
        let arrayChild = command.childCommands.first

        let flags = command.validFlags()
        XCTAssertTrue(flags.contains(command.flagVerbose))
        XCTAssertTrue(flags.contains(command.flagQuiet))
        XCTAssertTrue(flags.contains(Flag.help))

        let arguments = command.validArguments()
        XCTAssertTrue(arguments.contains(where: { $0 === command.namedArgument }))
        XCTAssertTrue(arguments.contains(where: { $0 === command.optionalArgument }))
        XCTAssertTrue(arguments.contains(where: { $0 === command.variadicArgument }))

        let subs = command.subcommands()
        XCTAssertTrue(subs.contains(where: { $0 === command.child }))
        if let arrayChild = arrayChild {
            XCTAssertTrue(subs.contains(where: { $0 === arrayChild }))
        } else {
            XCTFail("Expected composite command to expose nested command from array")
        }
    }

    func testArgumentValueConversionForScalarsAndCollections() {
        let stringArgument = Argument<String>(name: "name", kind: .named(short: nil, long: "name"), optional: false)
        stringArgument.appendStringValue("alice")
        XCTAssertEqual(stringArgument.value, "alice")

        let boolArgument = Argument<Bool>(name: "flag", kind: .named(short: nil, long: "flag"), optional: false)
        boolArgument.appendStringValue("true")
        XCTAssertEqual(boolArgument.value, true)

        let intArrayArgument = Argument<[Int]>(name: "count", kind: .named(short: nil, long: "count"), optional: false)
        intArrayArgument.appendStringValue("1")
        intArrayArgument.appendStringValue("2")
        intArrayArgument.appendStringValue("3")
        XCTAssertEqual(intArrayArgument.value ?? [], [1, 2, 3])
    }

    func testFlagEqualityHelpers() {
        let flag = Flag(short: "v", long: "verbose", help: "Verbose output")

        XCTAssertEqual(flag, Flag(short: "v", long: "verbose", help: "Verbose output"))
        XCTAssertNotEqual(flag, Flag(short: "q", long: "quiet", help: "Quiet"))
        XCTAssertTrue(flag == "-v")
        XCTAssertTrue(flag == "--verbose")
        XCTAssertTrue(["-v"].contains(flag))
        XCTAssertFalse(["-q"].contains(flag))
    }

    func testUsagePrinterOutputsUsageCommandsAndOptions() {
        let command = UsageRootCommand()
        let streamer = RecordingStreamer()

        let printer = UsagePrinter(printer: streamer)
        printer.output(executableName: "tool", commands: [command], error: nil)

        let output = streamer.combinedOutputStrippingANSI()

        XCTAssertTrue(output.contains("Usage:"), "Output did not contain usage heading: \(output)")
        XCTAssertTrue(output.contains("$ tool root COMMAND"), "Output did not contain command invocation: \(output)")
        XCTAssertTrue(output.contains("Commands:"), "Output did not contain commands heading: \(output)")
        XCTAssertTrue(output.contains("+ child"), "Output did not list child command: \(output)")
        XCTAssertTrue(output.contains("Options:"), "Output did not contain options heading: \(output)")
        XCTAssertTrue(output.contains("--path"), "Output did not list path argument: \(output)")
        XCTAssertTrue(output.contains("--mode"), "Output did not list mode argument: \(output)")
        XCTAssertTrue(output.contains("FILE"), "Output did not list positional argument: \(output)")
        XCTAssertTrue(output.contains("[items ...]"), "Output did not list variadic argument: \(output)")
        XCTAssertTrue(output.contains("-h, --help"), "Output did not include help flag: \(output)")
    }
}

private final class CompositeCommand: Command {
    let child = SimpleCommand(name: "child")
    let childCommands = [SimpleCommand(name: "child-array")]

    let flagVerbose = Flag(short: "v", long: "verbose", help: "Verbose output")
    let flagQuiet = Flag(short: "q", long: "quiet", help: "Quiet output")

    let namedArgument = Argument<String>(name: "path", kind: .named(short: nil, long: "path"), optional: false)
    let optionalArgument = Argument<String>(name: "mode", kind: .named(short: "m", long: "mode"), optional: true)
    let variadicArgument = Argument<[String]>(name: "items", kind: .variadic, optional: true)

    var name: String? { "root" }
    var help: String? { "Composite command" }

    func run() -> Bool { true }
}

private final class SimpleCommand: Command {
    let commandName: String

    init(name: String) {
        self.commandName = name
    }

    var name: String? { commandName }
    var help: String? { "Help for \(commandName)" }

    func run() -> Bool { true }
}

private final class UsageRootCommand: Command {
    let child = SimpleCommand(name: "child")

    let pathArgument = Argument<String>(name: "path", kind: .named(short: nil, long: "path"), optional: false, help: "Project path")
    let modeArgument = Argument<String>(name: "mode", kind: .named(short: "m", long: "mode"), optional: true, help: "Build mode")
    let positionalArgument = Argument<String>(name: "FILE", kind: .positional, optional: false, help: "File to process")
    let itemsArgument = Argument<[String]>(name: "items", kind: .variadic, optional: true, help: "Items to include")

    let verboseFlag = Flag(short: "v", long: "verbose", help: "Increase verbosity")

    var name: String? { "root" }
    var help: String? { "Root command overview" }
    var usage: String? {
        "Run `--path` to specify the `path`\nProvide optional `items` to extend processing."
    }

    func run() -> Bool { true }
}

private final class RecordingStreamer: OutputStreamer {
    private(set) var messages: [String] = []

    func print(_ text: String) {
        messages.append(text)
    }

    func combinedOutputStrippingANSI() -> String {
        let combined = messages.joined(separator: "\n")
        return combined.strippingANSISequences()
    }
}

private extension String {
    func strippingANSISequences() -> String {
        return replacingOccurrences(of: "\u{001B}\\[[0-9;]*m", with: "", options: .regularExpression)
    }
}

#if !os(macOS)
extension CommandUtilitiesTests {
    static let allTests = [
        ("testCommandReflectionCollectsArgumentsFlagsAndSubcommands", testCommandReflectionCollectsArgumentsFlagsAndSubcommands),
        ("testArgumentValueConversionForScalarsAndCollections", testArgumentValueConversionForScalarsAndCollections),
        ("testFlagEqualityHelpers", testFlagEqualityHelpers),
        ("testUsagePrinterOutputsUsageCommandsAndOptions", testUsagePrinterOutputsUsageCommandsAndOptions)
    ]
}
#endif
