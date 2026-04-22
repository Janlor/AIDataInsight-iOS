//
//  ViewDataState.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/12/29.
//

import Foundation

public enum ViewDataState<T> {
    case idle          // 还没开始
    case loading       // 加载中
    case content(T)    // 已有数据（不关心来源）
    case error(Error)
}
