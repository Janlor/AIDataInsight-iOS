// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "AppDependencies",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "AppDependencies",
            targets: ["AppDependencies"]),
    ],
    dependencies: [
        .package(path: "../../../Packages/library-basics"),
        .package(path: "../../../Packages/library-common"),
        .package(path: "../../../Packages/module-ai")
    ],
    targets: [
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