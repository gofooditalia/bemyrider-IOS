//
//  FinancialInfoHostingVC.swift
//  TaskGator
//
//  UIKit container for the SwiftUI FinancialInfoView.
//

import UIKit
import SwiftUI

final class FinancialInfoHostingVC: NewBaseViewController {
    
    private let vm = FinancialInfoViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.presentingVC = self
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
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

private extension FinancialInfoHostingVC {
    
    func embedView() {
        let child = UIHostingController(rootView: FinancialInfoView(viewModel: vm))
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
