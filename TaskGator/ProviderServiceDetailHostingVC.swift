//
//  ProviderServiceDetailHostingVC.swift
//  TaskGator
//
//  UIKit container for the SwiftUI ProviderServiceDetailView.
//

import UIKit
import SwiftUI

final class ProviderServiceDetailHostingVC: NewBaseViewController {
    
    var serviceDetail: ProviderServiceDetail?
    var providerService: ProviderService?
    
    private let vm = ProviderServiceDetailViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.presentingVC = self
        vm.serviceDetail = serviceDetail
        vm.providerService = providerService

        embedView()
        wireCallbacks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Setup

private extension ProviderServiceDetailHostingVC {
    
    func embedView() {
        let child = UIHostingController(rootView: ProviderServiceDetailView(viewModel: vm))
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
        
        vm.onEditService = { [weak self] in
            guard let self = self else { return }
            let vc = AddServiceHostingVC()
            vc.editServiceDetail = self.vm.serviceDetail
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
        
        vm.onDeleteService = { [weak self] in
            guard let self = self else { return }
            let alert = UIAlertController(
                title: "",
                message: "Are you sure you want to delete this service?".localized,
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Cancel".localized, style: .cancel))
            alert.addAction(UIAlertAction(title: "Delete".localized, style: .destructive) { _ in
                Task {
                    let success = await self.vm.deleteService()
                    if success {
                        NotificationCenter.default.post(name: .isAddService, object: ["isAddService": true] as [String: Any])
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            })
            self.present(alert, animated: true)
        }
    }
}
