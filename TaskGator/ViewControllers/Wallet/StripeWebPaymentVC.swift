//
//  StripeWebPaymentVC.swift
//  bemyrider
//
//  Created by NCT123 on 01/12/22.
//  Copyright © 2022 NCT 24. All rights reserved.
//

import UIKit
import WebKit

extension Notification.Name{
    static let stripePaymentHandler = Notification.Name("StripePaymentHandler")
}

class StripeWebPaymentVC: NewBaseViewController {
    
    static var storyboardInstance:StripeWebPaymentVC {
        return StoryBoard.wallet.instantiateViewController(withIdentifier: StripeWebPaymentVC.identifier) as! StripeWebPaymentVC
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var webViewContainer: UIView!
    //@IBOutlet weak var webView: WKWebView!
    //Erorr when you implementedfrom storyboard
    
    var stripe_payment_url:String?
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let stripUrl = stripe_payment_url, let url = URL(string: stripUrl) else { return }
        
        self.setupNavigationBar(title: "Payment".localized, isBack: true)
        
        activityIndicator.hidesWhenStopped = true
        activityIndicator.startAnimating()
        
        let webConfiguration = WKWebViewConfiguration()
        
        let customFrame = CGRect.init(origin: CGPoint.zero, size: CGSize.init(width: 0.0, height: self.webViewContainer.frame.size.height))
        self.webView = WKWebView (frame: customFrame , configuration: webConfiguration)
        webView.translatesAutoresizingMaskIntoConstraints = false
        self.webViewContainer.addSubview(webView)
        webView.topAnchor.constraint(equalTo: webViewContainer.topAnchor).isActive = true
        webView.rightAnchor.constraint(equalTo: webViewContainer.rightAnchor).isActive = true
        webView.leftAnchor.constraint(equalTo: webViewContainer.leftAnchor).isActive = true
        webView.bottomAnchor.constraint(equalTo: webViewContainer.bottomAnchor).isActive = true
        webView.heightAnchor.constraint(equalTo: webViewContainer.heightAnchor).isActive = true
        
        //webView.uiDelegate = self
        webView.allowsBackForwardNavigationGestures = true
        webView.navigationDelegate = self
        webView.scrollView.bounces = false
        
        webView.load(URLRequest(url: url, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,timeoutInterval: 180))
    }
    
    
}

//MARK: Custom function
extension StripeWebPaymentVC {
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        let url = NSURLComponents(string: url)!
        return (url.queryItems! as [NSURLQueryItem]).filter({ (item) in item.name == param }).first?.value
    }
    
    private func handleResponseOfStripe(reloadString: String) {
        if reloadString.lowercased().contains(string: "action=stripe_success") {
            self.alert(title: "", message: "Payment is successfull".localized) {
//                NotificationCenter.default.post(name: .stripePaymentHandler, object: ["paymentDone":false])
                NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        else if reloadString.lowercased().contains(string: "action=stripe_fail"){
            self.alert(title: "", message: "Payment failed".localized) {
//                NotificationCenter.default.post(name: .stripePaymentHandler, object: ["paymentDone":false])
                NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
                self.navigationController?.popToRootViewController(animated: true)
            }
        }
        
        /*
         if reloadString.lowercased().range(of: "action=") != nil {
         let action = self.getQueryStringParameter(url: reloadString, param: "action") ?? ""
         if action.lowercased() == "payment_complete" {
         let depositAmount = self.getQueryStringParameter(url: reloadString, param: "amount") ?? ""
         let txn_id = self.getQueryStringParameter(url: reloadString, param: "txn_id") ?? ""
         if !(txn_id.isEmpty) || !(depositAmount.isEmpty) {
         //self.despositFund(transactionId:txn_id!, amount: depositAmount!)
         //TODO: Call deposite func API
         
         }
         }
         else if action.lowercased() == "fail" {
         self.alert(title: "", message: "Payment failed") {
         self.navigationController?.popViewController(animated: true)
         }
         }
         
         }
         else if reloadString.lowercased().range(of: "failed") != nil {
         self.alert(title: "", message: "Payment failed") {
         self.navigationController?.popViewController(animated: true)
         }
         }
         */
    }
    
}

//https://stackoverflow.com/questions/37509990/migrating-from-ui_webview-to-wkwebview
extension StripeWebPaymentVC: /*WKUIDelegate*/ WKNavigationDelegate{
    
    //Equivalent of webViewDidStartLoad:
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //print(String(describing: webView.url))
    }
    
    
    //Equivalent of shouldStartLoadWithRequest :
    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
        let action: WKNavigationActionPolicy = .allow
        defer {decisionHandler(action)}
        
        guard let url = navigationAction.request.url else { return }
        print("url: \(url)")
        self.handleResponseOfStripe(reloadString: url.absoluteString)
        
        /*
         //1
         if navigationAction.navigationType == .linkActivated, url.absoluteString.hasPrefix("https://www.google.com/") {
         action = .cancel                  // Stop in WebView
         UIApplication.shared.openURL(url) // Open in Safari
         }
         */
        
        //2
        /*
         switch navigationAction.navigationType {
         case .linkActivated:
         if navigationAction.targetFrame == nil {
         self.webView.load(navigationAction.request)
         }
         if url.absoluteString.hasPrefix("http://www.example.com/open-in-safari") {
         action = .cancel                  // Stop in WebView
         UIApplication.shared.openURL(url) // Open in Safari
         print("url.absoluteString: \(url.absoluteString)")
         }
         default:
         break
         }
         */
    }
    
    //Equivalent of didFailLoadWithError:
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation, withError error: Error) {
        print("webView:\(webView) didFailNavigation:\(navigation) withError:\(error)")
        let nserror = error as NSError
        if nserror.code != NSURLErrorCancelled {
            webView.loadHTMLString("404 - Page Not Found", baseURL: URL(string: "http://www.example.com/"))
            //webView.loadHTMLStrin
        }
    }
    
    //Equivalent of webViewDidFinishLoad:
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        //print(String(describing: webView.url))
        activityIndicator.stopAnimating()
    }
    
}


