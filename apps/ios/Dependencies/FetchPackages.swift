#!/usr/bin/env swift

import Foundation

let packagesRoot = "../Packages"

// MARK: - 读取 Package.swift 内容
let packageSwiftPath = "./Package.swift"
guard FileManager.default.fileExists(atPath: packageSwiftPath) else {
    print("❌ 当前目录下没有 Package.swift！请在壳工程根目录运行")
    exit(1)
}

let packageContent = try String(contentsOfFile: packageSwiftPath, encoding: .utf8)

// MARK: - 解析远程依赖（只处理 url）
let regexPattern = #"\.package\s*\(\s*url:\s*"([^"]+)"\s*,\s*(exact|branch):\s*"([^"]+)"\s*\)"#
let regex = try NSRegularExpression(pattern: regexPattern, options: [])

let matches = regex.matches(in: packageContent, options: [], range: NSRange(location: 0, length: packageContent.utf16.count))

if matches.isEmpty {
    print("⚠️ 没有发现任何远程依赖（只有本地依赖）")
    exit(0)
}

// MARK: - 执行 shell 命令
@discardableResult
func shell(_ command: String, cwd: URL? = nil) -> Int32 {
    let task = Process()
    task.launchPath = "/bin/bash"
    task.arguments = ["-c", command]
    if let cwd = cwd {
        task.currentDirectoryURL = cwd
    }
    task.launch()
    task.waitUntilExit()
    return task.terminationStatus
}

// MARK: - 准备目标目录
let currentDir = URL(fileURLWithPath: FileManager.default.currentDirectoryPath, isDirectory: true)
let packagesDir = URL(fileURLWithPath: packagesRoot, relativeTo: currentDir).standardizedFileURL
do {
    try FileManager.default.createDirectory(at: packagesDir, withIntermediateDirectories: true, attributes: nil)
} catch {
    print("❌ 无法创建 Packages 目录: \(packagesDir.path)")
    print("   \(error)")
    exit(1)
}

print("📦 开始处理远程依赖 -> \(packagesDir.path) ...")

// MARK: - clone or update
for match in matches {
    let nsContent = packageContent as NSString
    let repoURL = nsContent.substring(with: match.range(at: 1))
    let lockType = nsContent.substring(with: match.range(at: 2)) // exact / branch
    let lockValue = nsContent.substring(with: match.range(at: 3)) // tag or branch name
    
    // repo 名称
    let repoName = URL(string: repoURL)?.deletingPathExtension().lastPathComponent ?? UUID().uuidString
    let targetDir = packagesDir.appendingPathComponent(repoName)
    
    let fileManager = FileManager.default

    // 判断目录是否已存在 & 是 git 仓库
    let gitDir = targetDir.appendingPathComponent(".git")
    let isGitRepo = fileManager.fileExists(atPath: gitDir.path)

    if isGitRepo {
        // ✅ 已存在且是 git 仓库 -> update
        print("🔄 更新 \(repoName) -> \(lockType): \(lockValue)")
        _ = shell("git fetch --all --tags", cwd: targetDir)
        _ = shell("git checkout \(lockValue)", cwd: targetDir)
        _ = shell("git pull", cwd: targetDir)
        print("✅ 已更新 \(repoName)")
    } else {
        // ⬇️ 不存在（或目录不完整）-> clone
        if fileManager.fileExists(atPath: targetDir.path) {
            print("⚠️ \(repoName) 目录已存在但不是 git 仓库，删除后重克隆")
            try? fileManager.removeItem(at: targetDir)
        }
        
        print("⬇️ 克隆 \(repoName) [\(lockType): \(lockValue)]")
        let cloneCmd = "git clone \(repoURL) \(targetDir.path)"
        if shell(cloneCmd) == 0 {
            _ = shell("git checkout \(lockValue)", cwd: targetDir)
            print("✅ 完成克隆 \(repoName)")
        } else {
            print("❌ 克隆失败 \(repoURL)")
        }
    }
}

print("🎉 所有远程依赖处理完毕")
