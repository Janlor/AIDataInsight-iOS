#!/usr/bin/env swift

import Foundation

// MARK: - 配置项
let packagesRoot = "../Packages"            // 扫描路径
let outputFile = "Package.swift"            // 输出文件
let businessModulesBranches = [             // 业务模块用分支锁定
    "library-basics": "v2.3.1",
    "library-common": "v2.5.1",
    "module-ai": "v2.4.1"
]
let businessModuleProductNames = [
    "library-basics": "LibraryBasics",
    "library-common": "LibraryCommon",
    "module-ai": "ModuleAI"
]
let defaultBranch = "main"                  // 如果没找到 tag，默认锁 main
let iosVersion = "v13"

// MARK: - CLI 参数解析
enum DependencyMode {
    case allRemote
    case allLocal
    case mixed(localModules: Set<String>)
}

func parseMode() -> DependencyMode {
    let args = CommandLine.arguments
    if args.contains("--all-local") {
        return .allLocal
    } else if let localIndex = args.firstIndex(of: "--local") {
        let localModules = Set(args[(localIndex + 1)...])
        return .mixed(localModules: localModules)
    } else {
        return .allRemote
    }
}

let mode = parseMode()

// MARK: - 执行 shell 命令
@discardableResult
func shell(_ command: String, currentDirectory: URL? = nil) -> String {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    if let dir = currentDirectory {
        task.currentDirectoryURL = dir
    }
    
    let pipe = Pipe()
    task.standardOutput = pipe
    task.standardError = pipe
    task.launch()
    
    let data = pipe.fileHandleForReading.readDataToEndOfFile()
    return String(data: data, encoding: .utf8) ?? ""
}

// MARK: - 检查是否是 Swift Package
func isSwiftPackage(at url: URL) -> Bool {
    FileManager.default.fileExists(atPath: url.appendingPathComponent("Package.swift").path)
}

// MARK: - 获取 Git 信息
func getGitRemoteURL(at url: URL) -> String? {
    let result = shell("git remote get-url origin", currentDirectory: url).trimmingCharacters(in: .whitespacesAndNewlines)
    return result.isEmpty ? nil : result
}

func getLatestTag(at url: URL) -> String? {
    let tags = shell("git tag --sort=-creatordate", currentDirectory: url)
        .split(separator: "\n")
        .map { String($0) }
    return tags.first
}

func getCurrentBranch(at url: URL) -> String? {
    let branch = shell("git rev-parse --abbrev-ref HEAD", currentDirectory: url)
        .trimmingCharacters(in: .whitespacesAndNewlines)
    return branch.isEmpty ? nil : branch
}

// MARK: - 递归扫描所有 Swift Package
//func scanPackages(at rootPath: String) -> [URL] {
//    let fm = FileManager.default
//    guard let enumerator = fm.enumerator(atPath: rootPath) else { return [] }
//    
//    var results: [URL] = []
//    
//    for case let subPath as String in enumerator {
//        let fullPath = URL(fileURLWithPath: rootPath).appendingPathComponent(subPath)
//        if isSwiftPackage(at: fullPath) {
//            results.append(fullPath)
//            enumerator.skipDescendants() // 已找到 Package.swift，不再往下
//        }
//    }
//    return results
//}

func scanPackages(at rootPath: String) -> [URL] {
    let fm = FileManager.default
    guard let contents = try? fm.contentsOfDirectory(atPath: rootPath) else { return [] }
    
    return contents.compactMap { subDir -> URL? in
        let fullPath = URL(fileURLWithPath: rootPath).appendingPathComponent(subDir)
        return isSwiftPackage(at: fullPath) ? fullPath : nil
    }
}

// MARK: - 扫描模块
let rootURL = URL(fileURLWithPath: packagesRoot)
let allPackages = scanPackages(at: rootURL.path)
if allPackages.isEmpty {
    print("❌ 没有发现任何 Swift Package！")
    exit(1)
}

// MARK: - 生成 dependencies & targets
var dependencyLines: [String] = []
var collectedModuleNames: [String] = []

for packageURL in allPackages.sorted(by: { $0.lastPathComponent < $1.lastPathComponent }) {
    let moduleName = packageURL.lastPathComponent
    let packageRelativePath = "\(packagesRoot)/\(packageURL.path.replacingOccurrences(of: rootURL.path + "/", with: ""))"

    switch mode {
    case .allLocal:
        dependencyLines.append(#".package(path: "\#(packageRelativePath)")"#)
        collectedModuleNames.append(moduleName)
        
    case .allRemote:
        if let remoteURL = getGitRemoteURL(at: packageURL) {
            if let branch = businessModulesBranches[moduleName] {
                dependencyLines.append(#".package(url: "\#(remoteURL)", branch: "\#(branch)")"#)
            } else if let tag = getLatestTag(at: packageURL) {
                dependencyLines.append(#".package(url: "\#(remoteURL)", exact: "\#(tag)")"#)
            } else {
                dependencyLines.append(#".package(url: "\#(remoteURL)", branch: "\#(defaultBranch)")"#)
            }
            collectedModuleNames.append(moduleName)
        } else {
            print("⚠️ [跳过] \(moduleName) 没有 git remote")
        }
        
    case .mixed(let localModules):
        if localModules.contains(moduleName) {
            dependencyLines.append(#".package(path: "\#(packageRelativePath)")"#)
        } else if let remoteURL = getGitRemoteURL(at: packageURL) {
            if let branch = businessModulesBranches[moduleName] {
                dependencyLines.append(#".package(url: "\#(remoteURL)", branch: "\#(branch)")"#)
            } else if let tag = getLatestTag(at: packageURL) {
                dependencyLines.append(#".package(url: "\#(remoteURL)", exact: "\#(tag)")"#)
            } else {
                dependencyLines.append(#".package(url: "\#(remoteURL)", branch: "\#(defaultBranch)")"#)
            }
        }
        collectedModuleNames.append(moduleName)
    }
}

let targetDependencies: [String] = collectedModuleNames.map { moduleName in
    if let productName = businessModuleProductNames[moduleName] {
        return ".product(name: \"\(productName)\", package: \"\(moduleName)\")"
    } else {
        return "\"\(moduleName)\""
    }
}

// MARK: - 拼接最终 Package.swift 内容
let packageContent = """
// swift-tools-version:5.6
import PackageDescription

let package = Package(
    name: "AppDependencies",
    platforms: [.iOS(.\(iosVersion))],
    products: [
        .library(
            name: "AppDependencies",
            targets: ["AppDependencies"]),
    ],
    dependencies: [
        \(dependencyLines.joined(separator: ",\n        "))
    ],
    targets: [
        // 预留 binaryTarget 示例
        // .binaryTarget(name: "MyBinaryLib", url: "http://server/MyBinary.xcframework.zip", checksum: "..."),
        .target(
            name: "AppDependencies",
            dependencies: [
                \(targetDependencies.joined(separator: ",\n                "))
            ]
        )
    ]
)
"""

// 写入文件
try packageContent.write(toFile: outputFile, atomically: true, encoding: .utf8)
print("✅ 已生成 \(outputFile) ，共 \(allPackages.count) 个模块")

