//
//  ServiceDetailHostingVC.swift
//  TaskGator
//
//  UIKit container for SwiftUI ServiceDetailView.
//  Uses fullscreen gradient header pattern (no UIKit nav bar).
//

import UIKit
import SwiftUI

final class ServiceDetailHostingVC: UIViewController {

    // MARK: - Legacy Properties (kept for compatibility with callers)
    var provider_service_id: String = ""
    var provider_id: String = ""
    var deliveryType: String = ""

    private var viewModel: ServiceDetailViewModel!

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor(red: 0.16, green: 0.13, blue: 0.40, alpha: 1)

        setupViewModel()
        embedView()
        bindViewModel()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
}

// MARK: - Setup

private extension ServiceDetailHostingVC {

    func setupViewModel() {
        viewModel = ServiceDetailViewModel()
        viewModel.providerServiceId = provider_service_id
        viewModel.providerId = provider_id
        viewModel.deliveryType = deliveryType
    }

    func embedView() {
        let child = UIHostingController(rootView: ServiceDetailView(viewModel: viewModel))
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

    func bindViewModel() {
        viewModel.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        viewModel.onOpenLocationPicker = { [weak self] in
            guard let self = self else { return }
            let ac = PlaceAutocompleteVC()
            ac.onPlaceSelected = { [weak self] address, lat, lng in
                guard let self = self else { return }
                self.viewModel.address = address
                self.viewModel.latitude = lat
                self.viewModel.longitude = lng
            }
            self.present(UINavigationController(rootViewController: ac), animated: true)
        }

        viewModel.onShowAlert = { [weak self] title, message, completion in
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK".localized, style: .default, handler: { _ in
                completion?()
                if completion != nil {
                    self?.navigationController?.popViewController(animated: true)
                }
            }))
            self?.present(alert, animated: true)
        }

        viewModel.onPushToProfile = { [weak self] providerId in
            guard let self = self,
                  let vc = CustomerSideProviderProfileVC.storyboardInstance else { return }
            vc.providerId = providerId
            self.navigationController?.pushViewController(vc, animated: true)
        }
    }
}
