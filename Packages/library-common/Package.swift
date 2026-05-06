// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "LibraryCommon",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15),
    ],
    products: [
        .library(
            name: "LibraryCommon",
            targets: [
                "AppMain",
                "CommonViewModel",
                "Login",
                "LoginProtocol",
                "Privacy",
                "PrivacyProtocol",
                "ProtocolAI",
                "Setting",
                "SettingProtocol",
            ]
        ),
        .library(
            name: "AppMain",
            targets: ["AppMain"]),
        .library(
            name: "CommonViewModel",
            targets: ["CommonViewModel"]),
        .library(
            name: "Login",
            targets: ["Login"]),
        .library(
            name: "LoginProtocol",
            targets: ["LoginProtocol"]),
        .library(
            name: "Privacy",
            targets: ["Privacy"]),
        .library(
            name: "PrivacyProtocol",
            targets: ["PrivacyProtocol"]),
        .library(
            name: "ProtocolAI",
            targets: ["ProtocolAI"]),
        .library(
            name: "Setting",
            targets: [ "Setting"]),
        .library(
            name: "SettingProtocol",
            targets: [ "SettingProtocol"]),
    ],
    dependencies: [
        .package(path: "../library-basics"),
//        .package(url: "http://192.168.0.93/appmodule-ios/library-basics.git", branch: "v2.3.1"),
    ],
    targets: [
        .target(
            name: "AppMain",
            dependencies: [
                "ProtocolAI",
                "LoginProtocol",
                .product(name: "AccountProtocol", package: "library-basics"),
                .product(name: "BaseUI", package: "library-basics"),
                .product(name: "AppLaunch", package: "library-basics"),
                .product(name: "Router", package: "library-basics"),
                .product(name: "BaseKit", package: "library-basics"),
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
            ]
        ),
        .target(
            name: "CommonViewModel",
            dependencies: [
                .product(name: "AppLaunch", package: "library-basics"),
                .product(name: "BaseViewModel", package: "library-basics"),
                .product(name: "Networking", package: "library-basics"),
            ]
        ),
        .target(
            name: "Login",
            dependencies: [
                "LoginProtocol",
                "PrivacyProtocol",
                .product(name: "AccountProtocol", package: "library-basics"),
                .product(name: "BaseUI", package: "library-basics"),
                .product(name: "Networking", package: "library-basics"),
                .product(name: "AppLaunch", package: "library-basics"),
                .product(name: "AppSecurity", package: "library-basics"),
                .product(name: "Router", package: "library-basics"),
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Localizable.xcstrings")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit")
            ]
        ),
        .target(
            name: "LoginProtocol",
            dependencies: [
                .product(name: "AccountProtocol", package: "library-basics")
            ]
        ),
        .target(
            name: "Privacy",
            dependencies: [
                "PrivacyProtocol",
                .product(name: "Environment", package: "library-basics"),
                .product(name: "BaseUI", package: "library-basics"),
                .product(name: "AppLaunch", package: "library-basics"),
                .product(name: "Router", package: "library-basics"),
            ],
            resources: [
                .process("Localizable.xcstrings")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("WebKit")
            ]
        ),
        .target(
            name: "PrivacyProtocol"
        ),
        .target(
            name: "ProtocolAI"
        ),
        .target(
            name: "Setting",
            dependencies: [
                "SettingProtocol",
                "LoginProtocol",
                "PrivacyProtocol",
                .product(name: "AccountProtocol", package: "library-basics"),
                .product(name: "BaseUI", package: "library-basics"),
                .product(name: "AppLaunch", package: "library-basics"),
                .product(name: "Router", package: "library-basics"),
                .product(name: "Environment", package: "library-basics")
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Localizable.xcstrings")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
            ]
        ),
        .target(
            name: "SettingProtocol"
        ),
    ]
)
