//
//  BaseViewModel.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/12/29.
//

import Foundation

public protocol CancellableTask: AnyObject {
    var isCancelled: Bool { get }
    var onFinish: (() -> Void)? { get set }
    func cancel()
}

public enum TaskKey: Hashable {
    case list
    case detail
    case update
    case custom(String)
}

/// 项目专用 BaseViewModel（Closure 回调）
open class BaseViewModel {

    // MARK: - Task 管理
    
    private var tasks: [TaskKey: CancellableTask] = [:]

    public init() {}

    /// 记录一个网络任务（用于统一 cancel）
    @discardableResult
    public func trackTask(
        _ task: CancellableTask?,
        for key: TaskKey,
        cancelPrevious: Bool = true
    ) -> CancellableTask? {

        guard var task = task else { return nil }

        if cancelPrevious, let old = tasks[key] {
            old.cancel()
            tasks[key] = nil
        }

        tasks[key] = task

        task.onFinish = { [weak self] in
            self?.tasks[key] = nil
        }

        return task
    }

    /// 取消单个任务
    public func cancelTask(for key: TaskKey) {
        tasks[key]?.cancel()
        tasks[key] = nil
    }

    /// 取消所有任务（页面关闭 / deinit）
    public func cancelAllTasks() {
        tasks.values.forEach { $0.cancel() }
        tasks.removeAll()
    }

    deinit {
        cancelAllTasks()
    }
}
