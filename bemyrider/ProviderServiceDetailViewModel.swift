//
//  ProviderServiceDetailViewModel.swift
//  bemyrider
//
//  SwiftUI ViewModel for Provider Service Detail screen.
//

import Foundation
import UIKit

@MainActor
final class ProviderServiceDetailViewModel: ObservableObject {
    @Published var serviceDetail: ProviderServiceDetail?
    @Published var providerService: ProviderService?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab = 0
    
    weak var presentingVC: UIViewController?
    
    var onEditService: (() -> Void)?
    var onDeleteService: (() -> Void)?
    var onBack: (() -> Void)?
    
    var tabs: [String] {
        ["Servizio", "Recensioni", "Galleria"]
    }
    
    func loadData() async {
        guard let detail = serviceDetail else { return }
        
        isLoading = true
        
        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "provider_service_id": detail.provider_service_id,
            "delivery_type": detail.delivery_type,
            "request_type": "scheduled"
        ]
        
        let result = await withCheckedContinuation { continuation in
            Modal.shared.providerServiceDetail(vc: presentingVC!, param: param) { response in
                continuation.resume(returning: response)
            }
        }
        
        if let dic = result as? [String: Any] {
            serviceDetail = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
        }
        
        isLoading = false
    }
    
    func deleteService() async -> Bool {
        guard let detail = serviceDetail else { return false }
        
        let param: [String: Any] = [
            "provider_service_id": detail.id,
            "user_id": UserData.shared.getUser()?.user_id ?? ""
        ]
        
        return await withCheckedContinuation { continuation in
            Modal.shared.deleteService(vc: presentingVC!, param: param) { response in
                let status = (response as? [String: Any])?["status"] as? String ?? "0"
                continuation.resume(returning: status == "1")
            }
        }
    }
}
