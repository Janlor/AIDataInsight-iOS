//
//  WKWebViewController.swift
//  LibraryBasics
//
//  Created by Janlor on 2025/4/15.
//

import Foundation
import WebKit

@objc(AppWKWebViewController)
open class WKWebViewController: UIViewController {
    
    /// wkwebview的配置
    @objc
    open lazy var wkWebViewConfig: WKWebViewConfiguration = WKWebViewConfiguration()
    
    /// wkWebView
    @objc
    open lazy var wkWebView: WKWebView = WKWebView(frame: view.bounds, configuration: wkWebViewConfig)
    
    @objc
    open override func loadView() {
        super.loadView()
        view = wkWebView
    }
 
    @objc
    open override func viewDidLoad() {
        super.viewDidLoad()
        // scrollView 自动适应 safeArea
        self.wkWebView.scrollView.contentInsetAdjustmentBehavior = .always
    }
    
    @objc
    open override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        wkWebViewConfig.addJsBridge()
    }
    
    @objc
    open override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        /// 防止循环引用
        wkWebViewConfig.removeJsbridge()
    }
    
}

