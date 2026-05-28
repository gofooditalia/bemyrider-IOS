//
//  CustomerProfileViewModel.swift
//  bemyrider
//
//  ViewModel for Customer Profile screen.
//

import UIKit

@MainActor
final class CustomerProfileViewModel: ObservableObject {

    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    var customerId: String?
    var isOwnProfile: Bool = true

    var onBack: (() -> Void)?
    var onEditTap: (() -> Void)?

    func loadProfile() {
        isLoading = true

        let userId: String
        if let customerId = customerId {
            userId = customerId
            isOwnProfile = false
        } else if Modal.sharedAppdelegate.isCustomerLogin {
            userId = UserData.shared.getUser()?.user_id ?? ""
        } else {
            userId = ""
        }

        guard !userId.isEmpty else {
            isLoading = false
            return
        }

        let param: [String: Any] = ["profile_id": userId]

        Modal.shared.getUserProfile(vc: UIViewController(), param: param) { [weak self] dic in
            DispatchQueue.main.async {
                self?.isLoading = false
                let data = ResponseKey.fatchData(res: dic, valueOf: .data).dic
                self?.profile = UserProfile(dictionary: data)
            }
        }
    }

    func refresh() {
        loadProfile()
    }

    var displayName: String {
        profile?.user_name ?? "Utente"
    }

    var phoneNumber: String {
        guard let profile = profile else { return "" }
        return "\(profile.country_code) \(profile.contact_number)"
    }

    var paymentMethodText: String {
        profile?.payment_mode == "w" ? "Portafoglio" : "Contanti"
    }

    var isFacebookVerified: Bool {
        !(profile?.fb_id.isEmpty ?? true)
    }

    var isGoogleVerified: Bool {
        !(profile?.gmail_id.isEmpty ?? true)
    }

    var isLinkedInVerified: Bool {
        !(profile?.linkedin_id.isEmpty ?? true)
    }

    var hasCompanyInfo: Bool {
        guard let profile = profile else { return false }
        return !(profile.company_name.isEmpty) ||
               !(profile.vat.isEmpty) ||
               !(profile.receipt_code.isEmpty) ||
               !(profile.certified_email.isEmpty)
    }
}
