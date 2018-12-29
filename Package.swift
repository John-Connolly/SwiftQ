// swift-tools-version:4.0

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
        .target(name: "Dev", dependencies: ["SwiftQ"]),
        .target(name: "SwiftQ", dependencies: ["NIO"]),
        .testTarget(name: "SwiftQTests", dependencies: ["SwiftQ"])
    ]
)
