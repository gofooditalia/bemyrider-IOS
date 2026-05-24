//
//  CustomerProfileHostingVC.swift
//  TaskGator
//
//  UIKit container for the SwiftUI CustomerProfileView.
//

import UIKit
import SwiftUI

final class CustomerProfileHostingVC: NewBaseViewController {

    private let vm = CustomerProfileViewModel()

    var customerId: String? {
        didSet {
            vm.customerId = customerId
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onEditTap = { [weak self] in
            self?.openEditProfile()
        }
        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Setup

private extension CustomerProfileHostingVC {

    func embedView() {
        view.backgroundColor = .clear

        let child = UIHostingController(rootView: CustomerProfileView(viewModel: vm))
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

    func openEditProfile() {
        guard let user = UserData.shared.getUser() else { return }
        Modal.shared.getUserProfile(vc: self, param: ["profile_id": user.user_id]) { [weak self] dic in
            guard let self = self else { return }
            let data = UserProfile(dictionary: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            let vc = EditProfileCustomerHostingVC()
            vc.passUserData = data
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
