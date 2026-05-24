//
//  MenuHostingVC.swift
//  TaskGator
//
//  UIKit container for the SwiftUI MenuView.
//  Handles all navigation from menu items.
//

import UIKit
import SwiftUI

final class MenuHostingVC: UIViewController {

    private let vm = MenuViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        wireCallbacks()
        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        vm.loadUserData()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

// MARK: - Setup

private extension MenuHostingVC {

    func embedView() {
        view.backgroundColor = UIColor(red: 62/255, green: 62/255, blue: 112/255, alpha: 1)

        let child = UIHostingController(rootView: MenuView(viewModel: vm))
        child.view.backgroundColor = .clear
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

    func wireCallbacks() {
        vm.onEditProfile  = { [weak self] in self?.handleEditProfile() }
        vm.onViewProfile  = { [weak self] in self?.handleViewProfile() }
        vm.onShareProfile = { [weak self] in self?.handleShareProfile() }
        vm.onMenuTap      = { [weak self] type in self?.handleMenuTap(type) }
    }

    // MARK: - Profile

    func handleEditProfile() {
        guard let user = UserData.shared.getUser() else { return }
        Modal.shared.getUserProfile(vc: self, param: ["profile_id": user.user_id]) { [weak self] dic in
            guard let self = self else { return }
            let data = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            if user.user_type == "c" {
                let vc = EditProfileCustomerHostingVC()
                vc.passUserData = data
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = EditProfileProviderHostingVC()
                vc.providerData = data
                vc.hidesBottomBarWhenPushed = true
                self.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func handleViewProfile() {
        guard let user = UserData.shared.getUser() else { return }
        if user.user_type == "c" {
            let vc = CustomerProfileHostingVC()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        } else {
            // Provider: switch to profile tab (index 2)
            if let tab = Modal.sharedAppdelegate.window?.rootViewController as? UITabBarController {
                tab.selectedIndex = 2
            }
        }
    }

    // MARK: - Share Profile

    func handleShareProfile() {
        guard let user = UserData.shared.getUser() else { return }
        let profileURL = "https://bemyrider.it/rider?id=\(user.user_id)"
        let text = "Ciao! Prenota il mio servizio su Bemyrider: \(profileURL)"
        let activityVC = UIActivityViewController(activityItems: [text], applicationActivities: nil)
        activityVC.popoverPresentationController?.sourceView = self.view
        self.present(activityVC, animated: true)
    }

    // MARK: - Menu tap routing

    func handleMenuTap(_ type: MenuOption) {
        switch type {
        case .notifications:
            let vc = NotificationsHostingVC()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case .resolutionCenter:
            let vc = DisputeListHostingVC()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case .paymentHistory:
            if let user = UserData.shared.getUser(), user.user_type == "p" {
                let vc = ProviderPaymentHistoryHostingVC()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            } else {
                let vc = PaymentHistoryHostingVC()
                vc.hidesBottomBarWhenPushed = true
                navigationController?.pushViewController(vc, animated: true)
            }

        case .accountSetting:
            let vc = AccountSettingHostingVC()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case .information:
            let vc = InfoHostingVC()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case .feedback:
            let vc = FeedbackHostingVC()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case .contactUs:
            let vc = ContactUsHostingVC()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case .stripe:
            let vc = StripeConnectWebVC.storyboardInstance
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case .myServices:
            let vc = MyServicesHostingVC()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case .financialInfo:
            let vc = FinancialInfoHostingVC()
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)

        case .login:
            navigationController?.pushViewController(LoginHostingVC(), animated: true)

        case .logout:
            confirmLogout()
        }
    }

    // MARK: - Logout

    func confirmLogout() {
        let alert = UIAlertController(
            title: "Alert",
            message: "Sei sicuro di voler uscire dall'applicazione?",
            preferredStyle: .alert
        )
        alert.addAction(UIAlertAction(title: "Ok", style: .destructive) { [weak self] _ in
            guard let self = self, let user = UserData.shared.getUser() else { return }
            let param: [String: Any] = [
                "user_id": user.user_id,
                "device_token": UserData.shared.deviceToken
            ]
            Modal.shared.logOut(vc: self, param: param) { _ in
                UserData.shared.logoutUser()
                Modal.sharedAppdelegate.rootToHome()
            }
        })
        alert.addAction(UIAlertAction(title: "Annulla", style: .cancel))
        present(alert, animated: true)
    }
}
