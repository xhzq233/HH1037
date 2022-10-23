//
//  ViewController.swift
//  HH1037
//
//  Created by Xu on 10/23/22.
//

import UIKit
import WebKit

class ViewController: UIViewController {

    var webView: WKWebView!

    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .white
        webView = WKWebView()

        webView.navigationDelegate = self
        webView.uiDelegate = self

        view.addSubview(webView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        loadURL()
    }

    func loadURL() {
        Task(priority: .background) {
            if let url = URL(string: "https://frontv2.pivotstudio.cn/") {
                let _ = webView.load(URLRequest(url: url))
            }
        }
    }

}

extension ViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        print(error.localizedDescription)
    }
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish to load")
    }
}
