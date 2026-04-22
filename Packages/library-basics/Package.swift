// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "LibraryBasics",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v13)
    ],
    products: [
        .library(
            name: "LibraryBasics",
            targets: [
                "Account",
                "AccountProtocol",
                "AppLaunch",
                "AppSecurity",
                "BaseEnv",
                "BaseKit",
                "BaseUI",
                "BaseViewModel",
                "BaseWebView",
                "Environment",
                "Networking",
                "Router",
                "Storage",
            ]
        ),
        .library(
            name: "Account",
            targets: ["Account"]
        ),
        .library(
            name: "AccountProtocol",
            targets: ["AccountProtocol"]
        ),
        .library(
            name: "AppLaunch",
            targets: ["AppLaunch"]
        ),
        .library(
            name: "AppSecurity",
            targets: ["AppSecurity"]
        ),
        .library(
            name: "BaseEnv",
            targets: ["BaseEnv"]
        ),
        .library(
            name: "BaseKit",
            targets: ["BaseKit"]
        ),
        .library(
            name: "BaseUI",
            targets: ["BaseUI"]
        ),
        .library(
            name: "BaseViewModel",
            targets: ["BaseViewModel"]
        ),
        .library(
            name: "BaseWebView",
            targets: ["BaseWebView"]
        ),
        .library(
            name: "Environment",
            targets: ["Environment"]
        ),
        .library(
            name: "Networking",
            targets: ["Networking"]
        ),
        .library(
            name: "Router",
            targets: ["Router"]
        ),
        .library(
            name: "Storage",
            targets: ["Storage"]
        ),
    ],
    dependencies: [
        .package(url: "https://gitee.com/mirrors/SwifterSwift.git", exact: "7.0.0"),
        .package(url: "https://gitee.com/dingjiarui/SVProgressHUD.git", exact: "2.3.1"),
        .package(url: "https://gitee.com/Janlor/Moya.git", exact: "15.0.5"),
    ],
    targets: [
        .target(
            name: "Account",
            dependencies: [
                "AccountProtocol",
                "AppLaunch",
                "AppSecurity",
                "BaseUI",
                "Networking",
                "Router",
                "Storage"
            ],
            resources: [
                .process("Localizable.xcstrings")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
            ]
        ),
        .target(
            name: "AccountProtocol"
        ),
        .target(
            name: "AppLaunch",
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
            ]
        ),
        .target(
            name: "AppSecurity",
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("Security"),
            ]
        ),
        .target(
            name: "BaseEnv",
            linkerSettings: [
                .linkedFramework("Foundation")
            ]
        ),
        .target(
            name: "BaseKit",
            dependencies:[
                .product(name: "SwifterSwift", package: "SwifterSwift")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("AudioToolbox"),
            ]
        ),
        .target(
            name: "BaseUI",
            dependencies: [
                "BaseKit",
                "SVProgressHUD",
            ],
            resources: [
                .process("Assets.xcassets"),
                .process("Localizable.xcstrings"),
                .copy("ThemeKit/UIColor/theme_colors.json"),
                .copy("ThemeKit/UIFont/theme_fonts.json"),
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("Photos"),
            ]
        ),
        .target(
            name: "BaseViewModel",
            linkerSettings: [
                .linkedFramework("Foundation"),
            ]
        ),
        .target(
            name: "BaseWebView",
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("WebKit"),
            ]
        ),
        .target(
            name: "Environment",
            dependencies: ["BaseEnv"],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
            ]
        ),
        .target(
            name: "Networking",
            dependencies: [
                "AccountProtocol",
                "Environment",
                "Router",
                "Storage",
                "Moya"
            ],
            resources: [
                .process("Localizable.xcstrings")
            ],
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
                .linkedFramework("MobileCoreServices"),
            ]
        ),
        .target(
            name: "Router",
            linkerSettings: [
                .linkedFramework("Foundation"),
                .linkedFramework("UIKit"),
            ]
        ),
//        .binaryTarget(
//            name: "Realm",
//            url: "https://github.com/realm/realm-swift/releases/download/v10.54.6/Realm.spm.zip",
//            checksum: "5cab4055cc6c63a9c33a18d0bee6e9a615dd6867a46a4db70ca76894dbfc2261"),
//        .binaryTarget(
//            name: "RealmSwift",
//            url: "https://github.com/realm/realm-swift/releases/download/v10.54.6/RealmSwift@26.0.1.spm.zip",
//            checksum: "b80ecd851282c1778e665ec0fcf84777a93b7679f7e564fd02e6fb649f4e3e87"),
        .target(
            name: "Storage",
            dependencies: [
//                "Realm",
//                "RealmSwift",
//                .product(name: "RealmSwift", package: "realm-swift"),
                "AppLaunch"
            ]
        ),
//        .binaryTarget(
//            name: "Kingfisher",
//            url: "https://github.com/onevcat/Kingfisher/releases/download/7.12.0/Kingfisher-7.12.0.zip",
//            checksum: "0551c09e6baa6e65640c7dcbaf520caa19ca617a8119de318ee27bc10b55c5d6"
//        ),
    ]
)
