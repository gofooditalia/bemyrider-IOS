//
//  NotificationsHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI NotificationsView.
//  Pushed from MenuHostingVC.
//

import UIKit
import SwiftUI

final class NotificationsHostingVC: NewBaseViewController {

    private let vm = NotificationsViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onSettings = { [weak self] in
            self?.navigationController?.pushViewController(NotificationSettingsHostingVC(), animated: true)
        }
        vm.onTapNotification = { [weak self] notif in
            self?.handleTap(notif)
        }
        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        vm.refresh()
    }
}

// MARK: - Setup

private extension NotificationsHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: NotificationsView(viewModel: vm))
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

    func handleTap(_ notif: NotificationCls.NotificationList) {
        guard notif.isactive.lowercased() != "du" else { return }

        let userType = notif.user_type
        switch notif.notification_type {
        case "r" where userType == "c":
            navigationController?.pushViewController(ReviewList.storyboardInstance!, animated: true)
        case "d" where userType == "c":
            navigationController?.pushViewController(DisputeListVC.storyboardInstance!, animated: true)
        case "m" where userType == "c":
            navigationController?.pushViewController(MessagesHostingVC(), animated: true)
        case "s" where userType == "c":
            navigationController?.pushViewController(ServiceRequestHostingVC(), animated: true)
        default:
            break
        }
    }
}
