//
//  FunctionModel.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation

struct FunctionModel: Hashable {
    let historyId: Int?
    let hasTool: Bool?
    let name: FunctionName?
    let msg: String?
    let arguments: FunctionArguments?
}
