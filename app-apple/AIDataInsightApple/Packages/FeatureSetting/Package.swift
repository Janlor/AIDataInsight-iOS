// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FeatureSetting",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatureSetting", targets: ["FeatureSetting"]),
    ],
    dependencies: [
        .package(path: "../AppAccount"),
        .package(path: "../AppContracts"),
        .package(path: "../AppCore"),
        .package(path: "../AppDesignSystem"),
    ],
    targets: [
        .target(name: "FeatureSetting", dependencies: ["AppAccount", "AppContracts", "AppCore", "AppDesignSystem"]),
        .testTarget(name: "FeatureSettingTests", dependencies: ["FeatureSetting"]),
    ]
)
