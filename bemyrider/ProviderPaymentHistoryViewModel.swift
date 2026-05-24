//
//  ProviderPaymentHistoryViewModel.swift
//  bemyrider
//
//  SwiftUI ViewModel for Provider Payment History screen.
//

import Foundation
import UIKit

@MainActor
final class ProviderPaymentHistoryViewModel: ObservableObject {
    var onBack: (() -> Void)?

    @Published var transactions: [PaymentHistory.TransactionList] = []
    @Published var isLoading = false
    @Published var isLoadingMore = false
    @Published var errorMessage: String?
    
    weak var presentingVC: UIViewController?
    
    private var pagination: Any?
    
    var showNoRecords: Bool {
        transactions.isEmpty && !isLoading
    }
    
    var hasMorePages: Bool {
        guard let page = pagination as? PaymentHistory.Pagination else { return false }
        return page.currentPage < page.total_pages
    }
    
    func loadTransactions() async {
        isLoading = true
        errorMessage = nil

        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "page": 1
        ]

        do {
            let result = try await withCheckedThrowingContinuation { continuation in
                Modal.shared.providerSidePaymentHistory(
                    vc: presentingVC ?? UIViewController(),
                    param: param,
                    failer: { errMsg in
                        continuation.resume(throwing: NSError(domain: "PaymentHistory", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: errMsg]))
                    },
                    success: { response in
                        continuation.resume(returning: response)
                    }
                )
            }
            if let dic = result as? [String: Any] {
                let history = PaymentHistory(dictionary: dic)
                transactions = history.transection_list
                pagination = history.pagination
            }
        } catch {
            // keep existing state visible
        }

        isLoading = false
    }
    
    func loadMoreIfNeeded(currentItem: PaymentHistory.TransactionList) {
        guard let lastItem = transactions.last,
              lastItem.transection_id == currentItem.transection_id,
              hasMorePages,
              !isLoadingMore else {
            return
        }
        
        Task {
            await loadMoreTransactions()
        }
    }
    
    private func loadMoreTransactions() async {
        guard let page = pagination as? PaymentHistory.Pagination else { return }
        isLoadingMore = true

        let nextPage = page.currentPage + 1
        let param: [String: Any] = [
            "user_id": UserData.shared.getUser()?.user_id ?? "",
            "page": nextPage
        ]

        do {
            let result = try await withCheckedThrowingContinuation { continuation in
                Modal.shared.providerSidePaymentHistory(
                    vc: presentingVC ?? UIViewController(),
                    param: param,
                    failer: { errMsg in
                        continuation.resume(throwing: NSError(domain: "PaymentHistory", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: errMsg]))
                    },
                    success: { response in
                        continuation.resume(returning: response)
                    }
                )
            }
            if let dic = result as? [String: Any] {
                let history = PaymentHistory(dictionary: dic)
                transactions += history.transection_list
                pagination = history.pagination
            }
        } catch {
            // keep existing transactions visible
        }

        isLoadingMore = false
    }
    
    func refresh() {
        Task {
            await loadTransactions()
        }
    }
}
