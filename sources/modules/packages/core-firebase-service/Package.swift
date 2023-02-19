// swift-tools-version: 5.7

import PackageDescription

let package = Package(
    name: "Core Firebase Service",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "CoreFirebaseService",
            type: .static,
            targets: [
                "CoreFirebaseService",
            ]
        )
    ],
    dependencies: [
        .package(
            url: "https://github.com/firebase/firebase-ios-sdk.git", from: "9.6.0"
        ),
        .package(path: "core-abstractions"),
    ],
    targets: [
        .target(
            name: "CoreFirebaseService",
            dependencies: [
                .product(name: "FirebaseAuth", package: "firebase-ios-sdk"),
                .product(name: "CoreAbstractions", package: "core-abstractions"),
            ],
            path: "Sources"
        ),
    ]
)
