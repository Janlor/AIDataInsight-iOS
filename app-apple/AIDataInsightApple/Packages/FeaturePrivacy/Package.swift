// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FeaturePrivacy",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeaturePrivacy", targets: ["FeaturePrivacy"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../AppDesignSystem"),
    ],
    targets: [
        .target(name: "FeaturePrivacy", dependencies: ["AppCore", "AppDesignSystem"]),
        .testTarget(name: "FeaturePrivacyTests", dependencies: ["FeaturePrivacy"]),
    ]
)
