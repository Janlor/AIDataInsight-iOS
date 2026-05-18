// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppAccount",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "AppAccount", targets: ["AppAccount"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../AppContracts"),
        .package(path: "../AppNetworking"),
    ],
    targets: [
        .target(name: "AppAccount", dependencies: ["AppCore", "AppContracts", "AppNetworking"]),
        .testTarget(name: "AppAccountTests", dependencies: ["AppAccount"]),
    ]
)
