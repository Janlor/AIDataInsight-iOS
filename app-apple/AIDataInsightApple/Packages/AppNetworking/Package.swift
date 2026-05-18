// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppNetworking",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "AppNetworking", targets: ["AppNetworking"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../AppContracts"),
    ],
    targets: [
        .target(name: "AppNetworking", dependencies: ["AppCore", "AppContracts"]),
        .testTarget(name: "AppNetworkingTests", dependencies: ["AppNetworking"]),
    ]
)
