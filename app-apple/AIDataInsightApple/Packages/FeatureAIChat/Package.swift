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
        .package(path: "../AppContracts"),
        .package(path: "../AppCore"),
        .package(path: "../AppDesignSystem"),
        .package(path: "../AppNetworking"),
    ],
    targets: [
        .target(name: "FeatureAIChat", dependencies: ["AppContracts", "AppCore", "AppDesignSystem", "AppNetworking"]),
        .testTarget(name: "FeatureAIChatTests", dependencies: ["FeatureAIChat"]),
    ]
)
