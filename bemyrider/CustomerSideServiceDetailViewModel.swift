import Foundation
import SwiftUI
import UIKit

@MainActor
final class CustomerSideServiceDetailViewModel: ObservableObject {

    @Published var serviceDetail: ProviderServiceDetail?
    @Published var isLoading = false
    @Published var isFavorite = false
    @Published var showDisputePopup = false
    @Published var cancelDidSucceed = false

    weak var presentingVC: UIViewController?
    var providerServiceId: String?
    var serviceRequestId: String?
    var customerItem: CustomerServicesCls.CustomerServices?

    var onBack: (() -> Void)?
    var onBookNowComplete: (([String: Any]) -> Void)?
    var onCancelSuccess: (() -> Void)?
    var onDownloadInvoice: (() -> Void)?
    var onSendMessage: (() -> Void)?
    var onRaiseDispute: (() -> Void)?
    var onDisputeSuccess: (() -> Void)?
    var onAddReview: (() -> Void)?
    var onExtendService: (() -> Void)?
    var onPayExtendedService: (() -> Void)?
    var onViewDispute: (() -> Void)?

    func loadData() async {
        isLoading = true

        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "provider_service_id": providerServiceId ?? "",
            "service_request_id": serviceRequestId ?? ""
        ]

        do {
            let dic = try await APIClient.shared.getProviderServiceDetail(params: param)
            let detail = ProviderServiceDetail(dic: ResponseKey.fatchData(res: dic, valueOf: .data).dic)
            serviceDetail = detail
            providerServiceDetail = detail
            isFavorite = detail.total_favorite > "0"
            NotificationCenter.default.post(name: .reloadFirstServiceData, object: nil)
        } catch {
            print(error)
        }

        isLoading = false
    }

    // MARK: - Status

    var statusColor: SwiftUI.Color {
        guard let status = serviceDetail?.service_status.lowercased() else { return SwiftUI.Color.gray }
        switch status {
        case "completed": return SwiftUI.Color.green
        case "pending": return SwiftUI.Color.orange
        case "accepted": return SwiftUI.Color.blue
        case "rejected", "cancelled": return SwiftUI.Color.red
        case "hired", "ongoing": return SwiftUI.Color.purple
        case "dispute": return SwiftUI.Color.red
        default: return SwiftUI.Color.gray
        }
    }

    // MARK: - Button visibility

    var isDispute: Bool {
        serviceDetail?.service_status.lowercased() == "dispute"
    }

    /// Rider in alto + no pagamento: dispute, rejected, cancelled, completed, expired
    var compactLayout: Bool {
        guard let status = serviceDetail?.service_status.lowercased() else { return false }
        return ["dispute", "rejected", "cancelled", "completed", "closed", "expired", "pending"].contains(status)
    }

    var showViewDispute: Bool {
        isDispute
    }

    var showBookNow: Bool {
        serviceDetail?.service_status.lowercased() == "accepted"
    }

    var showCancel: Bool {
        serviceDetail?.service_status.lowercased() == "hired"
    }

    var showDownloadInvoice: Bool {
        serviceDetail?.service_status.lowercased() == "completed"
    }

    var showAddReview: Bool {
        guard let d = serviceDetail else { return false }
        return d.service_status.lowercased() == "completed" && d.isReviewGiven.lowercased() == "n"
    }

    var showMessageButton: Bool {
        guard let status = serviceDetail?.service_status.lowercased() else { return false }
        return ["completed", "hired", "ongoing"].contains(status)
    }

    var showDisputeButton: Bool {
        guard let status = serviceDetail?.service_status.lowercased() else { return false }
        return ["hired", "ongoing"].contains(status)
    }

    var showExtendService: Bool {
        guard let d = serviceDetail else { return false }
        let status = d.service_status.lowercased()
        return status == "ongoing" && d.service_master_type == "hourly" && d.extend_service_data.count == 0
    }

    var showPayExtendedService: Bool {
        guard let d = serviceDetail else { return false }
        let status = d.service_status.lowercased()
        guard status == "ongoing", d.extend_service_data.count > 0 else { return false }
        return d.extend_service_data[0].serviceStatus == "accepted"
    }

    // MARK: - Favourite

    func toggleFavourite() {
        guard let d = serviceDetail, let vc = presentingVC else { return }
        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "service_id": customerItem?.provider_service_id ?? "",
            "fvrt_val": d.total_favorite > "0" ? "1" : "0",
            "lId": UserData.shared.languageID,
            "provider_id": d.provider_id,
            "delivery_type": d.delivery_type,
            "request_type": d.request_type
        ]

        Modal.shared.likeDislikeServices(vc: vc, param: param) { _ in
            DispatchQueue.main.async {
                self.serviceDetail?.total_favorite = (self.serviceDetail?.total_favorite ?? "0") > "0" ? "0" : "1"
                self.isFavorite = (self.serviceDetail?.total_favorite ?? "0") > "0"
                NotificationCenter.default.post(name: .providerDisLike, object: ["isProviderDislike": true])
            }
        }
    }

    // MARK: - Book Now

    func bookNow() {
        guard let item = customerItem, let vc = presentingVC else { return }
        let param = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "service_id": item.service_request_id
        ]
        Modal.shared.serviceRequestBookNow(vc: vc, param: param) { dic in
            Modal.sharedAppdelegate.stoapLoader()
            let dicData = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
            DispatchQueue.main.async {
                self.onBookNowComplete?(dicData)
            }
        }
    }

    // MARK: - Cancel

    func cancelService(reason: String) {
        guard let item = customerItem, let vc = presentingVC else { return }
        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "service_id": item.service_request_id,
            "cancel_reason": reason,
            "user_type": "c"
        ]
        Modal.shared.cancelService(vc: vc, param: param, failer: { errorMsg in
            print("Cancel service failed: \(errorMsg)")
        }) { _ in
            NotificationCenter.default.post(name: .reloadProviderTasks, object: nil)
            DispatchQueue.main.async {
                self.cancelDidSucceed = true
            }
        }
    }
}
