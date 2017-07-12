// swift-tools-version:3.1

import PackageDescription

let package = Package(
    name: "SwiftQ",
    dependencies: [
        .Package(url: "https://github.com/vapor/redis-provider.git", majorVersion: 2)
        
    ]
)
