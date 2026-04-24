//
//  Config.swift
//  Network
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
import Environment

public struct Config {
    public static var inferredChannel: String {
        Environment.channel.inferredChannel
    }
}

public struct NetworkOAuth {
    public static var appid: String {
        Environment.oauth.appid
    }
    
    public static var appSecret: String {
        Environment.oauth.appSecret
    }
    
    public static var appSalt: String {
        Environment.oauth.appSalt
    }
}

public struct NetworkServer {
    public static var baseURL: URL {
        Environment.server.baseURL
    }
    
    public static var uploadURL: URL {
        Environment.server.uploadURL
    }
}

public let NetworkDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()
