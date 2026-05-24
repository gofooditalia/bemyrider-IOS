//
//  FinancialInfoViewModel.swift
//  bemyrider
//
//  SwiftUI ViewModel for Financial Info screen.
//

import Foundation
import UIKit

@MainActor
final class FinancialInfoViewModel: ObservableObject {
    var onBack: (() -> Void)?

    @Published var totalEarned: String = ""
    @Published var completedServices: String = ""
    @Published var commission: String = ""
    @Published var netEarned: String = ""
    
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    weak var presentingVC: UIViewController?
    
    private var financialInfo: FinancialInfo?
    
    var currency: String {
        UserData.shared.currency
    }
    
    func loadData() async {
        guard !isLoading else { return }
        isLoading = true
        errorMessage = nil

        let param = ["user_id": UserData.shared.getUser()?.user_id ?? ""]

        do {
            let result = try await withCheckedThrowingContinuation { continuation in
                Modal.shared.getFinancialInfo(
                    vc: presentingVC ?? UIViewController(),
                    param: param,
                    failer: { errMsg in
                        continuation.resume(throwing: NSError(domain: "FinancialInfo", code: -1,
                            userInfo: [NSLocalizedDescriptionKey: errMsg]))
                    },
                    success: { response in
                        continuation.resume(returning: response)
                    }
                )
            }
            if let dic = result as? [String: Any],
               let data = dic["data"] as? [String: Any] {
                financialInfo = FinancialInfo(dictionary: data)
                totalEarned = "\(currency)\(financialInfo?.total_earned ?? "0")"
                completedServices = "\(financialInfo?.total_completed_service ?? 0)"
                commission = "\(currency)\(financialInfo?.total_commission ?? "0")"
                netEarned = "\(currency)\(financialInfo?.total_net_earned ?? "0")"
            }
        } catch {
            // keep existing values visible
        }

        isLoading = false
    }
    
    func refresh() {
        Task {
            await loadData()
        }
    }
}
