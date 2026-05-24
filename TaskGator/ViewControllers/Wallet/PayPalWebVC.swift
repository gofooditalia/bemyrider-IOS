//
//  PayPalWebVC.swift
//  TaskGator
//
//  Created by NCT 24 on 30/06/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import WebKit

extension Notification.Name{
    static let paymentProcessDone = Notification.Name("paymentProcessDone")
    static let stripePaymentHandler = Notification.Name("StripePaymentHandler")
}

class PayPalWebVC: NewBaseViewController {

    static var storyboardInstance:PayPalWebVC? {
        return StoryBoard.wallet.instantiateViewController(withIdentifier: PayPalWebVC.identifier) as? PayPalWebVC
    }
    
    @IBOutlet var activityIndicator: UIActivityIndicatorView!
    
    @IBOutlet weak var webViewContainer: UIView!
    //@IBOutlet weak var webView: WKWebView!
    //Erorr when you implementedfrom storyboard
    
    var amount:String!
    var deposit_commission:String?
    var service_id:String?
    
    var webView: WKWebView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        
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
        self.openUrl()
    }
    

}

//MARK: Custom function
extension PayPalWebVC {
    
    func openUrl() {
        let url = URL(string: Domain.getPayPalUrl(amount: amount, deposit_commission: deposit_commission, service_id: service_id))!
        webView.load(URLRequest(url: url))
    }
    
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: "Payment".localized, action: #selector(onClickMenu(_:)))
        self.setupNavigationBar(title: "Payment".localized, isBack: true)

    }
    
    @objc func onClickMenu(_ sender: UIButton){
        self.navigationController?.popViewController(animated: true)
    }
    
    
    private func getQueryStringParameter(url: String, param: String) -> String? {
        let url = NSURLComponents(string: url)!
        return (url.queryItems! as [NSURLQueryItem]).filter({ (item) in item.name == param }).first?.value
    }
    
    private func handleResponseOfPayPal(reloadString: String) {
        if reloadString.lowercased().contains(string: "success.php") {
//            DispatchQueue.main
            NotificationCenter.default.post(name: .stripePaymentHandler, object: ["paymentDone":true])
//            self.navigationController?.popViewController(animated: true)
                self.goToWallet()
        }
        else if reloadString.lowercased().contains(string: "cancel.php"){
            self.alert(title: "", message: "Payment failed".localized) {
                NotificationCenter.default.post(name: .stripePaymentHandler, object: ["paymentDone":false])
                self.navigationController?.popViewController(animated: true)
//                self.goToWallet()
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
    
    func goToWallet(){
        for controller in self.navigationController!.viewControllers {
            if controller.isKind(of: MyWalletVC.self) {
                let walletVC = controller as! MyWalletVC
                self.navigationController?.popToViewController(controller, animated: true)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5, execute: {
                    walletVC.callInitialAPIs()
                })
                
                break
            }
        }
    }
}

//https://stackoverflow.com/questions/37509990/migrating-from-ui_webview-to-wkwebview
extension PayPalWebVC: /*WKUIDelegate*/ WKNavigationDelegate{
    
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
        self.handleResponseOfPayPal(reloadString: url.absoluteString)
        
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

