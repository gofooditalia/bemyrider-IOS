//
//  BaseViewController.swift
//  TaskGator
//
//  Created by Nirav Sapariya 24 on 07/04/18.
//  Copyright © 2018 NMS. All rights reserved.
//

import UIKit

class BaseViewController: UIViewController {
    
    var sharedAppdelegate:AppDelegate {
        get{
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    var navigationBar: NavigationBarView!
    var statusBar: StatusBarView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        statusBar = StatusBarView.loadNib()
        self.view.addSubview(self.statusBar)
        navigationBar = NavigationBarView.loadNib()
        self.view.addSubview(self.navigationBar)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        let statusBarHeight = self.view.window?.windowScene?.statusBarManager?.statusBarFrame.height ?? 0
        self.statusBar.frame = CGRect(x: 0, y: 0, width: self.view.frame.width, height: statusBarHeight)
        self.statusBar.bringToFront()
        self.navigationBar.frame = CGRect(x: 0, y: statusBarHeight, width: self.view.frame.width, height: 50)
        self.navigationBar.bringToFront()
        self.view.layoutIfNeeded()
    }
    
    func setUpNavigation(vc:UIViewController, isBackButton:Bool = false, btnTitle:String = "", navigationTitle:String, action: Selector, isRightBtn:Bool = false, actionRight: Selector = #selector(onClickRightBtn(_:)), btnRightImg:UIImage = #imageLiteral(resourceName: "ic_account_settings")) {
        if isBackButton{
            navigationBar.btnMenu.setImage(#imageLiteral(resourceName: "ic_back"), for: .normal)
        }
        else{
            navigationBar.btnMenu.setImage(#imageLiteral(resourceName: "hamburger-icon"), for: .normal)
        }
        navigationBar.btnMenu.addTarget(vc, action:action, for: .touchUpInside)
        navigationBar.btnMenu.setTitle((btnTitle.isEmpty ? nil : btnTitle), for: .normal)
        navigationBar.btnMenu.setTitleColor(Color.white, for: .normal)
        navigationBar.lblTitle.text = navigationTitle
        
        //RightButton
        navigationBar.btnRight.setImage(btnRightImg, for: .normal)
        navigationBar.btnRight.addTarget(vc, action:actionRight, for: .touchUpInside)
        navigationBar.btnRight.isHidden = !isRightBtn
        
    }
    @objc func onClickRightBtn(_ sender: UIButton) {
        print("Right Click form parent")
    }
}


class NewBaseViewController: UIViewController {
    
    var sharedAppdelegate:AppDelegate {
        get{
            return UIApplication.shared.delegate as! AppDelegate
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor =  .white//Color.Theme.background
    }
    
    
    @objc func onClickRightBtn(_ sender: UIButton) {
        print("Right Click form parent")
    }
    
    func applyStatusbar(color:UIColor) {
        let statusBarFrame: CGRect
        if #available(iOS 13.0, *) {
            statusBarFrame = self.sharedAppdelegate.window?.windowScene?.statusBarManager?.statusBarFrame ?? CGRect.zero
        } else {
            statusBarFrame = UIApplication.shared.statusBarFrame
        }
        let statusBarView = UIView(frame: statusBarFrame)
        statusBarView.backgroundColor = color
        view.addSubview(statusBarView)
    }
    
    
    func setupNavigationBar(title: String = "", isBack: Bool = true,rightButton:Bool = false,rightBtnImage:UIImage = #imageLiteral(resourceName: "ic_back")) { //,action: Selector) {
        self.navigationController?.navigationBar.isHidden = false
        self.navigationController?.navigationBar.backgroundColor = Color.Theme.purple
        let leftSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
        leftSpace.width = 10.0
        
        
        
        if title != "" {
            self.navigationItem.title = title
            self.navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.font : RobotoFont.medium(with: 16),
                                                                            NSAttributedString.Key.foregroundColor : UIColor.white,
                                                                            ]
        }
        
        
        let backBtn = UIButton(type: UIButton.ButtonType.custom)
        //        logoBtn.frame = CGRect(x: 0, y: 0, width: 183, height: 30)
        backBtn.frame = CGRect(x: 0, y: 0, width: 26, height: 26)
        backBtn.tintColor = .white
        backBtn.setBackgroundImage(UIImage(named: "ic_back"), for: UIControl.State())
        backBtn.addTarget(self, action: #selector(didTapBackButton(sender:)), for: .touchUpInside)
        //        backBtn.isUserInteractionEnabled = false
        
        if rightButton{
            let rightSpace = UIBarButtonItem(barButtonSystemItem: .fixedSpace, target: nil, action: nil)
            
            let searchImage = UIImage(named: "ic_account_settings")!
            let searchButton = UIBarButtonItem(image: searchImage,  style: .plain, target: self, action: #selector(didTapRightButton(sender:)))
            searchButton.tintColor = .white
            navigationItem.rightBarButtonItems = [rightSpace, searchButton]
        }
        
        if isBack{
            let logoButtonItem = UIBarButtonItem(customView: backBtn)
            navigationItem.leftBarButtonItems = [leftSpace, logoButtonItem]
        }
        
    }
    
    @objc func didTapRightButton(sender: AnyObject){
        let vc = NotificationSettings.storyboardInstance!
        vc.hidesBottomBarWhenPushed = true
        self.navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapBackButton(sender: AnyObject){
        self.navigationController?.popViewController(animated: true)
    }
    
    @objc func onClickSkip() {
        UserData.shared.setisFirstTimeApp(launch: true)
        self.sharedAppdelegate.rootToHome()
    }
    
    
    
    func popToViewController<T:UIViewController>(type: T.Type, animated: Bool){
        for vc in self.navigationController?.viewControllers ?? []{
            print("\(vc) ==? \(T.self)")
            if vc is T{
                self.navigationController?.popToViewController(vc, animated: animated);break
            }
        }
    }
    
    func getViewController<T:UIViewController>(type: T.Type) -> UIViewController?{
        for vc in self.navigationController?.viewControllers ?? []{
            print("\(vc) ==? \(T.self)")
            if vc is T{
                return vc
            }
        }
        return nil
    }
}

