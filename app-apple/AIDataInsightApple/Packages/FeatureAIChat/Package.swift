// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FeatureAIChat",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatureAIChat", targets: ["FeatureAIChat"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../AppDesignSystem"),
    ],
    targets: [
        .target(name: "FeatureAIChat", dependencies: ["AppCore", "AppDesignSystem"]),
        .testTarget(name: "FeatureAIChatTests", dependencies: ["FeatureAIChat"]),
    ]
)
