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
        .package(path: "../AppContracts"),
        .package(path: "../AppCore"),
        .package(path: "../AppDesignSystem"),
        .package(path: "../AppNetworking"),
    ],
    targets: [
        .target(name: "FeatureHistory", dependencies: ["AppContracts", "AppCore", "AppDesignSystem", "AppNetworking"]),
        .testTarget(name: "FeatureHistoryTests", dependencies: ["FeatureHistory"]),
    ]
)
