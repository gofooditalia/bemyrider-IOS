//
//  SignUpHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI SignUpView.
//  Drop-in replacement for SignUpVC — can be used wherever
//  SignUpVC.storyboardInstance was pushed/set as root.
//

import UIKit
import SwiftUI

final class SignUpHostingVC: UIViewController {

    private let vm: SignUpViewModel

    /// Normal registration (no social data)
    init() {
        vm = SignUpViewModel()
        super.init(nibName: nil, bundle: nil)
    }

    /// Social registration — pre-fills fields from the social login response
    init(socialData: UserSocialData, socialUserId: String) {
        vm = SignUpViewModel()
        vm.isSocialLogin = true
        vm.socialUserId  = socialUserId
        vm.firstName     = socialData.first_name
        vm.lastName      = socialData.last_name
        vm.email         = socialData.email_id
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) { fatalError() }

    override func viewDidLoad() {
        super.viewDidLoad()
        wireViewModel()
        embedSignUpView()
    }
}

// MARK: - Setup

private extension SignUpHostingVC {

    func wireViewModel() {
        vm.onLoginTapped = { [weak self] in
            self?.navigationController?.pushViewController(LoginHostingVC(), animated: true)
        }
        vm.onSignUpSuccess = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onContactUsTapped = { [weak self] in
            if let vc = ContactUsVC.storyboardInstance {
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
        vm.onInfoTapped = { [weak self] in
            if let vc = infoPageListVC.storyboardInstance {
                self?.navigationController?.pushViewController(vc, animated: true)
            }
        }
    }

    func embedSignUpView() {
        let child = UIHostingController(rootView: SignUpView(viewModel: vm))
        child.view.backgroundColor = UIColor.clear
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
