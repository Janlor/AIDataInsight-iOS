// swift-tools-version:5.6

import PackageDescription

let package = Package(
    name: "LibraryBasics",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v15)
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
        .package(url: "https://gitee.com/neveremo/Alamofire.git", exact: "5.10.1"),
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
                "Alamofire"
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
        .target(
            name: "Storage"
        ),
        .testTarget(
            name: "LibraryBasicsTests",
            dependencies: [
                "Account",
                "Networking",
                "AccountProtocol",
                "Environment",
            ]
        ),
    ]
)
