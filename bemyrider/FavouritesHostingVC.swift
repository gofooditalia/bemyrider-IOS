//
//  FavouritesHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI FavouritesView.
//  Replaces FavouriteServicesVC.storyboardInstance in the customer tab bar.
//

import UIKit
import SwiftUI

final class FavouritesHostingVC: NewBaseViewController {

    private let vm = FavouritesViewModel()

    override func viewDidLoad() {
        super.viewDidLoad()
        vm.onTapItem = { [weak self] item in self?.openDetail(item) }
        embedView()
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(onProviderDislike(_:)),
            name: .providerDisLike,
            object: nil
        )
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        vm.refresh()
    }

    @objc private func onProviderDislike(_ notification: Notification) {
        if (notification.object as? [String: Bool])?["isProviderDislike"] == true {
            vm.refresh()
        }
    }
}

// MARK: - Setup

private extension FavouritesHostingVC {

    func embedView() {
        let child = UIHostingController(rootView: FavouritesView(viewModel: vm))
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

    func openDetail(_ item: FavoriteService) {
        guard let user = UserData.shared.getUser() else { return }
        Modal.shared.homeProviderServiceDetail(vc: self, param: [
            "user_id": user.user_id,
            "loginuser_id": user.user_id,
            "provider_id": item.provider_id,
            "delivery_type": item.delivery_type,
            "request_type": "scheduled"
        ]) { [weak self] dic in
            guard let self = self else { return }
            is_from_myservices = false
            let details = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            providerServiceDetail = details
            topTitle = details.service_name
            deliveryType = details.delivery_type
            let nextVC = ServiceDetailHostingVC()
            nextVC.provider_service_id = details.provider_service_id
            nextVC.provider_id = details.provider_id
            nextVC.deliveryType = details.delivery_type
            nextVC.hidesBottomBarWhenPushed = true
            self.navigationController?.pushViewController(nextVC, animated: true)
        }
    }
}
