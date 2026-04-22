//
//  AppCompatible.swift
//  LibraryCommon
//
//  Created by Janlor on 12/23/23.
//  Copyright © 2023 Janlor Lee. All rights reserved.
//

import UIKit

public struct AppWrapper<Base> {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol AppCompatible: AnyObject {
    associatedtype Base

    static var app: AppWrapper<Base>.Type { get }
    var app: AppWrapper<Base> { get }
}

public protocol AppCompatibleValue {
    associatedtype Base

    static var app: AppWrapper<Base>.Type { get }
    var app: AppWrapper<Base> { get }
}

extension AppCompatible {
    public static var app: AppWrapper<Self>.Type {
        get { AppWrapper<Self>.self }
        set { }
    }
    
    public var app: AppWrapper<Self> {
        get { return AppWrapper(self) }
        set { }
    }
}

extension AppCompatibleValue {
    public static var app: AppWrapper<Self>.Type {
        get { AppWrapper<Self>.self }
        set { }
    }
    
    public var app: AppWrapper<Self> {
        get { return AppWrapper(self) }
        set { }
    }
}

extension UIResponder: AppCompatible { }

extension String: AppCompatibleValue { }
