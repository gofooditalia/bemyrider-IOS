//
//  MyServicesHostingVC.swift
//  TaskGator
//
//  UIKit container for the SwiftUI MyServicesView.
//

import UIKit
import SwiftUI

final class MyServicesHostingVC: NewBaseViewController {
    
    private let vm = MyServicesViewModel()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        vm.presentingVC = self
        embedView()
        wireCallbacks()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
        vm.refresh()
    }
}

private extension MyServicesHostingVC {
    
    func embedView() {
        let child = UIHostingController(rootView: MyServicesView(viewModel: vm))
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
        
        vm.onAddService = { [weak self] in
            let vc = AddServiceHostingVC()
            vc.hidesBottomBarWhenPushed = true
            self?.navigationController?.pushViewController(vc, animated: true)
        }
        
        vm.onServiceSelected = { [weak self] (service: ProviderService) in
            guard let self = self else { return }
            let param = [
                "user_id": UserData.shared.getUser()!.user_id,
                "provider_service_id": service.provider_service_id
            ]
            Modal.shared.providerServiceDetail(vc: self, param: param) { dic in
                providerServiceDetail = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
                providerService = service
                
                if Modal.sharedAppdelegate.isCustomerLogin {
                    let vc = ServiceDetailHostingVC()
                    vc.provider_service_id = service.provider_service_id
                    vc.provider_id = providerServiceDetail?.provider_id ?? ""
                    vc.deliveryType = providerServiceDetail?.delivery_type ?? ""
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                } else {
                    let vc = ProviderServiceDetailHostingVC()
                    vc.serviceDetail = providerServiceDetail
                    vc.providerService = providerService
                    vc.hidesBottomBarWhenPushed = true
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
}
