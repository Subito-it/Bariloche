//
//  CatCommand.swift
//  BarilocheExample
//
//  Created by Francesco Bigagnoli on 19/12/2018.
//

import Foundation
import Bariloche

class CatCommand: Command {
    let usage: String? = "The cat utility reads files sequentially, writing them to the standard output.  The file operands are processed in command-line order.  If `file` is a single `--num` dash (`-') or absent, cat reads from the standard input.  If file is a UNIX domain socket, cat connects to it and then reads it until EOF.  This complements the UNIX domain binding capability available in inetd(8)."
    let verboseFlag = Flag(short: "v", long: "verbose", help: "Display non-printing characters so they are visible.  Control characters print as `^X' for control-X; the delete character (octal 0177) prints as `^?'.  Non-ASCII characters (with the high bit set) are printed as `M-' (for meta) followed by the character for the low 7 bits.")
    let fileArgument = Argument<String>(name: "file", kind: .positional, optional: false, autocomplete: .files(nil))
    let fileArgument2 = Argument<URL>(name: "file2", kind: .named(short: nil, long: "num"), optional: true, autocomplete: .files(nil))
    let flag = Flag(short: nil, long: "prova", help: "questo è un help")
        
    func run() -> Bool {
        guard let value = fileArgument.value else { return false }
        
        print("Running with argument \(value)")
        return true
    }
}
