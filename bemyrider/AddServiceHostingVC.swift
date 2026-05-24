//
//  AddServiceHostingVC.swift
//  bemyrider
//
//  UIKit container for the SwiftUI AddServiceView.
//

import UIKit
import SwiftUI

final class AddServiceHostingVC: NewBaseViewController {
    
    var editServiceDetail: ProviderServiceDetail?
    var editProviderService: ProviderService?
    
    private let vm = AddServiceViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.presentingVC = self
        
        if let detail = editServiceDetail {
            vm.loadForEdit(serviceDetail: detail, providerService: editProviderService)
        }

        embedView()
        wireCallbacks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}

// MARK: - Setup

private extension AddServiceHostingVC {
    
    func embedView() {
        let child = UIHostingController(rootView: AddServiceView(viewModel: vm))
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
    
    func wireCallbacks() {
        vm.onBack = { [weak self] in
            self?.navigationController?.popViewController(animated: true)
        }

        vm.onServiceAdded = { [weak self] in
            guard let nav = self?.navigationController else { return }
            if self?.editServiceDetail != nil,
               let myServicesVC = nav.viewControllers.first(where: { $0 is MyServicesHostingVC }) {
                nav.popToViewController(myServicesVC, animated: true)
            } else {
                nav.popViewController(animated: true)
            }
        }
        
        vm.onPickImage = { [weak self] in
            guard let self = self else { return }
            AttachmentHandler.shared.showPhotoAttachmentActionSheet(vc: self)
            AttachmentHandler.shared.imagePickedBlock = { [weak self] image, _ in
                self?.vm.addImage(image)
            }
        }
        
        vm.onError = { [weak self] message in
            let alert = UIAlertController(title: "Error".localized, message: message, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Ok".localized, style: .destructive, handler: nil))
            self?.present(alert, animated: true)
        }
    }
}
