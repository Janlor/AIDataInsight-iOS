// swift-tools-version: 6.0

import PackageDescription

let package = Package(
    name: "AppPersistence",
    platforms: [
        .iOS(.v17),
        .macOS(.v14),
        .visionOS(.v1),
    ],
    products: [
        .library(name: "AppPersistence", targets: ["AppPersistence"]),
    ],
    dependencies: [
        .package(path: "../AppCore"),
        .package(path: "../AppContracts"),
    ],
    targets: [
        .target(name: "AppPersistence", dependencies: ["AppCore", "AppContracts"]),
        .testTarget(name: "AppPersistenceTests", dependencies: ["AppPersistence"]),
    ]
)
