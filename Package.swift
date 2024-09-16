// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "pg-perf-regression",
    platforms: [.macOS(.v14)],
    dependencies: [
        .package(url: "https://github.com/vapor/postgres-nio.git", from: "1.22.1")
    ],
    targets: [
        .executableTarget(name: "pg-perf-regression", dependencies: [
            .product(name: "PostgresNIO", package: "postgres-nio")
        ]),
        .testTarget(name: "PerfTest", dependencies: [
            .product(name: "PostgresNIO", package: "postgres-nio")
        ])
    ]
)
