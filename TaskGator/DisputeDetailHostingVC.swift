//
//  DisputeDetailHostingVC.swift
//  bemyrider
//

import UIKit
import SwiftUI

final class DisputeDetailHostingVC: NewBaseViewController {

    private let vm = DisputeDetailViewModel()

    var disputeObj: Dispute? {
        didSet { vm.dispute = disputeObj }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.24, green: 0.24, blue: 0.44, alpha: 1)

        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        embedView()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }

    private func embedView() {
        let child = UIHostingController(rootView: DisputeDetailView(viewModel: vm))
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
