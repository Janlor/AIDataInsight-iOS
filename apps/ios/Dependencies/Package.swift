// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "Dependencies",
    platforms: [.iOS(.v15)],
    products: [
        .library(
            name: "Dependencies",
            targets: ["Dependencies"]),
    ],
    dependencies: [
        .package(path: "../Packages/library-basics"),
        .package(path: "../Packages/library-common"),
        .package(path: "../Packages/module-ai")
    ],
    targets: [
        .target(
            name: "Dependencies",
            dependencies: [
                .product(name: "LibraryBasics", package: "library-basics"),
                .product(name: "LibraryCommon", package: "library-common"),
                .product(name: "ModuleAI", package: "module-ai")
            ]
        )
    ]
)
