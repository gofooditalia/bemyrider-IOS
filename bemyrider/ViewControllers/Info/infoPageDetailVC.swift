//
//  infoPageDetailVC.swift
//  bemyrider
//
//  Created by admin on 2/25/19.
//  Copyright © 2019 NCT 24. All rights reserved.
//

import UIKit
import WebKit

class infoPageDetailVC: NewBaseViewController{

    //MARK: Properties
    static var storyboardInstance:infoPageDetailVC? {
        return StoryBoard.singleViews.instantiateViewController(withIdentifier: infoPageDetailVC.identifier) as? infoPageDetailVC
    }
    
    var urlString = String()
    var navTitle:String?
    
    //    MARK: ViewController Method
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
        let webView = WKWebView(frame: CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height))
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        //let url = URL(string: "https://www.google.com")
        if urlString != "" {
            let url = URL(string: urlString)
            webView.load(URLRequest(url: url!))
        }
    }
}

//MARK: Custom function
extension infoPageDetailVC {
    func setUpUI() {
//        setUpNavigation(vc: self, isBackButton: true, btnTitle: "", navigationTitle: navTitle ?? "", action: #selector(onClickMenu(_:)))
        self.applyStatusbar(color: Color.Theme.purple)
        self.setupNavigationBar(title: navTitle ?? "", isBack: true, rightButton: false)
    }
    
    @objc func onClickMenu(_ sender: UIButton){
        //sideMenuController?.showLeftView(animated: true, completionHandler: nil)
        self.navigationController?.popViewController(animated: true)
    }
}
extension infoPageDetailVC: /*WKUIDelegate*/ WKNavigationDelegate{
    
    //Equivalent of webViewDidStartLoad:
    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        //print(String(describing: webView.url))
    }
    
    //Equivalent of shouldStartLoadWithRequest :
    //    func webView(_ webView: WKWebView, decidePolicyFor navigationAction: WKNavigationAction, decisionHandler: @escaping (WKNavigationActionPolicy) -> Void) {
    //        //AppHelper.showLoadingView()
    //        var action: WKNavigationActionPolicy?
    //        defer {decisionHandler(action ?? .allow)}
    //
    //        guard let url = navigationAction.request.url else { return }
    //        print("url: \(url)")
    //        self.handleResponseOfPayPal(reloadString: url.absoluteString)
    //
    //    }
    
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
        webView.evaluateJavaScript("var element = document.getElementsByTagName('header'), index;for (index = element.length - 1; index >= 0; index--) {element[index].parentNode.removeChild(element[index]);}", completionHandler: nil)
        webView.evaluateJavaScript("var element = document.getElementsByTagName('footer'), index;for (index = element.length - 1; index >= 0; index--) {element[index].parentNode.removeChild(element[index]);}", completionHandler: nil)
    }
    
}
