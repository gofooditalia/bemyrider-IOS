//
//  HomeHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI HomeView.
//  Handles navigation to ServiceDetailVC, ProviderFilterVC.
//

import UIKit
import SwiftUI

final class HomeHostingVC: UIViewController {

    private let vm = HomeViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.presentingVC = self
        wireCallbacks()
        embedView()
        NotificationCenter.default.addObserver(self, selector: #selector(handleOpenRiderProfile(_:)), name: .openRiderProfile, object: nil)
    }

    deinit {
        NotificationCenter.default.removeObserver(self, name: .openRiderProfile, object: nil)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.navigationBar.isHidden = true
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.navigationBar.isHidden = false
    }
}

// MARK: - Setup

private extension HomeHostingVC {

    func wireCallbacks() {
        vm.onTapProvider = { [weak self] provider in
            self?.callProviderServiceDetail(provider: provider)
        }
        vm.onOpenFilter = { [weak self] in
            guard let self = self else { return }
            let vc = SearchHostingVC()
            vc.delegate = self
            vc.paramList = self.vm.currentFilterParams
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }

    func embedView() {
        view.backgroundColor = UIColor(red: 0.16, green: 0.13, blue: 0.40, alpha: 1)

        let child = UIHostingController(rootView: HomeView(viewModel: vm))
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

    func callProviderServiceDetail(provider: DeliveryProivderList) {
        guard let user = UserData.shared.getUser() else { return }
        let typeStr = vm.selectedTab.deliveryType   // "small" / "medium" / "large"
        Modal.shared.homeProviderServiceDetail(
            vc: self,
            param: [
                "user_id": user.user_id,
                "loginuser_id": user.user_id,
                "provider_id": provider.provider_id,
                "delivery_type": typeStr,
                "request_type": "scheduled"
            ]
        ) { [weak self] dic in
            guard let self = self else { return }
            is_from_myservices = false
            let nextVC = ServiceDetailHostingVC()
            let details = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            providerServiceDetail = details
            newDeliveryProvider = provider
            deliveryType = typeStr          // aggiorna la variabile globale
            topTitle = details.service_name
            nextVC.provider_service_id = details.id
            nextVC.provider_id = provider.provider_id
            nextVC.deliveryType = typeStr
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}

// MARK: - Deep Link

extension HomeHostingVC {

    @objc func handleOpenRiderProfile(_ notification: Notification) {
        print("🔗 [HomeHostingVC] handleOpenRiderProfile ricevuta userInfo=\(notification.userInfo ?? [:])")
        guard let providerId = notification.userInfo?["providerId"] as? String,
              let user = UserData.shared.getUser() else {
            print("🔗 [HomeHostingVC] ❌ guard fallito providerId=\(notification.userInfo?["providerId"] ?? "nil") user=\(UserData.shared.getUser()?.user_id ?? "nil")")
            return
        }
        print("🔗 [HomeHostingVC] ✅ avvio tryDeliveryTypes providerId=\(providerId)")
        let deliveryTypes = ["small", "medium", "large"]
        tryDeliveryTypesForDeepLink(deliveryTypes, providerId: providerId, userId: user.user_id)
    }

    private func tryDeliveryTypesForDeepLink(_ types: [String], providerId: String, userId: String) {
        guard !types.isEmpty else { return }
        let type = types[0]
        let remaining = Array(types.dropFirst())

        Modal.shared.homeProviderServiceDetail(vc: self, param: [
            "user_id": userId,
            "loginuser_id": userId,
            "provider_id": providerId,
            "delivery_type": type,
            "request_type": "scheduled"
        ], failer: { [weak self] _ in
            if !remaining.isEmpty {
                self?.tryDeliveryTypesForDeepLink(remaining, providerId: providerId, userId: userId)
            }
        }) { [weak self] dic in
            guard let self = self else { return }
            let details = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            guard !details.id.isEmpty else {
                if !remaining.isEmpty {
                    self.tryDeliveryTypesForDeepLink(remaining, providerId: providerId, userId: userId)
                }
                return
            }
            is_from_myservices = false
            providerServiceDetail = details
            topTitle = details.service_name

            let vc = ServiceDetailHostingVC()
            vc.provider_service_id = details.id
            vc.provider_id = providerId
            vc.deliveryType = type
            vc.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}

// MARK: - ProviderFilterDelegate

extension HomeHostingVC: ProviderFilterDelegate {

    func getFilterData(dic: [String: Any]) {
        guard !dic.isEmpty else { return }
        vm.applyFilter(dic)
    }

    func clearFilter() {
        vm.clearFilter()
    }
}
