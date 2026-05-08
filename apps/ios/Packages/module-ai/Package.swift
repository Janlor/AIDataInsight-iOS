// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "ModuleAI",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "ModuleAI",
            targets: ["ModuleAI"]),
    ],
    dependencies: [
        .package(path: "../library-common"),
//        .package(url: "http://192.168.0.93/appmodule-ios/library-basics.git", branch: "temp-fourth"),
//        .package(url: "http://192.168.0.93/appmodule-ios/library-common.git", branch: "v2.5.1"),
//        .package(url: "http://192.168.0.93/dev113/BaseUI.git", from: "1.0.5"),
//        .package(url: "http://192.168.0.93/dev113/Network.git", from: "1.0.3"),
//        .package(url: "http://192.168.0.93/dev113/Refresh.git", from: "1.0.3"),
//        .package(url: "http://192.168.0.93/dev113/AppLaunch.git", from: "1.0.1"),
//        .package(url: "http://192.168.0.93/dev113/BaseKit.git", from: "1.0.2"),
//        .package(url: "http://192.168.0.93/dev113/Router.git", from: "1.0.1"),
//        .package(url: "http://192.168.0.93/dev113/ProtocolAI.git", from: "1.0.0"),
//        .package(url: "https://github.com/danielgindi/Charts.git", exact: "5.1.0"),
        .package(url: "https://gitee.com/wanxy0527/Charts.git", exact: "5.1.0"),
    ],
    targets: [
        .target(
            name: "ModuleAI",
            dependencies: [
                .product(name: "LibraryCommon", package: "library-common"),
//                .product(name: "BaseUI", package: "BaseUI"),
//                .product(name: "Network", package: "Network"),
//                .product(name: "Refresh", package: "Refresh"),
//                .product(name: "AppLaunch", package: "AppLaunch"),
//                .product(name: "BaseKit", package: "BaseKit"),
//                .product(name: "Router", package: "Router"),
//                .product(name: "ProtocolAI", package: "ProtocolAI"),
                .product(name: "DGCharts", package: "Charts"),
            ],
            resources: [
                .process("Resources/Assets.xcassets"),
                .process("Resources/Localizable.xcstrings")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("CoreGraphics")
            ]
        ),
        .testTarget(
            name: "ModuleAITests",
            dependencies: ["ModuleAI"]
        ),
    ]
)
