// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Regex",
    products: [
        .executable(name: "rift", targets: ["Rift"]),
        .library(name: "Regex", targets: ["Regex"]),
    ],
    targets: [
        .target(
            name: "Rift",
            dependencies: ["Regex"],
            path: "CLI"
        ),
        .target(
            name: "Regex",
            path: "Source",
            exclude: ["main.swift"]
        ),
        .testTarget(
            name: "RegexTests",
            dependencies: ["Regex"],
            path: "Tests"
        ),
    ]
)
