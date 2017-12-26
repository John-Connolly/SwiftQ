// swift-tools-version:4.0

import PackageDescription

let package = Package(
    name: "SwiftQ",
    products: [
        .library(name: "SwiftQ", targets: ["SwiftQ"]),
        ],
    dependencies: [
      .package(url: "https://github.com/IBM-Swift/Kitura-redis.git", .exact("2.0.0")),
      .package(url: "https://github.com/vapor/redis.git", .branch("beta")),
      .package(url: "https://github.com/vapor/async.git", .branch("beta")),
//       .package(url: "https://github.com/vapor/vapor.git", .exact("3.0.0-alpha.x"))
    ],
    targets: [
        .target(name: "Dev", dependencies: ["SwiftQ"]),
        .target(name: "SwiftQ", dependencies: ["Redis","SwiftRedis", "Async"]),

        .testTarget(name: "SwiftQTests", dependencies: ["SwiftQ"])
    ]
)
