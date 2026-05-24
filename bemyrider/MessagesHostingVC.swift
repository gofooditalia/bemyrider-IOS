//
//  MessagesHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI MessagesView.
//  Handles navigation to ChatVC and ChatDelegate refresh.
//

import UIKit
import SwiftUI

final class MessagesHostingVC: UIViewController {

    private let vm = MessagesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.16, green: 0.13, blue: 0.40, alpha: 1)
        vm.presentingVC = self
        vm.onTapMessage = { [weak self] msg in self?.openChat(msg) }
        embedView()

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onMessageSent(_:)),
            name: .sendMessgae,
            object: nil
        )
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
        vm.refresh()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    @objc private func onMessageSent(_ notification: Notification) {
        if (notification.object as? [String: Any])?["sendMessgae"] as? Bool == true {
            vm.refresh()
        }
    }
}

// MARK: - Setup

private extension MessagesHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: MessagesView(viewModel: vm))
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

    func openChat(_ msg: MessageList) {
        guard let user = UserData.shared.getUser() else { return }
        let param: [String: Any] = [
            "from_user_id": user.user_id,
            "to_user_id": msg.to_user,
            "service_master_id": msg.service_master_id
        ]
        let chatVC = ChatHostingVC()
        chatVC.param = param
        chatVC.service_name = msg.service_name
        chatVC.delegate = self
        chatVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(chatVC, animated: true)
    }
}

// MARK: - ChatDelegate

extension MessagesHostingVC: ChatDelegate {

    func refreshMessageList() {
        vm.refresh()
    }
}
