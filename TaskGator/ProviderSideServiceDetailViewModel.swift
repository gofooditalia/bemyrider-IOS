import Foundation
import SwiftUI
import UIKit

@MainActor
final class ProviderSideServiceDetailViewModel: ObservableObject {
    
    @Published var serviceDetail: ProviderServices?
    @Published var providerServiceDetail: ProviderServiceDetail?
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var selectedTab: Int = 0
    @Published var showDisputePopup = false
    
    weak var presentingVC: UIViewController?
    var serviceRequestId: String?
    
    var onBack: (() -> Void)?
    var onAcceptSuccess: (() -> Void)?
    var onRejectSuccess: (() -> Void)?
    var onCancelSuccess: (() -> Void)?
    var onSendProposal: (() -> Void)?
    var onDownloadInvoice: (() -> Void)?
    var onRaiseDispute: (() -> Void)?
    var onDisputeSuccess: (() -> Void)?
    var onSendMessage: (() -> Void)?
    var onCustomerProfileTap: (() -> Void)?
    
    func loadData() async {
        guard let requestId = serviceRequestId else { return }
        
        isLoading = true
        
        do {
            let param: [String: Any] = [
                "user_id": UserData.shared.getUser()?.user_id ?? "",
                "service_request_id": requestId
            ]
            let dic = try await APIClient.shared.getProviderServiceData(params: param)
            
            if let data = dic["data"] as? [String: Any] {
                serviceDetail = ProviderServices(dictionary: data)
            }
            
            if let detail = serviceDetail {
                let providerServiceParam: [String: Any] = [
                    "provider_service_id": detail.provider_service_id
                ]
                let providerServiceDic = try await APIClient.shared.getProviderServiceDetail(params: providerServiceParam)
                if let providerServiceData = providerServiceDic["data"] as? [String: Any] {
                    providerServiceDetail = ProviderServiceDetail(dic: providerServiceData)
                }
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        
        isLoading = false
    }
    
    func acceptService() async -> Bool {
        guard let detail = serviceDetail else { return false }
        guard let vc = presentingVC else { return false }

        Modal.sharedAppdelegate.startLoader()

        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "service_id": detail.service_request_id,
            "provider_service_id": detail.provider_service_id,
            "provider_id": detail.provider_id,
            "status_type": "accepted"
        ]

        return await withCheckedContinuation { continuation in
            Modal.shared.acceptService(vc: vc, param: param, failer: { _, message in
                self.errorMessage = message
                continuation.resume(returning: false)
            }) { _ in
                continuation.resume(returning: true)
            }
        }
    }

    func rejectService() async -> Bool {
        guard let detail = serviceDetail else { return false }
        guard let vc = presentingVC else { return false }

        Modal.sharedAppdelegate.startLoader()

        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "service_id": detail.service_request_id,
            "provider_service_id": detail.provider_service_id,
            "provider_id": detail.provider_id,
            "status_type": "rejected"
        ]

        return await withCheckedContinuation { continuation in
            Modal.shared.acceptService(vc: vc, param: param, failer: { _, message in
                self.errorMessage = message
                continuation.resume(returning: false)
            }) { _ in
                continuation.resume(returning: true)
            }
        }
    }

    func cancelService(reason: String) async -> Bool {
        guard let detail = serviceDetail else { return false }
        guard let vc = presentingVC else { return false }

        Modal.sharedAppdelegate.startLoader()

        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "service_id": detail.service_request_id,
            "cancel_reason": reason,
            "user_type": "p"
        ]

        return await withCheckedContinuation { continuation in
            Modal.shared.cancelService(vc: vc, param: param, failer: { errorMsg in
                self.errorMessage = errorMsg ?? "Errore sconosciuto"
                continuation.resume(returning: false)
            }) { _ in
                continuation.resume(returning: true)
            }
        }
    }
    
    var statusColor: SwiftUI.Color {
        guard let status = serviceDetail?.service_status else { return SwiftUI.Color.gray }
        
        switch status.lowercased() {
        case "completed":
            return SwiftUI.Color.green
        case "pending":
            return SwiftUI.Color.orange
        case "accepted":
            return SwiftUI.Color.blue
        case "rejected", "cancelled":
            return SwiftUI.Color.red
        case "hired", "ongoing":
            return SwiftUI.Color.purple
        default:
            return SwiftUI.Color.gray
        }
    }
    
    var showAcceptRejectButtons: Bool {
        serviceDetail?.service_status.lowercased() == "pending"
    }
    
    var showCancelButton: Bool {
        ["hired", "ongoing"].contains(serviceDetail?.service_status.lowercased())
    }
    
    var showDownloadInvoice: Bool {
        serviceDetail?.service_status.lowercased() == "completed"
    }
    
    var showSendProposal: Bool {
        serviceDetail?.service_status.lowercased() == "pending" && 
        (serviceDetail?.proposal_service_data.isEmpty ?? true)
    }
    
    var showMessageButton: Bool {
        guard let status = serviceDetail?.service_status.lowercased() else { return false }
        return ["completed", "hired", "ongoing", "dispute"].contains(status)
    }
    
    var showDisputeButton: Bool {
        guard let status = serviceDetail?.service_status.lowercased() else { return false }
        return ["hired", "ongoing"].contains(status)
    }
}
