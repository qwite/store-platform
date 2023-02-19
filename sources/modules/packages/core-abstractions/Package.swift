// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Core Abstractions",
    products: [
        .library(
            name: "CoreAbstractions",
            targets: ["CoreAbstractions"]),
    ],
    targets: [
        .target(
            name: "CoreAbstractions",
            path: "Sources"
        ),
    ]
)
