//
//  FunctionResponseDTO.swift
//  ModuleAI
//
//  Created by Codex on 2026/1/1.
//

import Foundation
import Networking
import BaseKit

struct FunctionResponseDTO: Codable, NetworkRequestable {
    let historyId: Int?
    let hasTool: Bool?
    let name: FunctionName?
    let msg: String?
    let arguments: FunctionArguments?
    
    enum CodingKeys: CodingKey {
        case historyId, hasTool, name, msg, arguments
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        historyId = try container.decodeIfPresent(Int.self, forKey: .historyId)
        hasTool = try container.decodeIfPresent(Bool.self, forKey: .hasTool)
        name = try container.decodeIfPresent(FunctionName.self, forKey: .name)
        msg = try container.decodeIfPresent(String.self, forKey: .msg)
        arguments = try container.decodeFunctionArguments(name: name, forKey: .arguments)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(historyId, forKey: .historyId)
        try container.encodeIfPresent(hasTool, forKey: .hasTool)
        try container.encodeIfPresent(name, forKey: .name)
        try container.encodeIfPresent(msg, forKey: .msg)
        
        switch arguments {
        case .basic(let model):
            try container.encode(model, forKey: .arguments)
        case .timeRange(let model):
            try container.encode(model, forKey: .arguments)
        case .warehouse(let model):
            try container.encode(model, forKey: .arguments)
        case .accountAge(let model):
            try container.encode(model, forKey: .arguments)
        case .performanceType(let model):
            try container.encode(model, forKey: .arguments)
        case nil:
            break
        }
    }
}

extension FunctionResponseDTO {
    func toDomainModel() -> FunctionModel {
        FunctionModel(
            historyId: historyId,
            hasTool: hasTool,
            name: name,
            msg: msg,
            arguments: arguments
        )
    }
}
