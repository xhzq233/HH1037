//
//  ViewController.swift
//  HH1037
//
//  Created by Xu on 10/23/22.
//

import UIKit
import WebKit

class NetworkUnavailableView: UIView {
    let imageView = UIImageView()
    let labelView = UILabel()
    let stackView = UIStackView()
    let button = UIButton()
    init() {
        super.init(frame: .zero)
        self.addSubview(stackView)

        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            stackView.topAnchor.constraint(equalTo: topAnchor, constant: 64),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.6),
            stackView.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.6),
        ])

        labelView.text = "网络错误"
        imageView.contentMode = .scaleAspectFit
        stackView.axis = .vertical
        stackView.addArrangedSubview(imageView)
        stackView.addArrangedSubview(labelView)
        stackView.addArrangedSubview(button)
        stackView.spacing = 20

        labelView.textAlignment = .center
        labelView.font = .systemFont(ofSize: 22)

        if #available(iOS 15.0, *) {
            button.configuration = .filled()
        } else {
            // Fallback on earlier versions
        }
        
        button.frame.size = .init(width: 64, height: 32)
        button.setTitle("重新加载", for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

class ViewController: UIViewController {

    var webView: WKWebView!
    let networkUnavailableView = NetworkUnavailableView()

    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        loadURL()
    }

    let reachability: Reachability! = Reachability.forInternetConnection()

    func listenNetWorkChange() {
        reachability.startNotifier()
        NotificationCenter.default.addObserver(
            self, selector: #selector(inspectNetworkState), name: NSNotification.Name.reachabilityChanged, object: nil)
    }
    
    func showWebView() {
        webView.isHidden = false
        networkUnavailableView.isHidden = true
        networkUnavailableView.imageView.image = nil
        loadURL()
    }
    
    func hideWebView() {
        webView.isHidden = true
        networkUnavailableView.isHidden = false
        networkUnavailableView.imageView.image = UIImage(named: "group310")
    }
    
    @objc func reloadWeb() {
        if reachability.currentReachabilityStatus() == NotReachable { return }
        else {
            showWebView()
        }
    }

    @objc func inspectNetworkState() {
        if reachability.currentReachabilityStatus() != NotReachable {
            showWebView()
        } else {
            hideWebView()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        self.view.backgroundColor = .systemBackground
        webView = WKWebView()
        webView.navigationDelegate = self
        webView.uiDelegate = self

        view.addSubview(webView)
        view.addSubview(networkUnavailableView)

        webView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            webView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            webView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            webView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            webView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])

        networkUnavailableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            networkUnavailableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            networkUnavailableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            networkUnavailableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            networkUnavailableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
        ])
        
        networkUnavailableView.button.addTarget(self, action: #selector(reloadWeb), for: .touchUpInside)

        listenNetWorkChange()
        inspectNetworkState()
    }

    func loadURL() {
        Task(priority: .background) {
            if let url = URL(string: "https://husthole.com") {
                if webView.url != nil {
                    let _ = webView.reload()
                } else {
                    let _ = webView.load(URLRequest(url: url))
                }
            }
        }
    }
}

extension ViewController: WKNavigationDelegate, WKUIDelegate {
    func webView(
        _ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!,
        withError error: Error
    ) {
        hideWebView()
        print("webView error \(error)")
    }
    
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        print("Strat to load")
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        hideWebView()
        print("webView error \(error)")
    }
    
    func webView(_ webView: WKWebView, decidePolicyFor navigationResponse: WKNavigationResponse) async -> WKNavigationResponsePolicy {
        if (navigationResponse.response as? HTTPURLResponse)?.statusCode != 200 {
            return .cancel
        } else {
            return .allow
        }
    }

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        webView.evaluateJavaScript("window.changeToIOS()") { res, error in
            if let error = error {
                print(error)
            }
        }
    }
}
