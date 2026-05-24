//
//  StripeConnectOnboardingView.swift
//  TaskGator
//
//  SwiftUI view that embeds the Stripe Connect WebView
//  directly inside the onboarding wizard (no UIKit push).
//

import SwiftUI
import WebKit

// MARK: - ViewModel

@MainActor
final class StripeConnectOnboardingViewModel: ObservableObject {
    @Published var connectURL: URL?
    @Published var isLoading = true
    @Published var loadFailed = false

    var onConnected: (() -> Void)?
    var onSkip: (() -> Void)?

    weak var presentingVC: UIViewController?

    func fetchConnectURL() {
        guard let vc = presentingVC else { return }
        isLoading = true
        loadFailed = false

        Modal.shared.getStripeConnectUrl(
            vc: vc,
            param: ["user_id": UserData.shared.getUser()!.user_id]
        ) { [weak self] dic in
            guard let self = self else { return }
            let data = ResponseKey.fatchData(res: dic, valueOf: .data).dic
            if let urlString = data["connect_url"] as? String,
               let url = URL(string: urlString) {
                self.connectURL = url
            } else {
                self.loadFailed = true
            }
            self.isLoading = false
        }
    }

    func handleNavigation(_ url: URL) -> Bool {
        if url.path.contains("stripe_success-nct.php") {
            onConnected?()
            return false // cancel navigation
        }
        return true // allow
    }
}

// MARK: - SwiftUI View

struct StripeConnectOnboardingView: View {
    @ObservedObject var viewModel: StripeConnectOnboardingViewModel

    var body: some View {
        VStack(spacing: 0) {
            if viewModel.isLoading && viewModel.connectURL == nil {
                Spacer()
                ProgressView()
                    .scaleEffect(1.3)
                SwiftUI.Text("Caricamento...")
                    .font(AppTheme.Fonts.regular(14))
                    .foregroundColor(AppTheme.Colors.placeholder)
                    .padding(.top, 12)
                Spacer()
            } else if viewModel.loadFailed {
                Spacer()
                failedView
                Spacer()
            } else if let url = viewModel.connectURL {
                infoBar
                StripeWebView(url: url, viewModel: viewModel)
            }

        }
        .background(SwiftUI.Color.white.ignoresSafeArea())
        .onAppear {
            if viewModel.connectURL == nil && !viewModel.loadFailed {
                viewModel.fetchConnectURL()
            }
        }
    }

    // MARK: - Info Bar

    private var infoBar: some View {
        HStack(spacing: 10) {
            Image(systemName: "info.circle.fill")
                .foregroundColor(AppTheme.Colors.purple)
                .font(.system(size: 16))
            SwiftUI.Text("Collega il tuo account Stripe per ricevere i pagamenti")
                .font(AppTheme.Fonts.medium(13))
                .foregroundColor(AppTheme.Colors.charcoalGrey)
        }
        .padding(12)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(AppTheme.Colors.purple.opacity(0.08))
    }

    // MARK: - Failed View

    private var failedView: some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 48))
                .foregroundColor(AppTheme.Colors.orange)

            SwiftUI.Text("Impossibile caricare Stripe")
                .font(AppTheme.Fonts.bold(17))
                .foregroundColor(AppTheme.Colors.charcoalGrey)

            SwiftUI.Text("Controlla la connessione e riprova")
                .font(AppTheme.Fonts.regular(14))
                .foregroundColor(AppTheme.Colors.placeholder)

            Button(action: { viewModel.fetchConnectURL() }) {
                SwiftUI.Text("Riprova")
                    .font(AppTheme.Fonts.bold(15))
                    .foregroundColor(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 12)
                    .background(AppTheme.Colors.orange)
                    .cornerRadius(12)
            }
        }
    }

    // MARK: - Bottom Buttons

    private var bottomButtons: some View {
        Button(action: { viewModel.onSkip?() }) {
            SwiftUI.Text("Salta per ora")
                .font(AppTheme.Fonts.medium(14))
                .foregroundColor(AppTheme.Colors.placeholder)
                .underline()
        }
        .padding(.vertical, 14)
        .background(SwiftUI.Color.white)
    }
}

// MARK: - WKWebView Representable

private struct StripeWebView: UIViewRepresentable {
    let url: URL
    let viewModel: StripeConnectOnboardingViewModel

    func makeCoordinator() -> Coordinator { Coordinator(viewModel: viewModel) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        let prefs = WKWebpagePreferences()
        prefs.allowsContentJavaScript = true
        config.defaultWebpagePreferences = prefs

        let webView = WKWebView(frame: .zero, configuration: config)
        webView.navigationDelegate = context.coordinator
        webView.uiDelegate = context.coordinator
        webView.allowsBackForwardNavigationGestures = false
        webView.scrollView.contentInsetAdjustmentBehavior = .automatic
        webView.scrollView.bounces = true
        webView.backgroundColor = .white
        webView.isOpaque = true

        webView.load(URLRequest(url: url, cachePolicy: .useProtocolCachePolicy, timeoutInterval: 60))
        return webView
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    // MARK: - Coordinator

    final class Coordinator: NSObject, WKNavigationDelegate, WKUIDelegate {
        private let viewModel: StripeConnectOnboardingViewModel

        init(viewModel: StripeConnectOnboardingViewModel) {
            self.viewModel = viewModel
        }

        func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction,
                      decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
            guard let url = navigationAction.request.url else {
                decisionHandler(.allow)
                return
            }
            if viewModel.handleNavigation(url) {
                decisionHandler(.allow)
            } else {
                decisionHandler(.cancel)
            }
        }

        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
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

        func webView(_ webView: WKWebView, createWebViewWith configuration: WKWebViewConfiguration,
                      for navigationAction: WKNavigationAction, windowFeatures: WKWindowFeatures) -> WKWebView? {
            if navigationAction.targetFrame == nil || !(navigationAction.targetFrame!.isMainFrame) {
                webView.load(navigationAction.request)
            }
            return nil
        }
    }
}
