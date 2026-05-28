//
//  LoginHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI LoginView.
//  Owns the LoginViewModel and handles social-login SDK callbacks,
//  profile routing, and social sign-up forwarding.
//

import UIKit
import SwiftUI
import FacebookLogin
import GoogleSignIn

final class LoginHostingVC: UIViewController {

    private let vm = LoginViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        wireViewModel()
        embedLoginView()
    }
}

// MARK: - Setup

private extension LoginHostingVC {

    func wireViewModel() {
        vm.onSignUpTapped = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onSocialLoginTapped = { [weak self] provider in
            self?.startSocialFlow(for: provider)
        }
        vm.onNeedProviderProfile = { [weak self] in
            self?.getProviderProfile()
        }
        vm.onNeedCustomerProfile = { [weak self] in
            self?.getCustomerProfile()
        }
        vm.onNeedSocialSignUp = { [weak self] data in
            self?.pushSocialSignUp(data: data)
        }
        vm.onChangePasswordTapped = {
            // Navigate to Account Settings after rootToHome has set up the tab bar
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                guard let tabBar = Modal.sharedAppdelegate.window?.rootViewController as? UITabBarController,
                      let nav = tabBar.selectedViewController as? UINavigationController
                          ?? tabBar.viewControllers?.first as? UINavigationController else { return }
                let vc = AccountSettingHostingVC()
                vc.hidesBottomBarWhenPushed = true
                nav.pushViewController(vc, animated: true)
            }
        }
    }

    func embedLoginView() {
        let child = UIHostingController(rootView: LoginView(viewModel: vm))
        addChildViewController(child)
        child.view.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(child.view)
        NSLayoutConstraint.activate([
            child.view.topAnchor.constraint(equalTo: view.topAnchor),
            child.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            child.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            child.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        child.didMove(toParentViewController: self)
    }
}

// MARK: - Social login

private extension LoginHostingVC {

    func startSocialFlow(for provider: SocialProvider) {
        switch provider {
        case .facebook: startFacebookLogin()
        case .google:   startGoogleLogin()
        case .apple:    startAppleLogin()
        }
    }

    // MARK: Facebook

    func startFacebookLogin() {
        LoginManager().logOut()
        if AccessToken.current != nil {
            fetchFBUserData()
        } else {
            let manager = LoginManager()
            manager.logIn(permissions: [.publicProfile, .email], viewController: self) { [weak self] result in
                switch result {
                case .success: self?.fetchFBUserData()
                case .cancelled: break
                case .failed(let error): self?.vm.alertMessage = error.localizedDescription
                }
            }
        }
    }

    func fetchFBUserData() {
        FacebookSignInManager.basicInfoWithCompletionHandler(self) { [weak self] userInfo, error in
            guard let self = self else { return }
            if let error = error { self.vm.alertMessage = error.localizedDescription; return }
            guard let info = userInfo else {
                self.vm.alertMessage = "Something went wrong, please try again."
                return
            }
            let firstName = info["first_name"] as? String ?? ""
            let lastName  = info["last_name"]  as? String ?? ""
            let socialId  = info["id"]         as? String ?? ""
            let email     = info["email"]      as? String ?? ""
            var picture   = ""
            if let pic     = info["picture"] as? [String: Any],
               let picData = pic["data"]     as? [String: Any],
               let url     = picData["url"]  as? String { picture = url }
            Task {
                await self.vm.handleSocialLogin(firstName: firstName, lastName: lastName,
                                               loginType: "f", socialId: socialId,
                                               email: email, picture: picture)
            }
        }
    }

    // MARK: Google

    func startGoogleLogin() {
        GIDSignIn.sharedInstance.signIn(withPresenting: self) { [weak self] result, error in
            guard let self = self else { return }
            guard error == nil, let user = result?.user else {
                if let error = error { self.vm.alertMessage = error.localizedDescription }
                return
            }
            let firstName = user.profile?.givenName  ?? ""
            let lastName  = user.profile?.familyName ?? ""
            let email     = user.profile?.email      ?? ""
            let idToken   = user.idToken?.tokenString ?? ""
            var picture   = ""
            if let url = user.profile?.imageURL(withDimension: 320) { picture = "\(url)" }
            GIDSignIn.sharedInstance.signOut()
            Task {
                await self.vm.handleSocialLogin(firstName: firstName, lastName: lastName,
                                               loginType: "g", socialId: idToken,
                                               email: email, picture: picture)
            }
        }
    }

    // MARK: Apple

    func startAppleLogin() {
        AppleSignInManager.shared.delegate = self
        AppleSignInManager.shared.onClickAppleSignIn()
    }
}

// MARK: - AppleSignInManagerDelegate

extension LoginHostingVC: AppleSignInManagerDelegate {

    func didSuccessLogin(userId: String, firstName: String, lastName: String, email: String) {
        Task {
            await vm.handleSocialLogin(firstName: firstName, lastName: lastName,
                                       loginType: "a", socialId: userId,
                                       email: email, picture: "")
        }
    }

    func didFailedLogin(error: String) {
        vm.alertMessage = error
    }
}

// MARK: - Profile routing

private extension LoginHostingVC {

    func getProviderProfile() {
        let param = ["profile_id": UserData.shared.getUser()!.user_id]
        Modal.shared.getUserProfile(vc: self, param: param) { [weak self] dic in
            guard let self = self else { return }
            let data    = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            let userDic = UserData.shared.getUser()!
            userDic.first_name  = data!.firstName
            userDic.last_name   = data!.lastName
            userDic.user_name   = data!.user_name
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
        let param: [String: Any] = ["profile_id": UserData.shared.getUser()!.user_id]
        Modal.shared.getUserProfile(vc: self, param: param, failer: { _ in }) { [weak self] dic in
            guard let self = self else { return }
            let data    = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            let userDic = UserData.shared.getUser()!
            userDic.first_name  = data!.firstName
            userDic.last_name   = data!.lastName
            userDic.user_name   = data!.user_name
            userDic.profile_img = data!.profile_img
            _ = UserData.shared.setUser(dic: userDic.dictionary)
            let onboardingVC = FirstLoginOnboardingHostingVC()
            onboardingVC.userType = "c"
            onboardingVC.profileData = data
            onboardingVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(onboardingVC, animated: true)
        }
    }

    func pushSocialSignUp(data: [String: Any]) {
        guard let socialData = UserSocialData(dictionary: data) else { return }
        let socialId = data["user_id"] as? String ?? ""
        let vc = SignUpHostingVC(socialData: socialData, socialUserId: socialId)
        navigationController?.pushViewController(vc, animated: true)
    }
}
