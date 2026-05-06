//
//  Netwrok+Moya.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
import Moya

public typealias Cancellable = Moya.Cancellable

public typealias NetworkError = Moya.MoyaError
public typealias TargetType = Moya.TargetType

/// Represents an HTTP method.
public typealias Method = Moya.Method

public typealias Task = Moya.Task

/// Choice of parameter encoding.
public typealias ParameterEncoding = Moya.ParameterEncoding
public typealias JSONEncoding = Moya.JSONEncoding
public typealias URLEncoding = Moya.URLEncoding
//public typealias PropertyListEncoding = Moya.PropertyListEncoding

/// Multipart form.
public typealias MultipartFormData = Moya.MultipartFormData
public typealias MultipartFormBodyPart = Moya.MultipartFormBodyPart

public typealias DownloadDestination = Moya.DownloadDestination
