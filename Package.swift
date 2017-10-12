// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftQ",
    products: [
        .library(name: "SwiftQ",
                 targets: ["SwiftQ"]),
        ],
    dependencies: [
        .package(url: "https://github.com/vapor/redis.git", from: "2.1.0")
    ],
    targets: [
        .target(name: "SwiftQ",
                dependencies: ["Redis"]),
        .testTarget(name: "SwiftQTests",
                    dependencies: ["SwiftQ"])
    ]
)
