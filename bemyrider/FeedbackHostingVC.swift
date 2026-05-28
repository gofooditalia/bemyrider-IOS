//
//  FeedbackHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI FeedbackView.
//  Replaces FeedBackVC.storyboardInstance in the menu flow.
//

import UIKit
import SwiftUI

final class FeedbackHostingVC: NewBaseViewController {

    private let vm = FeedbackViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Setup

private extension FeedbackHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: FeedbackView(viewModel: vm))
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
}
