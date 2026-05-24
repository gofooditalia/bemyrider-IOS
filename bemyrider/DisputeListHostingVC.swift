//
//  DisputeListHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI DisputeListView.
//  Replaces DisputeListVC.storyboardInstance in the menu flow.
//

import UIKit
import SwiftUI

final class DisputeListHostingVC: NewBaseViewController {

    private let vm = DisputeListViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }
        vm.onTapDispute = { [weak self] dispute in
            self?.openDisputeDetail(dispute)
        }
        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Setup

private extension DisputeListHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: DisputeListView(viewModel: vm))
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

    func openDisputeDetail(_ dispute: Dispute) {
        let nextVC = DisputeDetailHostingVC()
        nextVC.disputeObj = dispute
        nextVC.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(nextVC, animated: true)
    }
}
