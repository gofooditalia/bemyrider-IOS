//
//  PaymentHistoryViewModel.swift
//  TaskGator
//
//  ViewModel for Payment History screen.
//

import UIKit

@MainActor
final class PaymentHistoryViewModel: ObservableObject {

    var onBack: (() -> Void)?

    @Published var transactions: [DepositHistoryList] = []
    @Published var isLoading = false

    private var depositHistoryObj: DepositHistory?

    // MARK: - Load

    func load(reset: Bool = true) {
        if reset {
            depositHistoryObj = nil
            transactions = []
        } else {
            guard let pag = depositHistoryObj?.pagination,
                  pag.currentPage < pag.total_pages else { return }
        }
        guard !isLoading else { return }
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        let nextPage = (depositHistoryObj?.pagination?.currentPage ?? 0) + 1
        let param: [String: Any] = [
            "user_id": user.user_id,
            "page": nextPage
        ]

        Modal.shared.paymentHistory(vc: UIViewController(), param: param, failer: { [weak self] _ in
            DispatchQueue.main.async { self?.isLoading = false }
        }) { [weak self] dic in
            DispatchQueue.main.async {
                self?.depositHistoryObj = DepositHistory(dictionary: dic)
                if reset {
                    self?.transactions = self?.depositHistoryObj?.historyList ?? []
                } else {
                    self?.transactions += self?.depositHistoryObj?.historyList ?? []
                }
                self?.isLoading = false
            }
        }
    }

    func refresh() {
        load(reset: true)
    }

    func loadMoreIfNeeded(index: Int) {
        guard index == transactions.count - 1 else { return }
        load(reset: false)
    }
}
