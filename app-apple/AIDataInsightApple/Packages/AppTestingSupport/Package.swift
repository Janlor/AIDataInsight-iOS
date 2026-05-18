// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppTestingSupport",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "AppTestingSupport", targets: ["AppTestingSupport"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../AppContracts"),
    ],
    targets: [
        .target(name: "AppTestingSupport", dependencies: ["AppCore", "AppContracts"]),
        .testTarget(name: "AppTestingSupportTests", dependencies: ["AppTestingSupport"]),
    ]
)
