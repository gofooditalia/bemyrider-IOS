//
//  ServiceRequestHostingVC.swift
//  TaskGator
//
//  UIKit container for the SwiftUI ServiceRequestView.
//  Replaces ServiceRequest.storyboardInstance in the tab bar.
//

import UIKit
import SwiftUI

final class ServiceRequestHostingVC: NewBaseViewController {

    private let vm = ServiceRequestViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.16, green: 0.13, blue: 0.40, alpha: 1)
        wireCallbacks()
        embedView()
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
}

// MARK: - Setup

private extension ServiceRequestHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: ServiceRequestView(viewModel: vm))
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
        vm.onTapCustomerItem = { [weak self] item in
            self?.openCustomerServiceDetail(item)
        }
        vm.onTapProviderItem = { [weak self] item in
            self?.openProviderServiceDetail(item)
        }
    }

    // MARK: - Navigation

    func openCustomerServiceDetail(_ item: CustomerServicesCls.CustomerServices) {
        topTitle = item.service_name
        customerSide_ProviderDetails = item
        let vc = CustomerSideServiceDetailHostingVC()
        vc.providerServiceId = item.provider_service_id
        vc.serviceRequestId = item.service_request_id
        vc.customerItem = item
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }

    func openProviderServiceDetail(_ item: ProviderServices) {
        topTitle = item.service_name
        providerSide_ProviderDetails = item
        let vc = ProviderSideServiceDetailHostingVC()
        vc.serviceRequestId = item.service_request_id
        vc.hidesBottomBarWhenPushed = true
        navigationController?.pushViewController(vc, animated: true)
    }
}
