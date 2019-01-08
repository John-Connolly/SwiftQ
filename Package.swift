// swift-tools-version:4.2

import PackageDescription

let package = Package(
    name: "SwiftQ",
    products: [
        .library(name: "SwiftQ", targets: ["SwiftQ"]),
        ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-nio.git", .exact("1.8.0")),

    ],
    targets: [
        .target(name: "SwiftQDev", dependencies: ["SwiftQ"]),
        .target(name: "SwiftQ", dependencies: ["NIO"]),
        .testTarget(name: "SwiftQTests", dependencies: ["SwiftQ"])
    ]
)
