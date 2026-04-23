//
//  PrivacyPolicyViewController.swift
//  LibraryCommon
//
//  Created by Janlor on 4/22/26.
//

import UIKit
import WebKit
import BaseUI

class PrivacyPolicyViewController: BaseViewController {
    
    /// 链接
    var urlString: String!
    var webView: WKWebView!
    
    override func setupUI() {
        super.setupUI()
        setupBackground()
        
        // 初始化 WKWebView
        webView = WKWebView(frame: self.view.bounds)
        webView.scrollView.contentInsetAdjustmentBehavior = .never
        webView.scrollView.backgroundColor = .clear
        webView.addObserver(self, forKeyPath: "title", options: .new, context: nil)
        view.addSubview(webView)
        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    override func setupData() {
        super.setupData()
        guard let url = URL(string: urlString) else { return }
        let request = URLRequest(url: url, cachePolicy: .reloadIgnoringLocalCacheData, timeoutInterval: 20)
        webView.load(request)
    }
    
    open override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
        if keyPath == "title" {
            if let title = webView.title, title != "Vite App" {
                navigationItem.title = title
            }
        } else {
            super.observeValue(forKeyPath: keyPath, of: object, change: change, context: context)
        }
    }
    
    deinit {
        if isViewLoaded {
            webView.removeObserver(self, forKeyPath: "title", context: nil)
        }
    }
}
