//
//  OutputStreamer.swift
//  Bariloche
//
//  Created by Tomas Camin on 18/12/2018.
//

protocol OutputStreamer {
    func print(_ text: String)
}

struct DefaultOutputStreamer: OutputStreamer {
    func print(_ text: String) {
        Swift.print(text)
    }
}
