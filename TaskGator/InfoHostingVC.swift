//
//  InfoHostingVC.swift
//  TaskGator
//
//  UIKit container for the SwiftUI InfoView.
//  Replaces infoPageListVC.storyboardInstance in the menu flow.
//

import UIKit
import SwiftUI
import SafariServices

final class InfoHostingVC: NewBaseViewController {

    private let vm = InfoViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onTapPage = { [weak self] page in
            self?.openInfoDetail(page)
        }
        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Setup

private extension InfoHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: InfoView(viewModel: vm))
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

    func openInfoDetail(_ page: infoData) {
        guard let url = URL(string: page.pageUrl) else { return }
        let safariVC = SFSafariViewController(url: url)
        present(safariVC, animated: true)
    }
}
