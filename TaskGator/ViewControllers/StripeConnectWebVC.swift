//
//  StripeConnectWebVC.swift
//  bemyrider
//
//  Created by NCT123 on 28/06/22.
//  Copyright © 2022 NCT 24. All rights reserved.
//

import UIKit
import WebKit

class StripeConnectWebVC: NewBaseViewController {

    //MARK: Properties
    static var storyboardInstance:StripeConnectWebVC {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: StripeConnectWebVC.identifier) as! StripeConnectWebVC
    }

    private var headerView: UIView!
    private var webview: WKWebView!
    private var progressView: UIProgressView!
    private var progressObservation: NSKeyValueObservation?
    private var isFirstLoad = true

    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        if let gradient = headerView.layer.sublayers?.first as? CAGradientLayer {
            gradient.frame = headerView.bounds
        }
    }

    deinit {
        progressObservation?.invalidate()
    }

    private func setupUI(){
        view.backgroundColor = UIColor(red: 0.16, green: 0.13, blue: 0.40, alpha: 1)

        // Gradient header (same as SwiftUI pages)
        headerView = UIView()
        headerView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(headerView)

        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [
            UIColor(red: 0.16, green: 0.13, blue: 0.40, alpha: 1).cgColor,
            UIColor(red: 0.22, green: 0.20, blue: 0.45, alpha: 1).cgColor,
            UIColor(red: 0.20, green: 0.22, blue: 0.35, alpha: 1).cgColor
        ]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        headerView.layer.insertSublayer(gradientLayer, at: 0)

        // Back button
        let backButton = UIButton(type: .system)
        backButton.translatesAutoresizingMaskIntoConstraints = false
        let chevronConfig = UIImage.SymbolConfiguration(pointSize: 18, weight: .semibold)
        backButton.setImage(UIImage(systemName: "chevron.left", withConfiguration: chevronConfig), for: .normal)
        backButton.tintColor = .white
        backButton.addTarget(self, action: #selector(didTapBackButton(sender:)), for: .touchUpInside)
        headerView.addSubview(backButton)

        // Title label
        let titleLabel = UILabel()
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.text = "Stripe Connect"
        titleLabel.font = .systemFont(ofSize: 22, weight: .bold)
        titleLabel.textColor = .white
        headerView.addSubview(titleLabel)

        // Progress bar
        progressView = UIProgressView(progressViewStyle: .bar)
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.progressTintColor = UIColor(red: 0.39, green: 0.35, blue: 0.95, alpha: 1)
        progressView.trackTintColor = UIColor.lightGray.withAlphaComponent(0.3)
        view.addSubview(progressView)

        // WKWebView configuration
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        webview = WKWebView(frame: .zero, configuration: config)
        webview.translatesAutoresizingMaskIntoConstraints = false
        webview.navigationDelegate = self
        webview.uiDelegate = self
        webview.allowsBackForwardNavigationGestures = false
        webview.scrollView.contentInsetAdjustmentBehavior = .automatic
        webview.scrollView.bounces = true
        webview.backgroundColor = .white
        webview.isOpaque = true
        webview.alpha = 0
        view.addSubview(webview)

        // Auto Layout
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            backButton.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            backButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            backButton.widthAnchor.constraint(equalToConstant: 30),
            backButton.heightAnchor.constraint(equalToConstant: 30),

            titleLabel.leadingAnchor.constraint(equalTo: backButton.trailingAnchor, constant: 12),
            titleLabel.centerYAnchor.constraint(equalTo: backButton.centerYAnchor),
            titleLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -20),

            headerView.bottomAnchor.constraint(equalTo: backButton.bottomAnchor, constant: 16),

            progressView.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            progressView.heightAnchor.constraint(equalToConstant: 3),

            webview.topAnchor.constraint(equalTo: progressView.bottomAnchor),
            webview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            webview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            webview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])

        // KVO for progress
        progressObservation = webview.observe(\.estimatedProgress, options: .new) { [weak self] webView, _ in
            guard let self = self else { return }
            let progress = Float(webView.estimatedProgress)
            self.progressView.setProgress(progress, animated: true)
            if progress >= 1.0 {
                UIView.animate(withDuration: 0.3, delay: 0.3, options: .curveEaseOut, animations: {
                    self.progressView.alpha = 0
                }) { _ in
                    self.progressView.setProgress(0, animated: false)
                }
            } else {
                self.progressView.alpha = 1
            }
        }

        getStripeUrl()
    }

    private func loadWeb(mAuthUrl: String){
        guard let stripeUrl = URL(string: mAuthUrl) else { return }
        webview.load(URLRequest(url: stripeUrl, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60))
    }

    func getStripeUrl(){
        self.sharedAppdelegate.startLoader()
        Modal.shared.getStripeConnectUrl(vc: self, param: ["user_id":UserData.shared.getUser()!.user_id]) { (dic) in
            let data  = ResponseKey.fatchData(res: dic, valueOf: .data).dic
            if let connect_url = data["connect_url"] as? String {
                self.loadWeb(mAuthUrl: connect_url)
            }else{
                self.sharedAppdelegate.stoapLoader()
                print("URL Not found from webservice")
            }
        }
    }

}

// MARK: - WKNavigationDelegate
extension StripeConnectWebVC: WKNavigationDelegate {

    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        self.sharedAppdelegate.stoapLoader()
        // Fade in webview on first load for smooth appearance
        if isFirstLoad {
            isFirstLoad = false
            UIView.animate(withDuration: 0.25) {
                self.webview.alpha = 1
            }
        }
        // Inject viewport meta for better mobile rendering
        let viewportScript = """
            var meta = document.querySelector('meta[name="viewport"]');
            if (!meta) {
                meta = document.createElement('meta');
                meta.name = 'viewport';
                document.head.appendChild(meta);
            }
            meta.content = 'width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no';
        """
        webView.evaluateJavaScript(viewportScript, completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        self.sharedAppdelegate.stoapLoader()
    }

    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        guard let url = navigationAction.request.url else {
            decisionHandler(.allow)
            return
        }

        // Intercept ONLY the final success page — let stripe_account-nct.php load
        // so the server can exchange the OAuth code and update is_payment_account_connected
        if url.path.contains("stripe_success-nct.php") {
            decisionHandler(.cancel)
            self.navigationController?.popViewController(animated: true)
            return
        }

        // Allow everything else (Stripe pages, CDNs, assets, etc.)
        decisionHandler(.allow)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
    }

    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        self.sharedAppdelegate.stoapLoader()
    }
}

// MARK: - WKUIDelegate
extension StripeConnectWebVC: WKUIDelegate {
    // Handle target="_blank" links by loading them in the same webview
    func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration, for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
        if navigationAction.targetFrame == nil || !(navigationAction.targetFrame!.isMainFrame) {
            webView.load(navigationAction.request)
        }
        return nil
    }
}
