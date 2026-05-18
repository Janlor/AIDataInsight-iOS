// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppDesignSystem",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "AppDesignSystem", targets: ["AppDesignSystem"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
    ],
    targets: [
        .target(name: "AppDesignSystem", dependencies: ["AppCore"]),
        .testTarget(name: "AppDesignSystemTests", dependencies: ["AppDesignSystem"]),
    ]
)
