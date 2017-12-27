// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftQ",
    products: [
        .library(name: "SwiftQ", targets: ["SwiftQ"]),
        ],
    dependencies: [
      .package(url: "https://github.com/vapor/redis.git", .branch("beta")),
      .package(url: "https://github.com/vapor/async.git", .branch("beta")),
    ],
    targets: [
        .target(name: "Dev", dependencies: ["SwiftQ"]),
        .target(name: "SwiftQ", dependencies: ["Redis", "Async"]),
        .testTarget(name: "SwiftQTests", dependencies: ["SwiftQ"])
    ]
)
