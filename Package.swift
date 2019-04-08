// swift-tools-version:5.0

import PackageDescription

let package = Package(
    name: "Regex",
    products: [
        .library(name: "Regex", targets: ["Regex"]),
    ],
    targets: [
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
