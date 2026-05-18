// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "FeatureLogin",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "FeatureLogin", targets: ["FeatureLogin"]),
    ],
    dependencies: [
        .package(path: "../AppAccount"),
        .package(path: "../AppCore"),
        .package(path: "../AppDesignSystem"),
    ],
    targets: [
        .target(name: "FeatureLogin", dependencies: ["AppAccount", "AppCore", "AppDesignSystem"]),
        .testTarget(name: "FeatureLoginTests", dependencies: ["FeatureLogin"]),
    ]
)
