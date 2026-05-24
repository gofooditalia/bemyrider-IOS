//
//  DisputeDetailViewModel.swift
//  bemyrider
//

import Foundation
import SwiftUI

@MainActor
final class DisputeDetailViewModel: ObservableObject {

    @Published var disputeInfo: DisputeMsgCls?
    @Published var messages: [DisputeMsg] = []
    @Published var isLoading = false
    @Published var messageText = ""
    @Published var isSending = false
    @Published var showAlert = false
    @Published var alertMessage = ""

    var dispute: Dispute?
    var onBack: (() -> Void)?

    private var currentPage = 0

    var isEscalated: Bool {
        disputeInfo?.escalate_admin == "y"
    }

    var disputeTitle: String {
        dispute?.dispute_title ?? disputeInfo?.dispute_title ?? ""
    }

    var raisedByName: String {
        guard let dispute = dispute else { return "" }
        let isCustomer = Modal.sharedAppdelegate.isCustomerLogin
        let isCreator = dispute.created_user == UserData.shared.getUser()?.user_id
        if isCustomer {
            return isCreator
                ? "\(dispute.customer_firstname) \(dispute.customer_lastname)"
                : "\(dispute.provider_firstname) \(dispute.provider_lastname)"
        } else {
            return isCreator
                ? "\(dispute.provider_firstname) \(dispute.provider_lastname)"
                : "\(dispute.customer_firstname) \(dispute.customer_lastname)"
        }
    }

    var statusText: String {
        guard let info = disputeInfo else { return dispute?.status ?? "" }
        if info.escalate_admin == "y" { return "Gestita dall'admin" }
        return info.status
    }

    var createdDate: String {
        dispute?.createdDate ?? ""
    }

    // MARK: - Load

    func loadDetails() {
        print("loadDetails called - dispute: \(dispute?.dispute_id ?? "nil")")
        guard let dispute = dispute else {
            print("loadDetails FAILED: dispute is nil!")
            return
        }
        isLoading = messages.isEmpty
        let nextPage = currentPage + 1

        var param: [String: Any] = [
            "dispute_id": dispute.dispute_id,
            "page": nextPage
        ]
        if nextPage > 1, let lastId = messages.last?.message_id {
            param["last_message_id"] = lastId
        }
        print("loadDetails API params: \(param)")

        Task {
            do {
                print("loadDetails: calling API with params: \(param)")
                // Try using Modal first (old way that works)
                let dic = try await withCheckedThrowingContinuation { (continuation: CheckedContinuation<[String: Any], Error>) in
                    Modal.shared.getDisputedetails(vc: UIViewController(), param: param, failer: { error in
                        continuation.resume(throwing: APIError(message: error))
                    }) { response in
                        continuation.resume(returning: response)
                    }
                }
                print("Modal API Response for dispute details: \(dic)")
                let msgObj = DisputeMsgCls(dictionary: dic)
                self.disputeInfo = msgObj
                print("disputeInfo loaded: dispute_id=\(msgObj.dispute_id ?? "nil"), escalate_admin=\(msgObj.escalate_admin ?? "nil")")
                self.currentPage = msgObj.pagination?.currentPage ?? nextPage

                if self.messages.isEmpty {
                    self.messages = msgObj.disputeMsgList
                } else {
                    self.messages += msgObj.disputeMsgList
                }
            } catch {
                print("DisputeDetail load error: \(error)")
            }
            self.isLoading = false
        }
    }

    func loadMoreIfNeeded(message: DisputeMsg) {
        guard let last = messages.last,
              last.message_id == message.message_id,
              let pagination = disputeInfo?.pagination,
              pagination.currentPage < pagination.total_pages else { return }
        loadDetails()
    }

    // MARK: - Send Message

    func sendMessage() {
        let text = messageText.trimmingCharacters(in: .whitespacesAndNewlines)
        print("sendMessage called - text: \(text), disputeInfo: \(disputeInfo?.dispute_id ?? "nil"), dispute: \(dispute?.dispute_id ?? "nil")")
        
        guard !text.isEmpty else {
            print("sendMessage failed: empty text")
            return
        }
        
        // Use disputeInfo.dispute_id if available, otherwise fall back to dispute.dispute_id
        let disputeId = disputeInfo?.dispute_id ?? dispute?.dispute_id ?? ""
        guard !disputeId.isEmpty else {
            print("sendMessage failed: no dispute_id available")
            return
        }

        isSending = true
        let param: [String: Any] = [
            "dispute_id": disputeId,
            "message_text": text,
            "user_id": UserData.shared.getUser()?.user_id ?? ""
        ]
        print("Sending dispute message with params: \(param)")

        // Use Modal (old API) for better compatibility
        Modal.shared.sendDisputeMessage(vc: UIViewController(), param: param, postImage: nil, imageName: nil, failer: { [weak self] error in
            print("DisputeDetail send error: \(error)")
            DispatchQueue.main.async {
                self?.isSending = false
            }
        }) { [weak self] dic in
            print("Modal send message API response: \(dic)")
            let data = ResponseKey.fatchDataAsDictionary(res: dic, valueOf: .data)
            let msg = DisputeMsg(dictionary: data)
            DispatchQueue.main.async {
                self?.messages.insert(msg, at: 0)
                self?.messageText = ""
                self?.isSending = false
            }
        }
    }

    func isCurrentUser(_ message: DisputeMsg) -> Bool {
        message.created_user == UserData.shared.getUser()?.user_id
    }

    // MARK: - Escalate to Admin

    @Published var isEscalating = false

    func escalateToAdmin() {
        guard let disputeId = disputeInfo?.dispute_id ?? dispute?.dispute_id,
              !disputeId.isEmpty else { return }

        let serviceReqId = dispute?.service_request_id ?? ""
        guard !serviceReqId.isEmpty else {
            alertMessage = "Impossibile inoltrare: dati servizio mancanti."
            showAlert = true
            return
        }

        isEscalating = true
        let params: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "service_id": serviceReqId
        ]
        print("escalateToAdmin params: \(params)")

        Task {
            do {
                let response = try await APIClient.shared.escalateToAdmin(params: params)
                print("escalateToAdmin response: \(response)")
                self.disputeInfo?.escalate_admin = "y"
                self.alertMessage = "Controversia inoltrata all'amministrazione."
                self.showAlert = true
            } catch {
                print("Escalate error: \(error)")
                self.alertMessage = "Errore nell'inoltro: \(error.localizedDescription)"
                self.showAlert = true
            }
            self.isEscalating = false
        }
    }

    func senderName(for message: DisputeMsg) -> String {
        if let info = disputeInfo {
            if message.created_user_type == "c" {
                return "\(info.customer_firstname) \(info.customer_lastname)"
            } else {
                return "\(info.provider_firstname) \(info.provider_lastname)"
            }
        }
        // Fallback to dispute object from list
        if let d = dispute {
            if message.created_user_type == "c" {
                return "\(d.customer_firstname) \(d.customer_lastname)"
            } else {
                return "\(d.provider_firstname) \(d.provider_lastname)"
            }
        }
        return ""
    }
}
