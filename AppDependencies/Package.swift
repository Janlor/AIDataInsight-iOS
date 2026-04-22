// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "AppDependencies",
    platforms: [.iOS(.v13)],
    products: [
        .library(
            name: "AppDependencies",
            targets: ["AppDependencies"]),
    ],
    dependencies: [
        .package(path: "../Packages/library-basics"),
        .package(path: "../Packages/library-common"),
        .package(path: "../Packages/module-ai"),
        // .package(url: "http://192.168.0.93/appmodule-ios/library-basics.git", branch: "v2.3.1"),
        // .package(url: "http://192.168.0.93/appmodule-ios/library-common.git", branch: "v2.5.1"),
        // .package(url: "http://192.168.0.93/appmodule-ios/module-ai.git", branch: "v2.4.1"),
    ],
    targets: [
        // 预留 binaryTarget 示例
        // .binaryTarget(name: "MyBinaryLib", url: "http://server/MyBinary.xcframework.zip", checksum: "..."),
        .target(
            name: "AppDependencies",
            dependencies: [
                .product(name: "LibraryBasics", package: "library-basics"),
                .product(name: "LibraryCommon", package: "library-common"),
                .product(name: "ModuleAI", package: "module-ai")
            ]
        )
    ]
)
