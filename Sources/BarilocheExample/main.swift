import Bariloche

func parseExample(command: Command) -> [Command] {
    let parser = Bariloche(command: command)
    return parser.parse()
}

let result = parseExample(command: CocoaPodsCommand())
// let result = parseExample(command: CatCommand())
// let result = parseExample(command: SampleCommand())
