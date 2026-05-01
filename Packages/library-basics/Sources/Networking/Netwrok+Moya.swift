//
//  Netwrok+Moya.swift
//  LibraryBasics
//
//  Created by Janlor on 2024/5/22.
//

import Foundation
import Moya

//*******************************Provider*************************************//
public typealias Provider = Moya.MoyaProvider

public typealias PluginType = Moya.PluginType

public typealias Cancellable = Moya.Cancellable

public typealias Completion = Moya.Completion

public typealias ProgressBlock = Moya.ProgressBlock

public typealias ProgressResponse = Moya.ProgressResponse

public typealias ProviderType = Moya.MoyaProviderType

public typealias StubBehavior = Moya.StubBehavior

public typealias NetworkError = Moya.MoyaError

public typealias Manager = Moya.Session

public typealias Endpoint = Moya.Endpoint
//**********************************end***************************************//


//*******************************TargetType***********************************//
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

/// Multipart form data encoding result.
//public typealias MultipartFormDataEncodingResult = Moya.Manager.MultipartFormDataEncodingResult
public typealias DownloadDestination = Moya.DownloadDestination
//**********************************end***************************************//
