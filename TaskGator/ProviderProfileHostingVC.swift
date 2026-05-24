//
//  ProviderProfileHostingVC.swift
//  TaskGator
//
//  UIKit container for the SwiftUI ProviderProfileView.
//  Replaces ProviderProfileVC.storyboardInstance in the tab bar.
//

import UIKit
import SwiftUI
import MessageUI

final class ProviderProfileHostingVC: NewBaseViewController {

    private let vm = ProviderProfileViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = Color.Theme.purple
        wireCallbacks()
        embedView()
        checkVersion()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onProfileChanged(_:)),
            name: .isChangeProfile,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        vm.loadProfile()
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK: - Setup

private extension ProviderProfileHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: ProviderProfileView(viewModel: vm))
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
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onEditTapped = { [weak self] in
            guard let self else { return }
            let vc = EditProfileProviderHostingVC()
            vc.providerData = vm.profile
            vc.hidesBottomBarWhenPushed = true
            navigationController?.pushViewController(vc, animated: true)
        }
        vm.onViewAllReviews = { [weak self] in
            self?.navigationController?.pushViewController(ReviewList.storyboardInstance!, animated: true)
        }
        vm.onSendEmail = { [weak self] email in
            self?.sendEmail(to: email)
        }
        vm.onCallPhone = { [weak self] phone in
            self?.callOn(PhoneNumber: phone)
        }
    }

    func checkVersion() {
        Task { [weak self] in
            guard let self else { return }
            do {
                let dict = try await APIClient.shared.getSiteSettings()
                let data = dict["data"] as? [String: Any] ?? [:]
                if let app_version = data["app_version"] as? String,
                   let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String,
                   let web = Double(app_version), let app = Double(version), app < web,
                   let storeUrl = data["store_url"] as? String,
                   storeUrl.contains(string: "apps.apple.com/app") {
                    await MainActor.run { Util.showUpgradeBox(vc: self, storeUrl: storeUrl) }
                }
            } catch {}
        }
    }

    @objc func onProfileChanged(_ notification: Notification) {
        if (notification.object as? [String: Any])?["isChangeProfile"] as? Bool == true {
            vm.loadProfile()
        }
    }
}

// MARK: - Email

extension ProviderProfileHostingVC: MFMailComposeViewControllerDelegate {

    func sendEmail(to email: String) {
        guard MFMailComposeViewController.canSendMail() else {
            alert(title: "Error".localized, message: "Can't send mail".localized)
            return
        }
        let mail = MFMailComposeViewController()
        mail.mailComposeDelegate = self
        mail.setToRecipients([email])
        present(mail, animated: true)
    }

    func mailComposeController(_ controller: MFMailComposeViewController,
                               didFinishWith result: MFMailComposeResult,
                               error: Error?) {
        controller.dismiss(animated: true)
    }
}
