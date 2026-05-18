// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FeatureHistory",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatureHistory", targets: ["FeatureHistory"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../AppDesignSystem"),
    ],
    targets: [
        .target(name: "FeatureHistory", dependencies: ["AppCore", "AppDesignSystem"]),
        .testTarget(name: "FeatureHistoryTests", dependencies: ["FeatureHistory"]),
    ]
)
