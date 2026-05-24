//
//  DisputeListViewModel.swift
//  TaskGator
//
//  ViewModel for Resolution Center (Dispute List).
//

import UIKit

@MainActor
final class DisputeListViewModel: ObservableObject {

    @Published var disputes: [Dispute] = []
    @Published var isLoading = false

    private var disputeObj: DisputeCls?

    var onBack: (() -> Void)?
    var onTapDispute: ((Dispute) -> Void)?

    // MARK: - Load

    func load(reset: Bool = true) {
        if reset {
            disputeObj = nil
            disputes = []
        } else {
            guard let pag = disputeObj?.pagination,
                  pag.currentPage < pag.total_pages else { return }
        }
        guard !isLoading else { return }
        guard let user = UserData.shared.getUser() else { return }
        isLoading = true

        let nextPage = (disputeObj?.pagination?.currentPage ?? 0) + 1
        let param: [String: Any] = [
            "user_id": user.user_id,
            "page": nextPage
        ]

        Modal.shared.getDisputelist(vc: UIViewController(), param: param) { [weak self] dic in
            DispatchQueue.main.async {
                self?.disputeObj = DisputeCls(dictionary: dic)
                if reset {
                    self?.disputes = self?.disputeObj?.disputeList ?? []
                } else {
                    self?.disputes += self?.disputeObj?.disputeList ?? []
                }
                self?.isLoading = false
            }
        }
    }

    func refresh() {
        load(reset: true)
    }

    func loadMoreIfNeeded(index: Int) {
        guard index == disputes.count - 1 else { return }
        load(reset: false)
    }
}
