//
//  SplashVC.swift
//  TaskGator
//
//  Created by NCT 24 on 25/07/18.
//  Copyright © 2018 NCT 24. All rights reserved.
//

import UIKit
import SwiftUI

class SplashVC: UIViewController {

    static var storyboardInstance:SplashVC {
        return StoryBoard.main.instantiateViewController(withIdentifier: SplashVC.identifier) as! SplashVC
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        if #available(iOS 13.0, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = Color.Theme.purple
            appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
            appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
            self.navigationController?.navigationBar.standardAppearance = appearance
            self.navigationController?.navigationBar.scrollEdgeAppearance = self.navigationController?.navigationBar.standardAppearance
            self.navigationController?.navigationBar.compactAppearance = self.navigationController?.navigationBar.standardAppearance

        } else {
            // Fallback on earlier versions
        }

        if #available(iOS 15, *) {
            let navigationBarAppearance = UINavigationBarAppearance()
            navigationBarAppearance.configureWithOpaqueBackground()
            navigationBarAppearance.titleTextAttributes = [
                NSAttributedString.Key.foregroundColor : UIColor.white
            ]
            navigationBarAppearance.backgroundColor = Color.Theme.purple
            UINavigationBar.appearance().standardAppearance = navigationBarAppearance
            UINavigationBar.appearance().compactAppearance = navigationBarAppearance
            UINavigationBar.appearance().scrollEdgeAppearance = navigationBarAppearance
        }

        showBootAnimation()
    }

    private func showBootAnimation() {
        view.backgroundColor = UIColor(red: 0.239, green: 0.231, blue: 0.420, alpha: 1)

        let splashView = SplashAnimationView { [weak self] in
            self?.redirectToVC()
        }
        let hostingController = UIHostingController(rootView: splashView)
        hostingController.view.backgroundColor = UIColor.clear
        hostingController.view.translatesAutoresizingMaskIntoConstraints = false
        addChildViewController(hostingController)
        view.addSubview(hostingController.view)
        NSLayoutConstraint.activate([
            hostingController.view.topAnchor.constraint(equalTo: view.topAnchor),
            hostingController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            hostingController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            hostingController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        hostingController.didMove(toParentViewController: self)
    }

}

//Custom functions
extension SplashVC{
    
    @objc func splashTimeOut(sender : Timer){
        redirectToVC()
    }
    
    private func redirectToVC(){
        
        if  !UserData.shared.isFirstTimeAppLaunch{
            let view = OnboardingView {
                UserData.shared.setisFirstTimeApp(launch: true)
                Modal.sharedAppdelegate.rootToHome()
            }
            let vc = UIHostingController(rootView: view)
            Modal.sharedAppdelegate.window?.rootViewController = vc
            Modal.sharedAppdelegate.window?.makeKeyAndVisible()
        }else{
            // Verify User already login or not.
            if UserData.shared.languageID.isEmpty{
                self.navigationController?.pushViewController(LanuguageVC.storyboardInstance!, animated: false)
            }else{
                // Fallback: se l'auto-login non risponde entro 8s navighiamo comunque
                var didNavigate = false
                let fallback = DispatchWorkItem { [weak self] in
                    guard !didNavigate else { return }
                    didNavigate = true
                    print("========AutoLogin timeout fallback")
                    Modal.sharedAppdelegate.rootToHome()
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 8.0, execute: fallback)

                callAutoLogin(failer: {
                    fallback.cancel()
                    guard !didNavigate else { return }
                    didNavigate = true
                    print("========AutoLogin fail")
                    Modal.sharedAppdelegate.rootToHome()
                }) { [weak self] in
                    fallback.cancel()
                    guard !didNavigate else { return }
                    didNavigate = true
                    guard let self = self else { return }
                    let user = UserData.shared.getUser()!
                    let onboardingStep = UserData.shared.onboardingCompletedStep

                    if user.user_type == "c"{
                        let profileIncomplete = user.first_name.isBlank || user.last_name.isBlank || user.contact_number.isBlank
                        if profileIncomplete {
                            if onboardingStep < 0 { UserData.shared.setOnboardingCompletedStep(0) }
                            self.getCustomerProfile()
                        } else if onboardingStep >= 0 && onboardingStep < 1 {
                            self.getCustomerProfile()
                        } else {
                            Modal.sharedAppdelegate.rootToHome()
                        }
                    }else{
                        let profileIncomplete = user.first_name.isBlank || user.last_name.isBlank || user.contact_number.isBlank || user.tax_id.isBlank
                        if profileIncomplete {
                            if onboardingStep < 0 { UserData.shared.setOnboardingCompletedStep(0) }
                            self.getProviderProfile()
                        } else if onboardingStep >= 0 && onboardingStep < 3 {
                            self.getProviderProfile()
                        } else {
                            Modal.sharedAppdelegate.rootToHome()
                        }
                    }
                }
            }
        }
    }
}

//API functions
extension SplashVC{
    func callAutoLogin(failer:@escaping() -> () , success:@escaping() -> ()) {
        if let userData = UserData.shared.getUserLoginData(){
            if UserData.shared.isSocialLogin{ //Socila login
                Modal.shared.autoLoginAfterSocial(email: userData.email, failer: { (err) in
                    //"Response status code was unacceptable: 404."
                    print("Erro:\(err)")
                    if err != "The Internet connection appears to be offline." || err != "Could not connect to the server."{
                        UserData.shared.logoutUser()
                        failer()
                    }
                }) { (dic) in
                    print(dic)
                    let data = ResponseKey.fatchData(res: dic, valueOf: .data).dic
                    _ = UserData.shared.setUser(dic: data)
                    success()
                }
            }else{
                Modal.shared.autoLogin(param: ["email": userData.email, "password": userData.password], failer: { (err) in
                    if err != "The Internet connection appears to be offline." || err != "Could not connect to the server." || err == "Your account is deactivated" {
                        UserData.shared.logoutUser()
                        //let nextVC = LoginVC.storyboardInstance!
                        //self.navigationController?.pushViewController(nextVC, animated: false)
                        //                        self.navigationController?.popToRootViewController(animated: false)
                        failer()
                    }
                }) { (dic) in
                    print(dic)
                    let data = ResponseKey.fatchData(res: dic, valueOf: .data).dic
                    let _ = UserData.shared.setUser(dic: data)
                    if let isUserActive = data["isUserActive"] as? String {
                        if isUserActive.lowercased() == "d" {
                            failer()
                            return
                        }
                    }
                    success()
                }
            }
        }
        else {
            //            let nextVC = LoginVC.storyboardInstance!
            //            self.navigationController?.pushViewController(nextVC, animated: false)
            Modal.sharedAppdelegate.rootToHome()
        }
    }
    
    func getProviderProfile() {
        Modal.shared.getUserProfile(vc: self, param: ["profile_id":UserData.shared.getUser()!.user_id
                                                     ]) { (dic) in
            let data = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            
            //Update userdefault values
            let userDic = UserData.shared.getUser()!
            userDic.first_name = data!.firstName
            userDic.last_name = data!.lastName
            userDic.user_name = data!.user_name
            userDic.profile_img = data!.profile_img
            _ = UserData.shared.setUser(dic: userDic.dictionary)
            
            let onboardingVC = FirstLoginOnboardingHostingVC()
            onboardingVC.userType = "p"
            onboardingVC.profileData = data
            onboardingVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(onboardingVC, animated: true)

        }
    }

    func getCustomerProfile() {
        //if Modal.sharedAppdelegate.isCustomerLogin {
        let param:[String:Any] = ["profile_id":UserData.shared.getUser()!.user_id]
        Modal.shared.getUserProfile(vc: self, param: param , failer: { (err) in
            print(err)
        }) { (dic) in
            let data = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            //Update userdefault values
            let userDic = UserData.shared.getUser()!
            userDic.first_name = data!.firstName
            userDic.last_name = data!.lastName
            userDic.user_name = data!.user_name
            userDic.profile_img = data!.profile_img
            _ = UserData.shared.setUser(dic: userDic.dictionary)

            let onboardingVC = FirstLoginOnboardingHostingVC()
            onboardingVC.userType = "c"
            onboardingVC.profileData = data
            onboardingVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(onboardingVC, animated: true)
            
        }
        
    }
}
