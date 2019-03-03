// swift-tools-version:5.0
// The swift-tools-version declares the minimum version of Swift required to build this package.

import PackageDescription

let package = Package(
    name: "Bariloche",
    products: [
        .library(
            name: "Bariloche",
            targets: ["Bariloche"]),
    ],
    dependencies: [
        .package(url: "https://github.com/onevcat/Rainbow", from: "3.0.0")
    ],
    targets: [
        .target(
            name: "Bariloche",
            dependencies: ["Rainbow"]),
        .target(
            name: "BarilocheExample",
            dependencies: ["Bariloche"]),
        .testTarget(
            name: "BarilocheTests",
            dependencies: ["Bariloche"]),
    ],
    swiftLanguageVersions: [.v4_2, .v5]
)
